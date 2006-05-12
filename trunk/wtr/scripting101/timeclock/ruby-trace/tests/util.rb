require 'ruby-trace/all'
require 'ruby-trace/util/todo'
include Todo
todo "If this doesn't appear, ruby-trace/util/todo is broken."

                       ### Overrides of Test::Unit Stuff ###
# Eliminate accidental dependencies on the environment.
class TraceTestCase < Test::Unit::TestCase
  def setup
    super
    ENV.delete('TRACEENV')
  end

  def test_dummy
    # Required to avoid spurious error in test::unit, which
    # wants to have a test in each test class.
  end
end

# Even though test classes all run together, we want to reinitialize the
# global $trace for each test. Eliminate accidental dependencies among
# tests.
class GlobalTestCase < TraceTestCase
  def setup
    super
    $trace = Trace::Connector.debugging_buffer
  end
end
  

# Same as GlobalTestCase, but for the method form of accessing the
# default Connector. 
class MethodTestCase < TraceTestCase
  def setup
    super
    # This is a kludge because test::unit insists on running 
    # a test in every test class, even if it's an abstract base class
    # like this one. Fooey.
    if self.respond_to?('trace')
      self.trace = Trace::Connector.debugging_buffer
    end
  end
end


                    ### Support for test setup ###

def two_test_destinations
  Trace::Connector.debugging_buffer {
    add_theme('usage', %w{task feature gesture})
    theme_and_destination_use_default('usage', 'buffer', 'feature')
    
    add_destination(Trace::BufferDestination.new('alternate'), :default)
    theme_and_destination_use_default('debugging', 'alternate', 'announce') 
    theme_and_destination_use_default('usage', 'alternate', 'task')
  }
end

                    ### Specialized Assertions ###

def assert_trace_exception(expected_message)
  begin
    yield
  rescue Trace::Exception
    assert_equal(expected_message, $!.message)
  rescue Exception
    assert(false, "Expected Trace::Exception, not #{$!.class}, #{$!.message}, #{$!.backtrace.join($/)}")
  else
    assert(false, "Expected a Trace::Exception")
  end
end


# Assert that destination has received the messages in Array strings.
# Destination must respond to 'messages'.
def assert_messages(destination, expected_strings, connector=$trace)
  actual_strings = connector.destination_named(destination).messages.collect { | m |
    m.body
  }
  assert_equal(expected_strings, actual_strings)
end


# Don't just use equal - makes for better error messages.
def assert_equal_arrays(expected, actual)
  assert_equal(expected.length, actual.length)
  (0...expected.length).each { | i |
    assert_equal(expected[i], actual[i])
  }
end

# Assert the contents of a file are as expected. 
# We could call diff, but the expected results files would have
# carriage returns in them, probably.
def assert_lines_in_file (file, expected)
  lines = File.readlines(file).collect{|l| l.chomp}
  assert_equal_arrays(expected, lines)
end


# Assert_messages_in_file checks messages that have been dumped to a file.
# Because the first line (with the location and timestamp) changes a lot,
# it's not checked exactly. Different tests do different approximate checks,
# controlled by one of these regexps. 

# Trace message comes from a test routine. The default.
TESTFILE_FORMAT=%r{.*\.rb:[\d]+:in `test_.*' at ..../../.. ..:..:..$}
# From a test routine, but without a timestamp.
TESTFILE_NO_TIME_FORMAT=%r{.*\.rb:[\d]+:in `test_.*'}
# Trace message comes from wherever and has a timestamp.
TIME_FORMAT=%r{.*\.rb:[\d]+.* at ..../../.. ..:..:..$}

def assert_messages_in_file(file, expected_strings, line1_format=TESTFILE_FORMAT)
  File.open(file, 'r') { | ios |
    messages = []
    while (line1 = ios.gets)
      line2 = ios.readline
      assert(line1 =~ line1_format, line1)
      assert(line2 =~ /= [a-z]* [a-z]+: (.*)/, line2)
      messages.push($1)
    end
    assert_equal_arrays(expected_strings, messages)
  }
end


def assert_messages_in_glob(glob, expected_strings)
  matches = Dir[glob]
  assert_equal(1, matches.length)
  assert_messages_in_file(matches[0], expected_strings)
end

  

                   ### Miscellaneous Utilities ###

def lines(*args)
  args.join($/)
end

def send_all(tr)
  tr.error 'error'
  tr.warning 'warning'
  tr.announce 'announce'
  tr.event 'event'
  tr.debug 'debug'
  tr.verbose 'verbose'
end

# Delete files matching prefix*
def remove(filename_prefix)    
  assert(/out/ =~ filename_prefix) # don't accidentally blow away useful files.
  matches = Dir[filename_prefix + "*"]
  matches.each { | match |
    File.safe_unlink(match)
  }
end

                  ### LogfileDestination support ###

def file_connector(filename,
                   dest = Trace::LogfileDestination.new('file', filename))
  Trace::Connector.new {
    add_destination(dest, :default)
    debugging_theme
    theme_and_destination_use_default('debugging', 'file', 'event')
  }
end

def close(connector)          # close the 'file' destination for connector
  connector.destination_named('file').close
end




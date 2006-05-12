# This is an UNFINISHED attempt to run the unit tests currently.
# The work on the harness is complete. 
# The problem remaining is that the tests are not thread-safe.
# It's an open question whether getting this to work would actually save any execution time.

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR
Dir.chdir TOPDIR
#(Dir["unittests/*_test.rb"] - ["unittests/popups_test.rb"]).each {|x| require x}

require 'unittests/buttons_test'
require 'unittests/checkbox_test'

require 'test/unit/testsuite'
require 'thread'
class ConcurrentTestSuite < Test::Unit::TestSuite
  
  # Runs the tests and/or suites contained in this TestSuite.
  def run(result, &progress_block)
    yield(STARTED, name)
    threads = []
    @tests.each do |test|
      threads << Thread.new do
        test.run(result, &progress_block)
      end
    end
    threads.each {|t| t.join}
    yield(FINISHED, name)
  end
end

# create a suite
require 'test/unit/collector/objectspace'

require 'test/unit/collector'
include Test::Unit::Collector


@filters = []
suite = ConcurrentTestSuite.new('super suite')
sub_suites = []
::ObjectSpace.each_object(Class) do |klass|
  if(Test::Unit::TestCase > klass)
    puts sub_suites, klass.suite
    add_suite(sub_suites, klass.suite)
  end
end
sort(sub_suites).each{|s| suite << s}



# select a runner
require 'test/unit/ui/console/testrunner'
Test::Unit::UI::Console::TestRunner.run(suite)


# then subclass Test::Unit::TestSuite and override the run method to be multithreaded

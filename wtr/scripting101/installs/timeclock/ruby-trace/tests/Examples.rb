require "test/unit"
require "ruby-trace/all"
require "util"
require 'ftools'


class Examples < TraceTestCase

  # Fetch an example to run.
  def get_example(name)
    assert(File.syscopy("../doc/examples/#{name}.rb", '.'))
  end

  # Run an external command, which is expected to succeed.
  def out(command)
    assert(system(command))
  end

  # Run an external command, which is expected to fail.
  def errout(command)
    assert(!system(command))
  end

  # Rename "Tracelog.txt" to an outfile, or rename the second arg.
  def outfile(name, from='Tracelog.txt')
    assert(File.move(from, name))
  end


  def test_print_example
    get_example 'print-example'
    out "ruby print-example.rb -r hi > out-print"

    assert_lines_in_file('out-print', ["called with '-r hi'"])

    out "../bin/ruby-trace print-example.rb -r hi > out-print"
    assert_lines_in_file('out-print', [
                  "print-example.rb:21:in `initialize'", 
                   "=  announce: New instance of Example: 'Example one'",
                   "print-example.rb:21:in `initialize'",
                   "=  announce: New instance of Example: 'Example two'",
                   "called with '-r hi'"])

    # This array will be used twice.
    expected = [
      "print-example.rb:21:in `initialize'",
      "=  announce: New instance of Example: 'Example one'",
      "print-example.rb:21:in `initialize'",
      "=  announce: New instance of Example: 'Example two'",
      "print-example.rb:25:in `do_something_detailed'",
      "=  verbose: something detailed has happened",
      "called with '-r hi'"]

    out "../bin/ruby-trace -t verbose print-example.rb -r hi > out-print"
    assert_lines_in_file('out-print', expected)
    # Try again with long argument.
    out "../bin/ruby-trace --threshold verbose print-example.rb -r hi > out-print"
    assert_lines_in_file('out-print', expected)

    # Try internal tracing. New trace statements are added all the time,
    # so we just do some rudimentary sanity checks.
    out "../bin/ruby-trace -i announce print-example.rb -r hi > out-print"
    lines = File.readlines('out-print')
    assert(lines.length > 10)
    assert_equal("called with '-r hi'", lines.last.chomp)
    # Make sure there are messages from the trace system at announce level.
    # Hope -q is a common option.
    out "grep -q 'trace announce' out-print"
    # Moreover, the messages from the default trace should still appear. 
    out "grep -q '=  announce: ' out-print"
  end


  def test_drain_example
    get_example 'drain-example'
    out "ruby drain-example.rb hi > out-drain"
    assert_equal(["argument is HI\n"], File.readlines('out-drain'))

    # Now show drain on error.
    errout "ruby drain-example.rb > out-drain-ignored 2>&1"
    outfile 'out-drain'
    expected = [
      'Messages at the "announce" level appear in both destinations.',
      '==== Beginning of buffer contents.',
      'Messages at the "announce" level appear in both destinations.',
      'Messages at the "event" level appear in only the buffer.',
      '==== End of buffer contents.'
    ]
    assert_messages_in_file('out-drain', expected, TIME_FORMAT)
  end

  # Note that this test now ties us to bash-type shells. But I want to do
  # exactly what I tell the typical user to do.
  def test_topic_example
    get_example 'topic-example'
    out %q{(export TRACEENV="accounting-file-threshold=verbose global-debugging-file-default=warning"; ruby topic-example.rb > out-topic-ignored)}
    
    outfile 'out-topic'
    expected = [
      'Impossible event explode in state crashed.',
      '(Error-level messages are normally seen.)',
      'state -> "crashed"',
      '(Verbose-level messages normally are not.)',
      'Hide! The auditors are coming.',
      '(The global threshold still allows warning messages.)'
    ]
    assert_messages_in_file('out-topic', expected, TIME_FORMAT)

    # Just for laughs, make sure the messages come from the right topics.
    messages = Trace::MessageReader.new.from_file('out-topic')
    assert_equal("accounting", messages[0].topic)
    assert_equal("accounting", messages[1].topic)
    assert_equal("accounting", messages[2].topic)
    assert_equal("accounting", messages[3].topic)
    assert_equal('', messages[4].topic)
    assert_equal('', messages[5].topic)

  end

  def test_topic_access_example
    get_example 'topic-access-example'
    out 'ruby topic-access-example.rb > out-topic-access-ignored'
    outfile 'out-topic-access'

    # The example uses odd topic names. Check them as well as the message
    # body. Could use assert_messages_in_file, but this is more convenient.
    # It does check for syntax errors that MessageReader may not, but
    # it's probably enough to do that in test_topic_example.
    messages = Trace::MessageReader.new.from_file('out-topic-access')
    assert_equal("using module constant", messages[0].topic)
    assert_equal("using class variables", messages[1].topic)
    assert_equal("using class variables", messages[2].topic)
    assert_equal("installing_on_connector", messages[3].topic)

    assert_equal("here's an example of using a module constant.",
                  messages[0].body)
    assert_equal("here's an example of using class variables.",
                  messages[1].body)
    assert_equal("topics are singletons.",
                  messages[2].body)
    assert_equal("Topics can be installed on the connector.",
                  messages[3].body)
  end

  def test_usage_example_1
    get_example 'usage-example-1'
    out 'ruby usage-example-1.rb > out-topic-usage-1-ignored'
    outfile 'out-usage-1'

    expected = [
      'User interface starts.',
      'User has turned off all helpful suggestions.'
    ]
    assert_messages_in_file('out-usage-1', expected, TIME_FORMAT)
  end
    
  def test_usage_example_2
    get_example 'usage-example-2'
    out 'ruby usage-example-2.rb > out-topic-usage-2-ignored'
    outfile 'out-usage-2.debug'
    outfile 'out-usage-2.usage', 'Usagelog.txt'

    assert_messages_in_file('out-usage-2.debug',
                            ['User interface starts.'], TIME_FORMAT)
    assert_messages_in_file('out-usage-2.usage',
                            ['User has turned off all helpful suggestions.'],
                            TIME_FORMAT)
  end
    

  def test_dump_example
    get_example 'dump-example'
    out 'ruby dump-example.rb > out-dump'
    expected = [
      "Exception caught: undefined method `upcase' for nil:NilClass",
      "=====Trace dump begins=========",
      "dump-example.rb:16",
      "=  event: This normally appears in the ring buffer.",
      "=====Trace dump ends==========="]
    assert_lines_in_file('out-dump', expected)

    out '../bin/ruby-trace -t verbose dump-example.rb > out-dump'
    # Splice in the verbose message.
    expected[-1,0] = [
      "dump-example.rb:17",
      "=  verbose: This normally does not."]
    assert_lines_in_file('out-dump', expected)
  end

  def test_todo_example
    get_example 'todo-example'
    out 'ruby todo-example.rb > out-todo'
    lines = File.readlines('out-todo')
    assert_equal(1, lines.length)
    assert(/The square root of 2 is 1.414/ =~ lines[0])

    out '../bin/todo todo-example.rb > out-todo'
    lines = File.readlines('out-todo').collect{ |l| l.chomp }
    assert(/The square root of 2 is 1.414/ =~ lines[-1])
    expected = [
      'TODO: Rename class Misnamed. (todo-example.rb:25)',
      'TODO: Change square_root to handle negative args. (todo-example.rb:29)',
      "TODO: This todo call happens every time the method is called. (todo-example.rb:31:in `square_root')"]
    assert_equal_arrays(expected, lines[0...-1])
  end

  def test_todo_example_2
    get_example 'todo-example-2'
    out 'ruby todo-example-2.rb > out-todo-2'
    lines = File.readlines('out-todo-2')
    assert_equal(1, lines.length)
    assert(/The square root of 2 is 1.414/ =~ lines[0])

    out '../bin/todo todo-example-2.rb > out-todo-2'
    lines = File.readlines('out-todo-2').collect{ |l| l.chomp }
    assert(/The square root of 2 is 1.414/ =~ lines[-1])
    expected = [
      'TODO: Rename class Misnamed. (todo-example-2.rb:10)',
      'TODO: Change square_root to handle negative args. (todo-example-2.rb:14)',
      "TODO: This todo call happens every time the method is called. (todo-example-2.rb:16:in `square_root')"]
    assert_equal_arrays(expected, lines[0...-1])
  end

  
end



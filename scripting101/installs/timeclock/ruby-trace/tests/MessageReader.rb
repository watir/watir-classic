require "test/unit"
require "ruby-trace/all"
require "util"


class MessageReader < TraceTestCase

  Scratch_file= 'out-message-reader-data'

  def setup
    remove(Scratch_file)
  end


  def test_empty
    File.open(Scratch_file, "w").close
    assert_equal([], Trace::MessageReader.new.from_file(Scratch_file))
  end

  def test_two_line_with_date
    start = Time.now
    conn = Trace::Connector.debugging_buffer_and_file(Scratch_file)
    conn.error(msg1 = 'message 1')
    conn.announce(msg2 = 'message 2')
    stop = Time.now
    close(conn)
    messages = Trace::MessageReader.new.from_file(Scratch_file)

    assert_equal(2, messages.length)

    assert_equal(msg1, messages[0].body)
    assert(messages[0].time >= start-1)  # the slop is because there might be
    assert(messages[0].time <= stop+1)   # fractional seconds lost in conversion
    assert_equal("./MessageReader.rb:23", messages[0].location)
    assert_equal('error', messages[0].level)
    assert_equal('', messages[0].topic)   # Note the anonymous topic.

    assert_equal(msg2, messages[1].body)
    assert(messages[1].time >= start-1)
    assert(messages[1].time <= stop+1)
    assert_equal("./MessageReader.rb:24", messages[1].location)
    assert_equal('announce', messages[1].level)
    assert_equal('', messages[1].topic)   # Note the anonymous topic.
  end

  def test_two_line_and_multiple_lines_in_message_body
    conn = Trace::Connector.debugging_buffer
    tr = conn.topic('tr')
    msg1 = ('message 1' + $/ + 'continuation' + $/ + 'again')
    tr.warning(msg1)
    tr.warning(msg2 = 'extra')
    # By using the buffer, we get messages without timestamps.
    ios = File.open(Scratch_file, "w")
    conn.destination_named('buffer').to_IO(ios)
    ios.close
    messages = Trace::MessageReader.new.from_file(Scratch_file)

    assert_equal(2, messages.length)

    assert_equal(msg1, messages[0].body)
    assert(messages[0].time == nil)
    assert_equal("./MessageReader.rb:50", messages[0].location)
    assert_equal('warning', messages[0].level)
    assert_equal('tr', messages[0].topic)

    assert_equal(msg2, messages[1].body)
    assert(messages[1].time == nil)
    assert_equal("./MessageReader.rb:51", messages[1].location)
    assert_equal('warning', messages[1].level)
    assert_equal('tr', messages[1].topic)
  end

  def test_bad_format_line_1
    ios = File.open(Scratch_file, "w")
    ios.puts('hi')
    ios.close

    err = lines("Message on line 1 is not properly formatted:", "hi")
    assert_trace_exception(err) {
      Trace::MessageReader.new.from_file(Scratch_file)
    }
  end

  def test_bad_format_line_2
    ios = File.open(Scratch_file, "w")
    ios.puts('drain-example.rb:13')
    ios.puts('hi')
    ios.close

    err = lines("Message on line 2 is not properly formatted:", "hi")
    assert_trace_exception(err) {
      Trace::MessageReader.new.from_file(Scratch_file)
    }
  end

  def test_truncated
    ios = File.open(Scratch_file, "w")
    ios.puts('drain-example.rb:13')
    ios.close

    assert_trace_exception("The final message is incomplete.") {
      Trace::MessageReader.new.from_file(Scratch_file)
    }
  end

end


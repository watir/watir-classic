require "test/unit"
require "ruby-trace/all"
require "util"


class BufferDestination < TraceTestCase

  def test_adding
    dest = Trace::BufferDestination.new("dest")

    assert_equal("dest", dest.name)

    assert_equal([], dest.messages)

    message1 = Trace::Message.new("1", "topic", "level")
    message2 = Trace::Message.new("2", "topic", "level")

    dest.accept(message1)
    assert_equal([message1], dest.messages)

    dest.accept(message2)
    assert_equal([message1, message2], dest.messages)
  end


  def test_size_change
    @conn = Trace::Connector.debugging_buffer
    dest = @conn.destination_named('buffer')
    dest.clear

    # Test that the buffer is a limited-size FIFO.
    dest.limit = 10
    expected = []
    1.upto(11) { | i |
      @conn.error_value { "i" }
      expected.push("i -> #{i}")
    }
    expected = expected[-10,10] # only last 10 should be present.
    assert_messages('buffer', expected, @conn)

    dest.limit = 10 # no change
    assert_messages('buffer', expected, @conn)
      
    dest.limit = 11 # no change
    assert_messages('buffer', expected, @conn)
      
    dest.limit = 9
    assert_messages('buffer', expected[1..10], @conn)
      
    dest.limit = 1
    last_element = "i -> 11" # just in case I  make same counting error
                             # in test as in code under test.
    assert_messages('buffer', [last_element], @conn)


    assert_trace_exception("Buffer size limit must be greater than zero.") {
      dest.limit = 0
    }
    # No change.
    assert_messages('buffer', [last_element], @conn)

    @conn.error('hi')
    assert_messages('buffer', ["hi"], @conn)

    # Check a bit of wrapping.
    @conn.error('bye')
    assert_messages('buffer', ["bye"], @conn)

    dest.limit = 2
    assert_messages('buffer', ["bye"], @conn)  # still there.
    @conn.announce('not so fast')
    assert_messages('buffer', ["bye", "not so fast"], @conn)

    @conn.announce('too late')
    assert_messages('buffer', ["not so fast", 'too late'], @conn)
  end

  def test_wrapping
    # Systematic tests of wrapping
    @conn = Trace::Connector.debugging_buffer
    dest = @conn.destination_named('buffer')
    dest.limit = 3
    
    assert_messages('buffer', %w{}, @conn)
    @conn.error('1')
    assert_messages('buffer', %w{1}, @conn)
    @conn.error('2')
    assert_messages('buffer', %w{1 2}, @conn)
    @conn.error('3')
    assert_messages('buffer', %w{1 2 3}, @conn)
    @conn.error('4')
    assert_messages('buffer', %w{2 3 4}, @conn)
    @conn.error('5')
    assert_messages('buffer', %w{3 4 5}, @conn)
    @conn.error('6')
    assert_messages('buffer', %w{4 5 6}, @conn)
    @conn.error('7')
    assert_messages('buffer', %w{5 6 7}, @conn)
    @conn.error('8')
    assert_messages('buffer', %w{6 7 8}, @conn)
    @conn.error('9')
    assert_messages('buffer', %w{7 8 9}, @conn)
    @conn.error('10')
    assert_messages('buffer', %w{8 9 10}, @conn)
  end

  def test_dump_to_IO
    @conn = Trace::Connector.debugging_buffer

    @conn.event(msg = 'this is an event')

    dumpfile="out-buffer-dump.txt"
    ios = File.open(dumpfile, "w")
    @conn.destination_named('buffer').to_IO(ios)
    ios.close
    # Without a formatter argument, to_IO uses the default formatter.
    assert_messages_in_file(dumpfile, [msg], TESTFILE_NO_TIME_FORMAT)
  end

end


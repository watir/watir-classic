require "test/unit"
require "ruby-trace/all"
require "util"


class Connector_misc < TraceTestCase

  def test_add_method_for_topic
    conn = Trace::Connector.debugging_buffer
    conn.topic('gui')
    conn.add_method_for_topic('gui')
    conn.gui.error { 'hola, dawn' }
    assert_messages('buffer', ['hola, dawn'], conn)
    assert_equal('gui', conn.destination_named('buffer').messages[0].topic)
  end

  def test_add_method_for_topic_with_bad_name
    conn = Trace::Connector.debugging_buffer

    err_msg_proc = proc { | name | 
      lines("'#{name}' is not a valid method name.",
            'To be added, topic names must match /^[a-z_]\w*$/.')
    }

    assert_trace_exception(err_msg_proc.call('to pic')) {
      conn.add_method_for_topic(conn.topic('to pic').name)
    }
    assert_trace_exception(err_msg_proc.call('Tom')) {
      conn.add_method_for_topic(conn.topic('Tom').name)
    }
    assert_trace_exception(err_msg_proc.call('Tom-foolery')) {
      conn.add_method_for_topic(conn.topic('Tom-foolery').name)
    }
    
    # These, however, are OK:
    conn.add_method_for_topic(conn.topic('t').name)
    conn.add_method_for_topic(conn.topic('_').name)
    conn.add_method_for_topic(conn.topic('_T').name)
    conn.add_method_for_topic(conn.topic('az').name)
    conn.add_method_for_topic(conn.topic('za0_9AZ').name)
  end

  def test_add_method_for_topic_with_duplicate_name
    conn = Trace::Connector.debugging_buffer

    assert_trace_exception("'clone' clashes with an existing method.") {
      conn.add_method_for_topic(conn.topic('clone').name)
    }

    # Also works for methods only defined on Topic.
    assert_trace_exception("'set_one_threshold' clashes with an existing method.") {
      conn.add_method_for_topic(conn.topic('set_one_threshold').name)
    }

    # ... and for methods only defined on Connector.
    assert_trace_exception("'topic' clashes with an existing method.") {
      conn.add_method_for_topic(conn.topic('topic').name)
    }

  end

  def test_add_method_for_topic_twice
    conn = Trace::Connector.debugging_buffer

    topic = conn.topic('gui')
    assert_equal(topic, conn.add_method_for_topic(topic.name))
    assert_equal(topic, conn.add_method_for_topic(topic.name))
  end

  def test_add_method_for_topic_without_topic
    conn = Trace::Connector.debugging_buffer

    assert_trace_exception("'no_topic' does not name a topic. Use Connector.topic first.") {
      conn.add_method_for_topic('no_topic')
    }
  end

  def test_add_method_for_topic_without_using_name
    conn = Trace::Connector.debugging_buffer

    assert_trace_exception("add_method_for_topic takes a topic name, not a topic object.") {
      topic = conn.topic('gui')
      conn.add_method_for_topic(topic)
    }
  end

  def test_drain
    # Note: tests that draining actually works is in the drain-example.rb
    # file in the examples directory.
    
    conn = Trace::Connector.debugging_buffer_and_file

    err = lines("Destination 'buffe' is unknown.",
                "   Try one of these:",
                "   buffer, file")
    assert_trace_exception(err) {
      conn.drain('buffe', 'file')
    }

    err = lines("Destination 'filee' is unknown.",
                "   Try one of these:",
                "   buffer, file")
    assert_trace_exception(err) {
      conn.drain('buffer', 'filee')
    }

    err = lines("Destination 'file' does not know how to drain.",
                "It should be a BufferDestination or something similar.")
    assert_trace_exception(err) {
      conn.drain('file', 'buffer')
    }
  end

  def test_standard_connectors_with_blocks
    # Check that the standard connectors can take blocks to augment
    # their normal behavior. Check that the things in the blocks actually
    # have an effect.
    # debugging_buffer is tested via two_test_destinations in util.

    conn = Trace::Connector.debugging_buffer_and_file {
      add_destination(Trace::BufferDestination.new('buffer2'))
      theme_and_destination_use_default('debugging', 'buffer2', 'verbose')
    }
    topic = conn.topic('topic', 'destination'=>'buffer2')
    topic.verbose(mess1 = 'i am verbose')
    topic.error(mess2 = 'i am error')
    assert_messages('buffer2', [mess1, mess2], conn)
    assert_messages('buffer', [], conn) # empty because buffer is not a
                                        # destination for this topic.
    
    conn = Trace::Connector.debugging_printer {
      add_destination(Trace::BufferDestination.new('buffer2'), :default)
      theme_and_destination_use_default('debugging', 'buffer2', 'event')

      add_theme('new', %w{so soso})
      theme_and_destination_use_default('new', 'buffer2', 'soso')
      theme_and_destination_use_default('new', 'printer', 'so')
    }
    topic = conn.topic('new topic', 'theme'=>'new')
    topic.soso(mess = 'I am another message')
    assert_messages('buffer2', [mess], conn)
  end
    
end


require "test/unit"
require "ruby-trace/all"
require "util"

class Environment_uses < TraceTestCase

  # See Environment.rb for tests of the Environment class. This checks
  # how the TRACEENV is used by connectors and topics.
  def test_default_behavior
    # Applies to the anonymous topic attached to the connector object.
    ENV["TRACEENV"]='--threshold=verbose'
    conn = Trace::Connector.debugging_buffer
    conn.verbose(def_message = 'verbose on default topic')
    expected = [def_message]
    assert_messages('buffer', expected, conn)

    # Also applied when new topic is created.
    ENV["TRACEENV"]= 'topic-buffer-default=debug;t--default=none'
    conn = Trace::Connector.debugging_buffer
    topic=conn.topic('topic')
    topic.debug(message = 'seen')
    topic.verbose('not seen')
    assert_messages('buffer', [message], conn)

    t=conn.topic('t')
    t.error 'not seen, even though error messages normally are.'
    assert_messages('buffer', [message], conn)

    # '--default' applies ONLY to the anonymous topic.
    ENV["TRACEENV"]= '--default=verbose;--threshold=debug'
    conn = Trace::Connector.debugging_buffer
    topic=conn.topic('topic')
    topic.debug('not seen')
    topic.verbose('also not seen')
    assert_messages('buffer', [], conn)

    # An explicit value overrides the default.
    ENV["TRACEENV"]= '--default=verbose;--threshold=debug'
    conn = Trace::Connector.debugging_buffer
    conn.debug(message = 'debug me!')
    conn.verbose('not seen')
    assert_messages('buffer', [message], conn)
  end

  def test_unadorned_behavior
    # TRACEENV doesn't apply to non-default connector.
    ENV['TRACENEV']='--default=verbose'
    conn = Trace::Connecter.new {
      debugging_theme_and_buffer
    }
    conn.verbose 'I am not seen'
    assert_messages('buffer', [], conn)
  end

  def test_global_settings
    ENV["TRACEENV"]= 'global-debugging-buffer-default=verbose'
    conn = Trace::Connector.debugging_buffer
    conn.verbose(msg = 'seen')
    assert_messages('buffer', [msg], conn)

    # global settings overridden by topic default.
    ENV["TRACEENV"]= 'global-debugging-buffer-default=verbose topic-buffer-default=error'
    conn = Trace::Connector.debugging_buffer
    topic = conn.topic('topic')
    conn.verbose(msg1 = 'seen')
    topic.verbose('not seen')
    topic.warning('not seen')
    topic.error(msg2 = 'also seen')
    assert_messages('buffer', [msg1, msg2], conn)

    # global settings also overriden by topic explicit setting.
    ENV["TRACEENV"]= 'global-debugging-buffer-default=verbose topic-buffer-threshold=error'
    conn = Trace::Connector.debugging_buffer
    topic = conn.topic('topic')
    conn.verbose(msg1 = 'seen')
    topic.verbose('not seen')
    topic.warning('not seen')
    topic.error(msg2 = 'also seen')
    assert_messages('buffer', [msg1, msg2], conn)
  end

  def test_global_settings_mismatch
    ENV["TRACEENV"]= 'global-debugging-buffe-default=verbose global-debuggin-buffer-default=verbose'
    conn = Trace::Connector.debugging_buffer
    topic = conn.topic('topic')
    conn.verbose('not seen')
    topic.verbose('not seen')
    assert_messages('buffer', [], conn)
  end

end


require 'test/unit'
require "ruby-trace/start/global-buffer"
require "util"


class Connector_as_topic < GlobalTestCase

  # $trace is a topic, just like any other.
  def test_topic
    
    expected = %w{error warning announce event}
    send_all($trace)
    assert_messages("buffer", expected)

    $trace.set_default_threshold("buffer", "none")
    send_all($trace)
    assert_messages("buffer", expected)

    $trace.set_threshold("buffer", "verbose")
    send_all($trace)
    expected += %w{error warning announce event debug verbose}
    assert_messages("buffer", expected)

    $trace.set_threshold("buffer", "default")
    send_all($trace)
    assert_messages('buffer', expected)

    # Doesn't interfere with other topics.
    tr = $trace.topic("new topic")
    send_all(tr)
    expected += %w{error warning announce event}
    assert_messages('buffer', expected)

    # $trace is a normal topic.
    $trace.topic_named("").set_threshold("buffer", "error")
    send_all($trace)
    expected += %w{error}
    assert_messages('buffer', expected)
  end

end



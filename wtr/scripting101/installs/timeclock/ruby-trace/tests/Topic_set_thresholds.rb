require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"


class Topic_set_thresholds < GlobalTestCase

  def setup
    super
    $trace=two_test_destinations
    @initial=$trace.topic("initial")
    @initial_alternate_messages = %w{error warning announce}
    @initial_buffer_messages = %w{error warning announce event}

    @all_messages = %w{error warning announce event debug verbose}

    # These represent the running total of what we expect to have been
    # delivered to the respective destinations.
    @alternate_messages = []
    @buffer_messages = []
  end

  # Check each destination against the messages expected to have been sent. 
  def assert_all_destinations
    assert_messages("alternate", @alternate_messages)
    assert_messages("buffer", @buffer_messages)
  end

  def send_and_assert(tr)
    send_all(tr)
    assert_all_destinations
  end

  def unknown_level_string(bad_level, topic)
    [ "'#{bad_level}' is not a level for topic '#{topic}'.",
      "   Try one of these:",
      "   default, none, error, warning, announce, event, debug, verbose"
      ].join($/)
  end

  def unknown_destination_string(bad_dest, topic)
    [ "'#{bad_dest}' is not a destination for topic '#{topic}'.",
      "   Try one of these:",
      "   buffer, alternate"
      ].join($/)
  end


       ##### The initial state of this test configuration #####

  def test_initial
    @alternate_messages = @initial_alternate_messages
    @buffer_messages = @initial_buffer_messages
    send_and_assert @initial
  end


      ##### Changing individual thresholds: set_threshold #####

  def test_threshold_change
    tr = $trace.topic("threshold_change")

    # Move the threshold up
    tr.set_threshold("alternate", "warning")
    tr.set_threshold("buffer", "announce")

    @alternate_messages = %w{error warning}
    @buffer_messages = %w{error warning announce}
    send_and_assert(tr)

    # only this topic's threshold has changed.
    @alternate_messages += @initial_alternate_messages
    @buffer_messages += @initial_buffer_messages
    send_and_assert(@initial)

    # drop the threshold to the bottom
    tr.set_threshold("alternate", "verbose")
    tr.set_threshold("buffer", "verbose")

    @alternate_messages += @all_messages
    @buffer_messages += @all_messages
    send_and_assert(tr)
  
    # Check again that only this topic's threshold has changed.
    @alternate_messages += @initial_alternate_messages
    @buffer_messages += @initial_buffer_messages
    send_and_assert(@initial)
  end

  def test_threshold_to_default
    tr = $trace.topic("default")

    # Set to non-default values
    tr.set_threshold("alternate", "warning")
    tr.set_threshold("buffer", "debug")
    @alternate_messages = %w{error warning}
    @buffer_messages = %w{error warning announce event debug}
    send_and_assert(tr)

    # Change alternate to default
    tr.set_threshold("alternate", "default")
    @alternate_messages += @initial_alternate_messages
    @buffer_messages += @buffer_messages
    send_and_assert(tr)

    # Now change buffer to default
    tr.set_threshold("buffer", "default")
    @alternate_messages += @initial_alternate_messages
    @buffer_messages += @initial_buffer_messages
    send_and_assert(tr)

    # Do it again, just to be sure.
    tr.set_threshold("buffer", "default")
    @alternate_messages += @initial_alternate_messages
    @buffer_messages += @initial_buffer_messages
    send_and_assert(tr)
  end

  def test_threshold_to_none
    tr = $trace.topic("turn off")
    tr.set_threshold("alternate", "none").set_threshold("buffer", "none")
    @alternate_messages = []
    @buffer_messages = []
    send_and_assert(tr)
  end

  def test_set_threshold_to_unknown_threshold
    topic = "unknown threshold"
    bad_level = 'erro'
    tr = $trace.topic(topic)
    assert_trace_exception(unknown_level_string(bad_level, topic)) {
      tr.set_threshold("alternate", bad_level)
    }
    test_initial		# Should have had no effect.
  end

  def test_set_threshold_to_unknown_destination
    topic = "unknown_destination"
    bad_dest = 'fil'
    tr = $trace.topic(topic)
    assert_trace_exception(unknown_destination_string(bad_dest, topic)) {
      tr.set_threshold(bad_dest, "error")
    }
    test_initial		# Should have had no effect.
  end



   ##### Changing a topic's default threshold: set_default_threshold #####

  def test_set_default_threshold
    tr = $trace.topic("change_default_level")

    # Change alternate default. Because topic is tracking the default,
    # change has immediate effect.
    tr.set_default_threshold("alternate", "error")
    @alternate_messages = %w{error}
    @buffer_messages = @initial_buffer_messages
    send_and_assert(tr)

    # Set buffer to a specific level. Change default. Expect no effect
    tr.set_threshold("buffer", "verbose")
    @alternate_messages += %w{error}
    @buffer_messages += @all_messages
    send_and_assert(tr)		# Make sure set_threshold had effect

    tr.set_default_threshold("buffer", "error")
    @alternate_messages += %w{error}
    @buffer_messages += @all_messages
    send_and_assert(tr) 

    # Now make buffer track default. Default should have effect.
    tr.set_threshold("buffer", "default")
    @alternate_messages += %w{error}
    @buffer_messages += %w{error}
    send_and_assert(tr)

    # Make sure you can set the default threshold to "none"
    tr.set_default_threshold("alternate", "none")
    tr.set_default_threshold("buffer", "none")
    # expected messages are unchanged.
    send_and_assert(tr)
  end
    
  def test_set_default_threshold_unknown_level
    topic = "unknown threshold"
    bad_level = "erro"
    tr = $trace.topic(topic)

    assert_trace_exception(unknown_level_string(bad_level, topic)) {
      tr.set_default_threshold("alternate", bad_level)
    }
    test_initial		# Should have had no effect.
  end
    
  def test_set_default_threshold_to_unknown_destination
    topic = "unknown_destination"
    bad_dest = 'fil'
    tr = $trace.topic(topic)

    assert_trace_exception(unknown_destination_string(bad_dest, topic)) {
      tr.set_default_threshold(bad_dest, "error")
    }
    test_initial		# Should have had no effect.
  end

  def test_set_default_threshold_to_custom_level
    $trace.add_theme('custom', %w{custom_default custom_lower}, :default)
    $trace.theme_and_destination_use_default('custom', 'buffer', 'custom_default')
    tr = $trace.topic('custom', 'destination'=>'buffer')

    string = 'hi'
    tr.custom_default_value { "string" }
    tr.custom_lower 'hi'
    assert_messages('buffer', ['string -> "hi"'])

    tr.set_threshold('buffer', 'custom_lower')
    tr.custom_default { "string" } # non-evaluating form
    tr.custom_lower_value { "string[1].chr" }

    assert_messages('buffer',
                    ['string -> "hi"', 'string', 'string[1].chr -> "i"'])
  end
    
end

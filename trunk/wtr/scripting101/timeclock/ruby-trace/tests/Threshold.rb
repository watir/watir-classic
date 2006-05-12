require "test/unit"
require "ruby-trace/all"
require "util"

# The threshold that applies to a given topic is controlled by four levels: 
#    an explicitly-set topic threshold -
#       topic.set_threshold('dest', "error")
#    a topic default -
#       topic.set_default_threshold('dest', "warning"))
#    a Connector default -
#       $trace.theme_and_destination_use_default('theme', 'dest', "verbose")
# Except for the Connector default, the levels do not originally exist.
# They are listed above in descending order of precedence.
# All of this is controlled by the Threshold class and its interaction with
# Topic. These tests check that the precedence order truly works.
# They moreover test that changes to the currently dominant level
# have effect. (So it's not just creating it that makes a difference.)

class Threshold < TraceTestCase

  def setup
    super
    @conn=Trace::Connector.debugging_buffer
    @conn.add_theme("threshold",
                     %w{ten nine eight seven six five four three two one},
                     :default)
    @conn.theme_and_destination_use_default('threshold', 'buffer', 'ten')
    @tr=@conn.topic('threshold')
  end

  # Utilities at end, to avoid clutter.
  
  def test_precedence

    # CONNECTOR DEFAULT
    # Default behavior.
    assert_open_at 'ten'
    assert_closed_at 'nine'

    # Change current dominant threshold - check changed behavior.
    assert_lowered_to('nine') { 
      @conn.theme_and_destination_use_default('threshold', 'buffer', 'nine')
    }
    
    # TOPIC DEFAULT
    # Add a more-dominant threshold.
    assert_lowered_to('eight') {
      @tr.set_default_threshold("buffer", "eight")
    }

    # Change current dominant threshold - check changed behavior.
    assert_lowered_to('seven') {
      @tr.set_default_threshold("buffer", 'seven')
    }
    # Change previously dominant threshold - no effect.
    @conn.theme_and_destination_use_default('threshold', 'buffer', 'ten')
    assert_open_at 'seven'

    # EXPLICIT TOPIC THRESHOLD
    # Add a more-dominant threshold.
    assert_lowered_to('four') {
      @tr.set_threshold("buffer", 'four')
    }
    # Change current dominant threshold - check changed behavior.
    assert_lowered_to('three') {
      @tr.set_threshold("buffer", 'three')
    }
    # Change previously dominant threshold - no effect.
    @tr.set_default_threshold("buffer", 'nine')
    assert_open_at('three')

    # Now peel off dominant thresholds and show that the 
    # previously-set values are now uncovered.
    @tr.set_threshold("buffer", 'default')
    assert_open_at('nine')
    assert_closed_at('eight')

    @tr.set_default_threshold("buffer", 'default')
    assert_open_at('ten')
    assert_closed_at('nine')
  end

  def test_middle_forgotten
    # Forgetting about the topic default makes no difference if the
    # topic has got an explicit level.
    @tr.set_default_threshold('buffer', 'four')
    assert_open_at('four') 
    @tr.set_threshold('buffer', 'one')
    assert_open_at('one')
    
    @tr.set_default_threshold('buffer', 'default')
    assert_open_at('one')  # It had no effect

    @tr.set_threshold('buffer', 'default') # connector default has effect
    assert_closed_at('one')
    assert_closed_at('four') # wiped-out topic default
    assert_open_at('ten')
  end
  
  def assert_open_at(level)
    messages = send_to_empty(level)
    assert(messages.length == 1)
    assert_equal(level, messages[0].body)
  end

  def assert_closed_at(level)
    messages = send_to_empty(level)
    assert(messages.length == 0)
  end

  def send_to_empty(level) # and return the messages in 'buffer'
    @conn.destination_named('buffer').clear
    # Note that sends the name of the level to that level. 
    @tr.send(level, level)
    return @conn.destination_named('buffer').messages
  end

  def assert_lowered_to(level)
    assert_closed_at level
    yield
    assert_open_at level
  end

end

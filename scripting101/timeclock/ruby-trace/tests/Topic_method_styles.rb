require "test/unit"
require "ruby-trace/start/method-buffer"
require "util"

class Topic_method_styles < MethodTestCase

  # There are three styles of sending messages:
  # - with strings
  # - with blocks
  # - with self-documenting blocks 
  # They are illustrated here, as well as used elsewhere in the tests. 

  def test_message_styles
    self.trace = Trace::Connector.debugging_buffer

    i = 102359
    
    trace.error "happy birthday, #{i}"
    trace.warning { "happy birthday, #{i}" }
    trace.announce_value { "i - i" }

    # As a special feature, no argument just prints "Reached here."
    
    trace.announce

    assert_messages('buffer', 
                    ["happy birthday, #{i}",
                      "happy birthday, #{i}",
                      "i - i -> 0",
                      "Reached here."],
                    trace)

    # Also check that the message levels are correct.
    messages = trace.destination_named('buffer').messages
    assert_equal("error", messages[0].level)
    assert_equal("warning", messages[1].level)
    assert_equal("announce", messages[2].level)
    assert_equal("announce", messages[3].level)
  end
end


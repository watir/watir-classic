require "test/unit"
require "ruby-trace/start/method-buffer"
require "util"

# Test the Object#trace version of accessing the default Connector.
# The $trace method is tested all over the place.
class Method_global < MethodTestCase

  def invoke
    trace.error('hi')
    assert_messages('buffer', ['hi'], trace)
  end

  def test_setting
    invoke
    # You have to remember to use 'self.trace=' instead of 'trace='.
    self.trace = Trace::Connector.debugging_buffer
    invoke
  end

end

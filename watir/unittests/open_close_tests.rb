# rapidly open and close IE windows
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_OpenClose < Test::Unit::TestCase
  def setup # an extra ie window will mask the error
    # it would be a more reliable test (though ruder)
    # if we closed all ie windows
    $ie.close if $ie
  end
  def test_whether_win32ole_runtime_or_rpc_error_happens
    20.times do
      assert_nothing_raised do
        ie = Watir::IE.new
        ie.close
      end
    end
  end
  def teardown
    @ie.close if defined?(@ie)
    start_ie_with_logger
  end
end       
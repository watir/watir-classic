$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CloseAllWindows < Watir::TestCase
  
  def setup
    @browsers = []
    5.times {@browsers << Watir::Browser.new}
  end

  def test_close_all_windows
    assert @browsers.all? {|browser| browser.exists?}
    Watir::IE.close_all
    assert @browsers.all? {|browser| not browser.exists?}
  end
  
end

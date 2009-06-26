$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Browser < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "utf8.html" # could be any page really
  end 

  def test_status_returns_window_status
    browser.execute_script "window.status = 'All done!'"
    assert_equal "All done!", browser.status
  end

end



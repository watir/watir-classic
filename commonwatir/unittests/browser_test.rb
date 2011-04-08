$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Browser < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "utf8.html" # could be any page really
  end 

  def test_status_returns_window_status
    browser.execute_script "window.status = 'All done!'"
    assert_match /done/i, browser.status
  end

end

class TC_Browser_Exists < Test::Unit::TestCase
  def setup
    @browser = Watir::Browser.new
    @browser.goto self.class.html_root + "blankpage.html"
  end

  def teardown
    @browser.close if @browser.exists?
  end

  def test_exists
    assert @browser.exists?
  end

  def test_not_exists
    @browser.close
    assert_false @browser.exists?
  end
end



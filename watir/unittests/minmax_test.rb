# feature tests for minimizing and maximizing IE windows

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_MinMax< Test::Unit::TestCase
  tags :must_be_visible
  def setup
    goto_page 'pass.html'
  end
  def teardown
    browser.restore
  end
  def test_minimimum
    browser.minimize
    assert browser.minimized?
  end
  def test_maximum
    browser.maximize
    assert !browser.minimized?
  end
  def test_activate
    browser.activate
    assert browser.active?
    begin
      new_browser = Watir::IE.start($htmlRoot + 'blankpage.html')
      assert new_browser.active?
      assert !browser.active?
      browser.activate
      browser.activate   # bug in rautomation? It's in front just not activated
      assert browser.active?
    ensure
      new_browser.close
    end
  end
end


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
  end
  def test_maximum
    browser.maximize
  end
  def test_front
    assert browser.front?
    ie2 = Watir::IE.start($htmlRoot + 'blankpage.html')
    assert ie2.front?
    assert ! browser.front?
    browser.bring_to_front
    assert browser.front?
    ie2.close
  end
end


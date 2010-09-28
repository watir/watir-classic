# Rely upon Watir's tests for Waiter, just test accessibility

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_WaitUntil < Test::Unit::TestCase
  def setup
    goto_page("delay.html")
  end
  
  def test_divs
    assert(browser.div(:id, "output").verify_contains("no"))
    assert_nothing_raised do
      browser.wait_until { browser.div(:id, "output").verify_contains("yes") }
    end
    assert(browser.div(:id, "output").verify_contains("yes"))
  end
end

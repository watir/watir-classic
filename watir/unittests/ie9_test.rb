$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_IE9 < Test::Unit::TestCase
  include Watir::Exception

  def setup
    goto_page "ie_9.html"
  end

  def test_clicking_button
    browser.button(:value, "Click Me").click
    assert(browser.text.include?("PASS") )
  end

end
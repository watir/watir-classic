# feature tests for Visibility 

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Visibility < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "visibility.html"
  end
  
  # will check for divs which are visible on the screen (not inline style)
  def test_initial_divs
    assert_equal(true, browser.div(:id, "div1").visible?)
    assert_equal(false, browser.div(:id, "div2").visible?)
    assert_equal(false, browser.div(:id, "div3").visible?)
  end

  # will check for textfields which are visible on the screen (not inline style)
  # if any textfields style displays true, it checks if all the parents are true else displays false
  def test_initial_text_fields
    assert_equal(true, browser.text_field(:id, "lgnId1").visible?)
    assert_equal(false, browser.text_field(:id, "lgnId2").visible?)
    assert_equal(false, browser.text_field(:id, "lgnId3").visible?)
  end

  # Check if the second div becomes visible (inline visibility test)
  def test_make_visible_second_div
    browser.link(:id, "div2vis").click
    #wait_until { browser.div(:id, "div2").visible? }
    assert_equal(true, browser.div(:id, "div2").visible? )
    assert_equal(true, browser.text_field(:id, "lgnId2").visible? )  
  end

  # Check if the second div becomes visible (inline Display block test)
  def test_make_display_third_div
    browser.link(:id, "div3blk").click
    #wait_until { browser.div(:id, "div3").visible? }
    assert_equal(true, browser.div(:id, "div3").visible? )
    assert_equal(true, browser.text_field(:id, "lgnId3").visible? )  
  end
  
  def test_hidden_element
    assert_equal(false, browser.hidden(:id, 'hidden-type').visible? )
  end
end

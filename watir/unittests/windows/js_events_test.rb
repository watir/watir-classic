# feature tests for JavaScript events
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_JSEvents < Test::Unit::TestCase
  def setup
    goto_page "javascriptevents.html"
  end
  
  def test_Button_disabled
    assert_false( $ie.button(:caption, "Button 1").enabled?) 
  end
  
  def test_Button_Enabled
    $ie.text_field(:name, "entertext").fire_event("onkeyup")
    assert($ie.button(:caption, "Button 1").enabled?)   
  end
  
  def test_Button_click
    # Firing event to make button enabled
    $ie.text_field(:name, "entertext").fire_event("onKeyUp")
    # Clicking the button
    $ie.button(:caption, "Button 1").click
    assert($ie.text.include?("PASS") )
  end
  
  #onMouseOver tests
  #window status
  
  def test_no_status_bar_exception
    $ie.link(:text, "New Window No Status Bar").click
    status_bar_test_win = nil
    # Note: this test will fail if the Google toolbar popup blocker is turned on
    assert_nothing_raised { status_bar_test_win = Watir::IE.attach(:title, "Pass Page") }
    assert_raises( Watir::NoStatusBarException ) { status_bar_test_win.status }
    status_bar_test_win.close
    status_bar_test_win = nil
  end
  
  def test_page_nostatus
    assert_equal("Done", $ie.status) 
  end
  
  def test_set_page_status
    $ie.link(:text, "Check the Status").fire_event("onMouseOver")
    assert_equal("It worked", $ie.status) 
  end
  
  def test_clear_page_status
    $ie.link(:text, "Clear the Status").fire_event("onMouseOver")
    assert_equal("Done", $ie.status) 
  end
end

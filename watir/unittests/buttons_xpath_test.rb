# feature tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Buttons_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "buttons1.html"
  end
  
  def test_properties
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").id   }  
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").name   }  
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").disabled   }  
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").type   }  
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").value   }  
    
    assert_equal("b1"  , browser.button(:xpath, "//input[@id='b2']/").name  ) 
    assert_equal("b2"  , browser.button(:xpath, "//input[@id='b2']/").id  ) 
    assert_equal("button"  , browser.button(:xpath, "//input[@id='b2']/").type  ) 
  end
  
  def test_button_using_default
    # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@value='Missing Caption']/").click   }  
    
    browser.button(:xpath, "//input[@value='Click Me']/").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_Button_click_only
    browser.button(:xpath, "//input[@value='Click Me']/").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_button_click
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@value='Missing Caption']/").click   }  
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@id='MissingId']/").click   }  
    
    assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   browser.button(:xpath, "//input[@value='Disabled Button']/").click   }  
    
    browser.button(:xpath, "//input[@value='Click Me']/").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_Button_Exists
    assert(browser.button(:xpath, "//input[@value='Click Me']/").exists?)   
    assert(browser.button(:xpath, "//input[@value='Submit']/").exists?)   
    assert(browser.button(:xpath, "//input[@name='b1']/").exists?)   
    assert(browser.button(:xpath, "//input[@id='b2']/").exists?)   
    
    assert_false(browser.button(:xpath, "//input[@value='Missing Caption']/").exists?)   
    assert_false(browser.button(:xpath, "//input[@name='missingname']/").exists?)   
    assert_false(browser.button(:xpath, "//input[@id='missingid']/").exists?)   
  end
  
  def test_Button_Enabled
    assert(browser.button(:xpath, "//input[@value='Click Me']/").enabled?)   
    assert_false(browser.button(:xpath, "//input[@value='Disabled Button']/").enabled?)   
    assert_false(browser.button(:xpath, "//input[@name='b4']/").enabled?)   
    assert_false(browser.button(:xpath, "//input[@id='b5']/").enabled?)   
    
    assert_raises(UnknownObjectException) {   browser.button(:xpath, "//input[@name='noName']/").enabled?  }  
  end
end


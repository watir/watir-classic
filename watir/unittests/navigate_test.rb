# feature tests for navigation
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'cgi'

class TC_Navigate < Test::Unit::TestCase
  tags :fails_on_firefox
  def test_navigation
    browser.clear_url_list
    goto_page 'buttons1.html'
    assert_equal(($htmlRoot + 'buttons1.html').gsub(" ","%20").downcase, browser.url.downcase)  

    assert_equal(1, browser.url_list.length)
    assert_equal(browser.url, browser.url_list[0])
    
    goto_page 'checkboxes1.html'
    assert_equal("Test page for Check Boxes", browser.title) 

    assert_equal(2, browser.url_list.length)
    assert_equal(browser.url, browser.url_list[1])
    
    browser.clear_url_list
    assert_equal(0, browser.url_list.length )
    
    browser.back
    assert_equal("Test page for buttons", browser.title)   
    
    browser.forward
    assert_equal("Test page for Check Boxes", browser.title)   
    browser.checkbox(:name, "box1").set
    assert(browser.checkbox(:name, "box1").isSet?)   
    
    browser.refresh
    # Not sure how we test this. Text fields and checkboxes dont get reset if you click the browser refresh button
    # -- this could be tested with the add-row page.
  end
end

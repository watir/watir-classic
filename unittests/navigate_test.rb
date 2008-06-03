# feature tests for navigation
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'cgi'

class TC_Navigate < Test::Unit::TestCase
  
  def test_navigation
    $ie.clear_url_list
    goto_page 'buttons1.html'
    url = $ie.url.downcase
    url = CGI::unescape url 
    assert_equal(($htmlRoot + 'buttons1.html').downcase, url)  # sometimes we get capital drive letters 

    assert_equal(1, $ie.url_list.length)
    assert_equal(url, $ie.url_list[0].downcase)
    
    goto_page 'checkboxes1.html'
    url = $ie.url.downcase   
    url = CGI::unescape url 
    assert_equal("Test page for Check Boxes", $ie.title) 

    assert_equal(2, $ie.url_list.length)
    assert_equal(url, $ie.url_list[1].downcase)
    
    $ie.clear_url_list
    assert_equal(0, $ie.url_list.length )
    
    $ie.back
    assert_equal("Test page for buttons", $ie.title)   
    
    $ie.forward
    assert_equal("Test page for Check Boxes", $ie.title)   
    $ie.checkbox(:name, "box1").set
    assert($ie.checkbox(:name, "box1").isSet?)   
    
    $ie.refresh
    # Not sure how we test this. Text fields and checkboxes dont get reset if you click the browser refresh button
    # -- this could be tested with the add-row page.
  end
end

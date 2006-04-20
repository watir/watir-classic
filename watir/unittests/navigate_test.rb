# feature tests for navigation
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Navigate < Test::Unit::TestCase
  include Watir
  
  def goto_page(a)
    $ie.goto($htmlRoot + a)
  end
  
  def test_navigation
    $ie.clear_url_list
    goto_page('buttons1.html')
    url = $ie.url.downcase.gsub('///' , '//') # no idea why this happens - we get 3 / after file:
    assert_equal(url.downcase, ($htmlRoot + 'buttons1.html' ).downcase )  # sometimes we get capital drive letters 
    
    assert_equal(1, $ie.url_list.length)
    assert_equal(url, $ie.url_list[0].gsub('\\', '/').downcase)
    
    goto_page('checkboxes1.html')
    url = $ie.url.downcase.gsub('///' , '//')   # no idea why this happens - we get 3 / after file:
    
    assert_equal($ie.title, "Test page for Check Boxes") 
    assert_equal(2, $ie.url_list.length)
    assert_equal(url, $ie.url_list[1].gsub('\\', '/').downcase)
    
    $ie.clear_url_list
    assert_equal(0, $ie.url_list.length )
    
    $ie.back
    assert_equal($ie.title , "Test page for buttons")   
    
    $ie.forward
    assert_equal($ie.title , "Test page for Check Boxes")   
    
    $ie.checkBox(:name, "box1").set
    assert($ie.checkBox(:name, "box1").isSet?)   
    
    $ie.refresh
    # Not sure how we test this. Text fields and checkboxes dont get reset if you click the browser refresh button
  end
end

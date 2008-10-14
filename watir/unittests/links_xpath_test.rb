# feature tests for Links
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Links_XPath < Test::Unit::TestCase
  
  def setup
    goto_page "links1.html"
  end
  
  def test_link_exists
    assert($ie.link(:xpath, "//a[contains(.,'test1')]/").exists?)
    assert($ie.link(:xpath, "//a[contains(., /TEST/i)]/").exists?)   
    assert_false($ie.link(:xpath, "//a[contains(.,'missing')]/").exists?)
    
    assert_false($ie.link(:xpath, "//a[@url='alsomissing.html']/").exists?)
    
    assert($ie.link(:xpath, "//a[@id='link_id']/").exists?)
    assert_false($ie.link(:xpath, "//a[@id='alsomissing']/").exists?)
    
    assert($ie.link(:xpath, "//a[@name='link_name']/").exists?)
    assert_false($ie.link(:xpath, "//a[@name='alsomissing']/").exists?)
    assert($ie.link(:xpath, "//a[@title='link_title']/").exists?)
  end
  
  def test_link_click
    $ie.link(:xpath, "//a[contains(.,'test1')]/").click
    assert($ie.text.include?("Links2-Pass"))
  end
  
  def test_link_with_text_call
    $ie.link(:xpath, "//a[text()='test1']").click
    assert($ie.text.include?("Links2-Pass"))
  end
  
end


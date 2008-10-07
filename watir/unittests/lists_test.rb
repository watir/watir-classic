$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
  
class Lists_Tests < Watir::TestCase
  
  def setup
    goto_page 'lists.html'
  end        

  def test_list_items_exist
    assert(browser.li(:id, 'list1').exists?)
    assert(browser.li(:id, 'list2').exists?)
    assert(browser.li(:id, 'list3').exists?)    
    assert(browser.li(:id, 'ordered1').exists?)    
    assert_equal('Coffee', browser.li(:index, 1).text)
  end

  def test_list_item_exists_by_name
    assert(browser.li(:name, 'x1').exists?)
    assert ! (browser.li(:name, 'maptest02').exists?)
  end  
  
  def test_li_length
    assert_equal(6, browser.lis.length)
  end
  
  def test_multiple_attributes
    assert_equal('Phil', browser.li(:id => 'ordered1', :name => 'x1').text)
  end

end 


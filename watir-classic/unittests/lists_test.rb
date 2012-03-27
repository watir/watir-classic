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
    assert_equal('Coffee', browser.li(:index, 0).text)
  end

  def test_li_length
    assert_equal(6, browser.lis.length)
  end
  
end 


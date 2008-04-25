$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
  
class Lists_Tests < Watir::TestCase
  
  def setup
    $ie.goto($htmlRoot + 'lists.html')
  end        

  def test_list_items_exist
    assert($ie.li(:id, 'list1').exists?)
    assert($ie.li(:id, 'list2').exists?)
    assert($ie.li(:id, 'list3').exists?)    
    assert($ie.li(:id, 'ordered1').exists?)    
    assert_equal('Coffee', $ie.li(:index, 1).text)
  end

  def test_list_item_exists_by_name
    assert($ie.li(:name, 'l1').exists?)
    assert ! ($ie.li(:name, 'maptest02').exists?)
  end  
  
  def test_li_length
    assert_equal(6, $ie.lis.length)
  end

end 


# feature tests for relative navigation/specification

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Relative < Test::Unit::TestCase
  
  def setup
    $ie.goto($htmlRoot + "depot_store.html")
    @headline = $ie.h3(:text, 'Pragmatic Version Control')
  end
  
  def test_parent
    catalog_entry = @headline.parent
    link = catalog_entry.link(:class, 'addtocart')
    assert_equal 'http://localhost:3000/store/add_to_cart/12', link.href  
    assert_nothing_raised{link.click}
  end
  
  def test_parent_page_container
    catalog_entry = @headline.parent
    assert_not_nil catalog_entry.page_container
  end
  
  def test_before_and_after
    link = $ie.link(:class => 'addtocart', :index => 2)
    assert_equal 'http://localhost:3000/store/add_to_cart/12', link.href  
    assert(link.after?(@headline))
    assert(@headline.before?(link))
    assert !(link.before? @headline)
    assert !(@headline.after? link)
    assert !(link.after? link)
  end   
  
  def test_find_after
    link = $ie.link(:class => 'addtocart', :after? => @headline)
    assert_equal 'http://localhost:3000/store/add_to_cart/12', link.href  
  end
    
end
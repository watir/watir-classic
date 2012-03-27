# feature tests for relative navigation/specification

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Relative < Test::Unit::TestCase
  
  def setup
    goto_page "depot_store.html"
    @headline = browser.h3(:text, 'Pragmatic Version Control')
  end
    
  tag_method :test_parent, :fails_on_firefox
  def test_parent
    catalog_entry = @headline.parent
    link = catalog_entry.link(:class, 'addtocart')
    assert_equal 'http://localhost:3000/store/add_to_cart/12', link.href  
    assert_nothing_raised{link.click}
  end
  
  tag_method :test_parent_page_container, :fails_on_firefox
  def test_parent_page_container
    catalog_entry = @headline.parent
    assert_not_nil catalog_entry.page_container
  end
    
end

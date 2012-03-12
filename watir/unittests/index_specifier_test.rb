$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_BaseIndex < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "multiple_specifiers.html"
  end

  def test_default_index
    assert "one", browser.table.row.cell.class_name
  end

  def test_zero_based_indexing
    assert "one", browser.button(:index => 0).class_name
    assert "two", browser.button(:index => 1).class_name    

    Watir::IE.zero_based_indexing = false

    assert "one", browser.button(:index => 1).class_name
    assert "two", browser.button(:index => 2).class_name    

    Watir::IE.zero_based_indexing = true

    assert "one", browser.button(:index => 0).class_name
    assert "two", browser.button(:index => 1).class_name    
  end

end


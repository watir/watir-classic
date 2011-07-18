$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_BaseIndex < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "multiple_specifiers.html"
  end

  def test_default_index
    assert "one", browser.table.row.cell.class_name
    assert "testcell", browser.table.row.cell.name
  end

  
end


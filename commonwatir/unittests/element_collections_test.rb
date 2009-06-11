$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_ElementCollections < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "definition_lists.html"
  end 

  def test_first
    assert_equal "experience", browser.dls.first.title
    assert_equal "industry",   browser.dts.first.class_name
  end
  
  def test_last
    assert_equal 'noop', browser.dls.last.id
    assert_equal 'noop', browser.dds.last.class_name
  end
end



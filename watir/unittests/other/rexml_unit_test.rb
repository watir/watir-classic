require 'test/unit'
require "rexml/document"

class RexmlTest < Test::Unit::TestCase
  def setup
    file = File.open( "xpath_bug.xml" )
    @doc = REXML::Document.new file
  end
  def fixture xpath
    matches = []
    @doc.elements.each(xpath) do |element|
      matches << element                  
      assert_equal('Add', element.text)    
      assert_equal('ButtonText', element.attributes['class'])
    end
    assert_equal(1, matches.length)
  end  
  def test_text
    fixture "//div[text()='Add' and @class='ButtonText']"
  end
  def test_contains
    fixture "//div[contains(.,'Add') and @class='ButtonText']"
  end
end
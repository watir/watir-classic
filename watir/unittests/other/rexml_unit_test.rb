require 'test/unit'
require 'nokogiri'

class XPathTest < Test::Unit::TestCase
  def setup
    file = File.open( "xpath_bug.xml" )
    @doc = Nokogiri::HTML::Document.read_io(file, nil, nil, 2145)
  end
  def fixture xpath
    matches = []
    
    @doc.xpath(xpath).each() do |node|
    	matches << node
    	assert_equal('Add', node.text)
    	assert_equal('ButtonText', node['class'])
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


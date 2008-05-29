# feature tests for Tables
# revision: $Revision: 1076 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Nbsp_Xpath < Test::Unit::TestCase
  
  def setup
    use_page "xpath_nbsp.html"
  end
  
  def test_nbsp
  	div = $ie.element_by_xpath("//div")
  	assert(div.innerText, "Hello world")
  end
end
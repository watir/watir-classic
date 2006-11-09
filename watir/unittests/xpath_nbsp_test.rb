# feature tests for Tables
# revision: $Revision: 1076 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Tables < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "xpath_nbsp.html")
  end
  
  def test_nbsp
	div = $ie.element_by_xpath("//div")
	assert(div.innerText, "Hello world")
  end
end
# defect reproduction
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Divs_XPath2 < Test::Unit::TestCase
  def setup
    $ie.goto($htmlRoot + "list_matters.html")
  end
  def test_div
    ie = Watir::IE.attach(:title, /List Matters/)
    # Note: this test fails, probably because of bad html to xml translation.
    # However... the same xpath expression finds the right object in Selenium!
    assert_equal('Add', ie.div(:xpath, "//div[text()='Add' and @class='ButtonText']").text)
  end
end
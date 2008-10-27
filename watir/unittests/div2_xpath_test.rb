# defect reproduction
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Divs_XPath2 < Test::Unit::TestCase
  def setup
    goto_page "list_matters.html"
  end
  def test_div_with_text
    # Note: this test fails, probably because of bad html to xml translation.
    # However... the same xpath expression finds the right object in Selenium!
    assert_equal('Add', browser.div(:xpath, "//div[text()='Add' and @class='ButtonText']").text)
  end
    def test_div_with_contains
    # Note: this test fails, probably because of bad html to xml translation.
    # However... the same xpath expression finds the right object in Selenium!
    assert_equal('Add', browser.div(:xpath, "//div[contains(.,'Add') and @class='ButtonText']").text)
  end
  
end
# feature tests for Javascript redirect
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Redirect < Test::Unit::TestCase
    
  def setup
    goto_page("redirect.html")
  end
  
  def goto_multiple_redirect
    goto_page("redirect1.html")
  end

  tag_method :test_single_redirect, :fails_on_ie
  def test_single_redirect
    assert_raises(UnknownObjectException) {browser.div(:id , "div77").click }
    assert_raises(UnknownObjectException) {browser.div(:title , "div77").click }
    
    assert(browser.text_field(:name, "text1").verify_contains("0") )  
    browser.div(:id , "div3").click
    assert(browser.text_field(:name, "text1").verify_contains("1") )  
    browser.div(:id , "div4").click
    assert(browser.text_field(:name, "text1").verify_contains("0") )  
  end
  
  tag_method :test_multiple_redirect, :fails_on_ie
  def test_multiple_redirect
    goto_multiple_redirect()
    assert_raises(UnknownObjectException) {browser.div(:id , "div77").click }
    assert_raises(UnknownObjectException) {browser.div(:title , "div77").click }
    
    assert(browser.text_field(:name, "text1").verify_contains("0") )  
    browser.div(:id , "div3").click
    assert(browser.text_field(:name, "text1").verify_contains("1") )  
    browser.div(:id , "div4").click
    assert(browser.text_field(:name, "text1").verify_contains("0") )  
  end
end

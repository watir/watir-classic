# feature tests for TextArea Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_TextArea_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "textArea.html"
  end
  
  def test_textarea_field_exists
    #test for existance of 4 text area
    assert(browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@name='txtMultiLine2']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@name='txtMultiLine3']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@name='txtReadOnly']/").exists?)
    
    assert(browser.text_field(:xpath , "//textarea[@id='txtMultiLine1']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@id='txtMultiLine2']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@id='txtMultiLine3']/").exists?)
    assert(browser.text_field(:xpath , "//textarea[@id='txtReadOnly']/").exists?)
    #test for missing 
    assert_false(browser.text_field(:xpath , "//textarea[@name='missing']/").exists?)   
    assert_false(browser.text_field(:xpath , "//textarea[@name='txtMultiLine4']/").exists?)
  end
  
  def xtest_textarea_to_s
    # bug reported by Zeljko Filipin
    # assert_nothing_raised { browser.text_field(:xpath , "//textarea[@id='txtMultiLine3']/").to_s  }
    # The above assertion fails. No property or method called maxlength
  end
  
  def test_textarea_field
    # test for read only method
    assert_false(browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").readonly? )  
    assert(browser.text_field(:xpath , "//textarea[@name='txtReadOnly']/").readonly?)
    
    # test for enabled? method
    assert_false(browser.text_field(:xpath , "//textarea[@name='txtDisabled']/").enabled? )  
    assert(browser.text_field(:xpath , "//textarea[@id='txtMultiLine1']/").enabled? )  
    
    
    t1 = browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/")
    assert(t1.verify_contains("Hello World") )  
    assert(t1.verify_contains(/el/) )  
    t2 = browser.text_field(:xpath , "//textarea[@name='txtMultiLine2']/")
    assert(t2.verify_contains(/IE/))
    assert_raises(UnknownObjectException) {   browser.text_field(:xpath , "//textarea[@name='NoName']/").verify_contains("No field to get a value of") }  
    assert_raises(UnknownObjectException) {   browser.text_field(:xpath , "//textarea[@id='noID']/").verify_contains("No field to get a value of") }  
    
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='txtNone']/").append("Some Text") }  
    
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@id='txtReadOnly']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='txtDisabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='missing_field']/").append("Some Text") }  
    
    browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").append(" Some Text")
    assert_equal(  "Hello World Some Text" , browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").value)  
    
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@id='txtReadOnly']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='txtDisabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='missing_field']/").append("Some Text") }  
    
    browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").set("watir IE Controller")
    assert_equal(  "watir IE Controller" , browser.text_field(:xpath , "//textarea[@name='txtMultiLine1']/").value )  
    
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@id='txtReadOnly']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='txtDisabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//textarea[@name='missing_field']/").append("Some Text") }  
    
    browser.text_field(:xpath , "//textarea[@name='txtMultiLine2']/").clear
    assert_equal(  "" , browser.text_field(:xpath , "//textarea[@name='txtMultiLine2']/").value )  
  end
  
end

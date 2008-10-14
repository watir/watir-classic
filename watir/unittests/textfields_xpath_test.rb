# feature tests for Text Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Fields_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "textfields1.html"
  end
  
  def test_text_field_exists
    assert($ie.text_field(:xpath , "//input[@name='text1']/").exists?)   
    assert_false($ie.text_field(:xpath , "//input[@name='missing']/").exists?)   
    
    assert($ie.text_field(:xpath , "//input[@id='text2']/").exists?)   
    assert_false($ie.text_field(:xpath , "//input[@id='alsomissing']/").exists?)   
    
    #assert($ie.text_field(:xpath , "//input[@beforeText='This Text After']/").exists? )
    #assert($ie.text_field(:xpath , "//input[@afterText='This Text Before']/").exists? )
  end
  
  def test_text_field_dragContentsTo
    $ie.text_field(:xpath , "//input[@name='text1']/").dragContentsTo(:xpath , "//input[@id='text2']/")
    assert_equal($ie.text_field(:xpath , "//input[@name='text1']/").value, "" ) 
    assert_equal($ie.text_field(:xpath , "//input[@id='text2']/").value, "goodbye allHello World" ) 
  end
  
  def test_text_field_VerifyContents
    assert($ie.text_field(:xpath , "//input[@name='text1']/").verify_contains("Hello World") )  
    assert($ie.text_field(:xpath , "//input[@name='text1']/").verify_contains(/Hello\sW/ ) )  
    assert_false($ie.text_field(:xpath , "//input[@name='text1']/").verify_contains("Ruby") )  
    assert_false($ie.text_field(:xpath , "//input[@name='text1']/").verify_contains(/R/) )  
    assert_raises(UnknownObjectException) {   $ie.text_field(:xpath , "//input[@name='NoName']/").verify_contains("No field to get a value of") }  
    
    assert($ie.text_field(:xpath , "//input[@id='text2']/").verify_contains("goodbye all") )  
    assert_raises(UnknownObjectException) {   $ie.text_field(:xpath , "//input[@id='noID']/").verify_contains("No field to get a value of") }  
  end
  
  def test_text_field_enabled
    assert_false($ie.text_field(:xpath , "//input[@name='disabled']/").enabled? )  
    assert($ie.text_field(:xpath , "//input[@name='text1']/").enabled? )  
    assert($ie.text_field(:xpath , "//input[@id='text2']/").enabled? )  
  end
  
  def test_text_field_readOnly
    assert_false($ie.text_field(:xpath , "//input[@name='disabled']/").readonly? )  
    assert($ie.text_field(:xpath , "//input[@name='readOnly']/").readonly? )  
    assert($ie.text_field(:xpath , "//input[@id='readOnly2']/").readonly? )  
  end
  
  def test_text_field_value
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='missing_field']/").append("Some Text") }  
    assert_equal(  "Hello World" , $ie.text_field(:xpath , "//input[@name='text1']/").value )  
  end
  
  def build_to_s_regex(lhs, rhs)
    Regexp.new("^#{lhs}: +#{rhs}$")
  end
  
  def test_text_field_Append
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@id='readOnly2']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='disabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='missing_field']/").append("Some Text") }  
    
    $ie.text_field(:xpath , "//input[@name='text1']/").append(" Some Text")
    assert_equal(  "Hello World Some Text" , $ie.text_field(:xpath , "//input[@name='text1']/").value )  
  end
  
  
  def test_text_field_Clear
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@id='readOnly2']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='disabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='missing_field']/").append("Some Text") }  
    
    $ie.text_field(:xpath , "//input[@name='text1']/").clear
    assert_equal(  "" , $ie.text_field(:xpath , "//input[@name='text1']/").value )  
  end
  
  def test_text_field_Set
    assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@id='readOnly2']/").append("Some Text") }  
    assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='disabled']/").append("Some Text") }  
    assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:xpath , "//input[@name='missing_field']/").append("Some Text") }  
    
    $ie.text_field(:xpath , "//input[@name='text1']/").set("watir IE Controller")
    assert_equal(  "watir IE Controller" , $ie.text_field(:xpath , "//input[@name='text1']/").value )  
  end
  
  def test_JS_Events
    $ie.text_field(:xpath , "//input[@name='events_tester']/").set('p')
    
    # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
    assert_equal( "keypresskeydownkeypresskeyup" , $ie.text_field(:xpath , "//textarea[@name='events_text']/").value.gsub("\r\n" , "")  )
    $ie.button(:value , "Clear Events Box").click
    $ie.text_field(:xpath , "//input[@name='events_tester']/").set('ab')
    
    # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
    assert_equal( "keypresskeydownkeypresskeyupkeydownkeypresskeyup" , $ie.text_field(:xpath , "//textarea[@name='events_text']/").value.gsub("\r\n" , "") )
  end
  
  def test_password
    $ie.text_field(:xpath , "//input[@name='password1']/").set("secret")
    assert( 'secret' , $ie.text_field(:xpath , "//input[@name='password1']/").value )
    
    $ie.text_field(:xpath , "//input[@id='password1']/").set("top_secret")
    assert( 'top_secret' , $ie.text_field(:xpath , "//input[@id='password1']/").value )
  end
  
end

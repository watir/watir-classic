# feature tests for Divs, Spans and P's
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Divs_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "div.html"
  end
  
  def test_divs
    assert_raises(UnknownObjectException) {$ie.div(:xpath , "//div[@id='div77']/").click }
    assert_raises(UnknownObjectException) {$ie.div(:xpath , "//div[@title='div77']/").click }
    
    assert($ie.text_field(:xpath, "//input[@name='text1']/").verify_contains("0") )  
    $ie.div(:xpath , "//div[@id='div3']/").click
    assert($ie.text_field(:xpath, "//input[@name='text1']/").verify_contains("1") )  
    $ie.div(:xpath , "//div[@id='div4']/").click
    assert($ie.text_field(:xpath, "//input[@name='text1']/").verify_contains("0") )  
  end
  
  def test_div_properties
    assert_raises(UnknownObjectException) {$ie.div(:xpath , "//div[@id='div77']/").text }
    assert_raises(UnknownObjectException) {$ie.div(:xpath , "//div[@title='div77']/").text }
    
    assert_equal("This div has an onClick that increments text1", 
    $ie.div(:xpath , "//div[@id='div3']/").text.strip )
    assert_equal("This text is in a div with an id of div1 and title of test1",   
    $ie.div(:xpath , "//div[@title='Test1']/").text.strip )
    
    assert_raises(UnknownObjectException) {$ie.div(:xpath , "//div[@id='div77']/").class_name }
    assert_equal("blueText" ,   $ie.div(:xpath , "//div[@id='div2']/").class_name )
    assert_equal("" ,   $ie.div(:xpath , "//div[@id='div1']/").class_name )
  end
  
  def test_objects_in_div
    assert($ie.div(:xpath , "//div[@id='buttons1']/").button(:index,1).exists? )
    assert_false($ie.div(:xpath , "//div[@id='buttons1']/").button(:index,3).exists? )
    assert($ie.div(:xpath , "//div[@id='buttons1']/").button(:name,'b1').exists? )
    
    assert($ie.div(:xpath , "//div[@id='buttons2']/").button(:index,1).exists? )
    assert($ie.div(:xpath , "//div[@id='buttons2']/").button(:index,2).exists? )
    assert_false($ie.div(:xpath , "//div[@id='buttons1']/").button(:index,3).exists? )
    
    $ie.div(:xpath , "//div[@id='buttons1']/").button(:index,1).click
    
    assert_equal( 'button1' ,   $ie.div(:xpath , "//div[@id='text_fields1']/").text_field(:index,1).value)
    
    assert_equal( 3 , $ie.div(:xpath , "//div[@id='text_fields1']/").text_fields.length )
  end
  
  def test_span_properties
    assert_raises(UnknownObjectException) {$ie.span(:xpath , "//span[@id='span77']/").text }
    assert_raises(UnknownObjectException) {$ie.span(:xpath , "//span[@title='span77']/").text }
    
    assert_equal("This span has an onClick that increments text2" ,   $ie.span(:xpath , "//span[@id='span3']/").text.strip )
    assert_equal("This text is in a span with an id of span1 and title of test2" ,   $ie.span(:xpath , "//span[@title='Test2']/").text.strip )
    
    assert_raises(UnknownObjectException) {$ie.span(:xpath , "//span[@id='span77']/").class_name }
    assert_equal("blueText" ,   $ie.span(:xpath , "//span[@id='span2']/").class_name )
    assert_equal("" ,   $ie.span(:xpath , "//span[@id='span1']/").class_name )
  end
  
  def test_objects_in_span
    assert($ie.span(:xpath , "//span[@id='buttons1']/").button(:index,1).exists? )
    assert_false($ie.span(:xpath , "//span[@id='buttons1']/").button(:index,3).exists? )
    assert($ie.span(:xpath , "//span[@id='buttons1']/").button(:name,'b1').exists? )
    
    assert($ie.span(:xpath , "//span[@id='buttons2']/").button(:index,1).exists? )
    assert($ie.span(:xpath , "//span[@id='buttons2']/").button(:index,2).exists? )
    assert_false($ie.span(:xpath , "//span[@id='buttons1']/").button(:index,3).exists? )
    
    $ie.span(:xpath , "//span[@id='buttons1']/").button(:index,1).click
    
    assert_equal( 'button1' ,   $ie.span(:xpath , "//span[@id='text_fields1']/").text_field(:index,1).value)
    
    assert_equal( 3 , $ie.span(:xpath , "//span[@id='text_fields1']/").text_fields.length )
  end
  
  def test_p
    assert($ie.p(:xpath , "//p[@id='number1']/").exists?)
    assert($ie.p(:xpath , "//p[@title='test_3']/").exists?)
    
    assert_false($ie.p(:xpath , "//p[@id='missing']/").exists?)
    assert_false($ie.p(:xpath , "//p[@title='test_55']/").exists?)
    
    assert_raises( UnknownObjectException) {$ie.p(:xpath , "//p[@id='missing']/").class_name }
    assert_raises( UnknownObjectException) {$ie.p(:xpath , "//p[@id='missing']/").text }
    assert_raises( UnknownObjectException) {$ie.p(:xpath , "//p[@id='missing']/").title }
    assert_raises( UnknownObjectException) {$ie.p(:xpath , "//p[@id='missing']/").to_s }
    assert_raises( UnknownObjectException) {$ie.p(:xpath , "//p[@id='missing']/").disabled }        
  end
end

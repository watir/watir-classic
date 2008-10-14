# feature tests for Check Boxes
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CheckBox_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "checkboxes1.html"
  end
  
  def test_checkbox_properties
    assert_raises(UnknownObjectException) {   $ie.checkbox(:xpath , "//input[@name='noName']/").id   }  
    assert_raises(UnknownObjectException) {   $ie.checkbox(:xpath , "//input[@name='noName']/").name   }  
    assert_raises(UnknownObjectException) {   $ie.checkbox(:xpath , "//input[@name='noName']/").disabled   }  
    assert_raises(UnknownObjectException) {   $ie.checkbox(:xpath , "//input[@name='noName']/").type   }  
    assert_raises(UnknownObjectException) {   $ie.checkbox(:xpath , "//input[@name='noName']/").value   }  
    
    assert_equal("1" , $ie.checkbox(:xpath , "//input[@name='box4']/").value )
    assert_equal("3" , $ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").value )
    assert_equal("checkbox" , $ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").type )
    assert_equal(false , $ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").disabled )
    assert_equal("" , $ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").id )
    
    assert_equal("box4-value5" , $ie.checkbox(:xpath , "//input[@name='box4' and @value='5']/").title)
    assert_equal("" , $ie.checkbox(:xpath , "//input[@name='box4' and @value='4']/").title)
  end
  
  def test_CheckBox_Exists
    assert($ie.checkbox(:xpath , "//input[@name='box4' and @value='1']/").exists?)   
    assert_false($ie.checkbox(:xpath , "//input[@name='box4' and @value='22']/").exists?)   
  end
  
  def test_checkbox_Enabled
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@name='noName']/").enabled? }  
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@id='noName']/").enabled? }  
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@name='box4' and @value='6']/").enabled? }  
    
    assert($ie.checkbox(:xpath , "//input[@name='box1']/").enabled?)   
    assert_false($ie.checkbox(:xpath , "//input[@name='box2']/").enabled?)   
    
    assert($ie.checkbox(:xpath , "//input[@name='box4' and @value='4']/").enabled?)   
    assert_false($ie.checkbox(:xpath , "//input[@name='box4' and @value='5']/").enabled?)   
  end
  
  def test_checkbox_isSet
    assert_raises(UnknownObjectException ) { $ie.checkbox(:xpath , "//input[@name='noName']/").isSet? }  
    
    assert_false($ie.checkbox(:xpath , "//input[@name='box1']/").isSet?)   
    assert_false($ie.checkbox(:xpath , "//input[@name='box2']/").isSet?)   
    assert($ie.checkbox(:xpath , "//input[@name='box3']/").isSet?)   
    
    assert_false($ie.checkbox(:xpath , "//input[@name='box4' and @value='2']/").isSet?)   
    assert($ie.checkbox(:xpath , "//input[@name='box4' and @value='1']/").isSet?)   
  end
  
  def test_checkbox_clear
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@name='noName']/").clear }  
    $ie.checkbox(:xpath , "//input[@name='box1']/").clear
    assert_false($ie.checkbox(:xpath , "//input[@name='box1']/").isSet?)   
    
    assert_raises(ObjectDisabledException) { $ie.checkbox(:xpath , "//input[@name='box2']/").clear } 
    assert_false($ie.checkbox(:xpath , "//input[@name='box2']/").isSet?)   
    
    $ie.checkbox(:xpath , "//input[@name='box3']/").clear
    assert_false($ie.checkbox(:xpath , "//input[@name='box3']/").isSet?)   
    
    $ie.checkbox(:xpath , "//input[@name='box4' and @value='1']/").clear
    assert_false($ie.checkbox(:xpath , "//input[@name='box4' and @value='1']/").isSet?)   
  end
  
  def test_checkbox_getState
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@name='noName']/").getState }  
    assert_equal( false , $ie.checkbox(:xpath , "//input[@name='box1']/").getState )   
    assert_equal( true , $ie.checkbox(:xpath , "//input[@name='box3']/").getState)   
    
    # checkboxes that have the same name but different values
    assert_equal( false , $ie.checkbox(:xpath , "//input[@name='box4' and @value='2']/").getState )   
    assert_equal( true , $ie.checkbox(:xpath , "//input[@name='box4' and @value='1']/").getState)   
  end
  
  def test_checkbox_set
    assert_raises(UnknownObjectException) { $ie.checkbox(:xpath , "//input[@name='noName']/").set }  
    $ie.checkbox(:xpath , "//input[@name='box1']/").set
    assert($ie.checkbox(:xpath , "//input[@name='box1']/").isSet?)   
    
    assert_raises(ObjectDisabledException) { $ie.checkbox(:xpath , "//input[@name='box2']/").set }  
    
    $ie.checkbox(:xpath , "//input[@name='box3']/").set
    assert($ie.checkbox(:xpath , "//input[@name='box3']/").isSet?)   
    
    # checkboxes that have the same name but different values
    $ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").set
    assert($ie.checkbox(:xpath , "//input[@name='box4' and @value='3']/").isSet?)   
    
    # test set using the optinal true/false
    # assumes the checkbox is already checked
    $ie.checkbox(:xpath , "//input[@name='box1']/").set( false )
    assert_false($ie.checkbox(:xpath , "//input[@name='box1']/").isSet?)   
    
    $ie.checkbox(:xpath , "//input[@name='box1']/").set( true )
    assert($ie.checkbox(:xpath , "//input[@name='box1']/").isSet?)   
    
  end
end

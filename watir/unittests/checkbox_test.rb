# feature tests for Check Boxes

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_CheckBox < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "checkboxes1.html"
  end

  def test_checkbox_exceptions
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").id }  
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").name }  
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").disabled }  
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").type }  
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").value }  
  end
  
  def test_checkbox_properties_with_index
    assert_equal("box1", browser.checkbox(:index, 0).name ) 
    assert_equal("", browser.checkbox(:index, 0).id ) 
    assert_equal("checkbox", browser.checkbox(:index, 0).type ) 
    assert_equal("on", browser.checkbox(:index, 0).value ) 
    assert_equal(false, browser.checkbox(:index, 0).disabled ) 
  end
  def test_checkbox_properties
    assert_equal("check_box_style", browser.checkbox(:name, "box1").class_name) 
    assert_equal("", browser.checkbox(:name, "box2").class_name) 
    
    assert_equal("1", browser.checkbox(:name, "box4").value )
    assert_equal("3", browser.checkbox(:name => "box4", :value => 3).value )
    assert(browser.checkbox(:name, "box6").exists?)    
    assert_equal("checkbox", browser.checkbox(:name => "box4", :value => 3).type )
    assert_equal("checkbox", browser.checkbox(:name => "box6", :value => 'Milk').type )
    assert_equal(false, browser.checkbox(:name => "box4", :value => 3).disabled )
    assert_equal("", browser.checkbox(:name => "box4", :value => 3).id )
    
    assert_equal("box4-value5", browser.checkbox(:name => "box4", :value => 5).title)
    assert_equal("", browser.checkbox(:name => "box4", :value => 4).title)
  end
  
  def test_onClick
    assert_false(browser.button(:value, "foo").enabled?)
    browser.checkbox(:name, "box5").set
    assert(browser.button(:value, "foo").enabled?)
    
    browser.checkbox(:name, "box5").clear
    assert_false(browser.button(:value, "foo").enabled?)
    
    browser.checkbox(:name, "box5").clear
    assert_false(browser.button(:value, "foo").enabled?)
  end
  
  def test_CheckBox_Exists
    assert(browser.checkbox(:name, "box1").exists?)   
    assert_false(browser.checkbox(:name, "missing").exists?)   
    
    assert(browser.checkbox(:name => "box4", :value => 1).exists?)   
    assert_false(browser.checkbox(:name => "box4", :value => 22).exists?)   

    assert(browser.checkbox(:name => "box4", :value => /[0-9]/).exists?)   
    assert_false(browser.checkbox(:name => "box4", :value => /\d\d\d/).exists?)   
  end
  
  def test_checkbox_Enabled
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").enabled? }  
    assert_raises(UnknownObjectException) { browser.checkbox(:id, "noName").enabled? }  
    assert_raises(UnknownObjectException) { browser.checkbox(:name => "box4", :value => 6).enabled? }  
    
    assert(browser.checkbox(:name, "box1").enabled?)   
    assert_false(browser.checkbox(:name, "box2").enabled?)   
    
    assert(browser.checkbox(:name => "box4", :value => 4).enabled?)   
    assert_false(browser.checkbox(:name =>"box4", :value => 5 ).enabled?)   
  end
  
  def test_checkbox_isSet
    assert_raises(UnknownObjectException ) { browser.checkbox(:name, "noName").isSet? }  
    
    assert_false(browser.checkbox(:name, "box1").isSet?)   
    assert_false(browser.checkbox(:name, "box2").isSet?)   
    assert(browser.checkbox(:name, "box3").isSet?)   
    
    assert_false(browser.checkbox(:name => "box4", :value => 2 ).isSet?)   
    assert(browser.checkbox(:name => "box4", :value => 1 ).isSet?)  

    assert_false(browser.checkbox(:name => 'box6', :value => 'Milk').isSet?)     
  end
  
  def test_checkbox_clear
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").clear }  
    browser.checkbox(:name, "box1").clear
    assert_false(browser.checkbox(:name, "box1").isSet?)   
    
    assert_raises(ObjectDisabledException) { browser.checkbox(:name, "box2").clear } 
    assert_false(browser.checkbox(:name, "box2").isSet?)   
    
    browser.checkbox(:name, "box3").clear
    assert_false(browser.checkbox(:name, "box3").isSet?)   
    
    browser.checkbox(:name => "box4", :value => 1).clear
    assert_false(browser.checkbox(:name => "box4", :value => 1).isSet?)   

    browser.checkbox(:name => "box6", :value => 'Tea').clear
    assert_false(browser.checkbox(:name => "box6", :value => 'Tea').isSet?)   
  end
  
  def test_checkbox_getState
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").getState }  
    assert_equal( false, browser.checkbox(:name, "box1").getState )   
    assert_equal( true, browser.checkbox(:name, "box3").getState)   
    
    # checkboxes that have the same name but different values
    assert_equal( false, browser.checkbox(:name => "box4", :value => 2).getState )   
    assert_equal( true, browser.checkbox(:name => "box4", :value => 1).getState)   
  end
  
  def test_checkbox_set
    assert_raises(UnknownObjectException) { browser.checkbox(:name, "noName").set }  
    browser.checkbox(:name, "box1").set
    assert(browser.checkbox(:name, "box1").isSet?)   
    
    assert_raises(ObjectDisabledException) { browser.checkbox(:name, "box2").set }  
    
    browser.checkbox(:name, "box3").set
    assert(browser.checkbox(:name, "box3").isSet?)   
    
    # checkboxes that have the same name but different values
    browser.checkbox(:name => "box4", :value => 3).set
    assert(browser.checkbox(:name => "box4", :value => 3).isSet?)   
    
    # test set using the optinal true/false
    # assumes the checkbox is already checked
    browser.checkbox(:name, "box1").set( false )
    assert_false(browser.checkbox(:name, "box1").isSet?)   
    
    browser.checkbox(:name, "box1").set( true )
    assert(browser.checkbox(:name, "box1").isSet?)   

    browser.checkbox(:name => "box6", :value => 'Tea').set( false )
    assert_false(browser.checkbox(:name => "box6", :value => 'Tea').isSet?)   
    
    browser.checkbox(:name => "box6", :value => 'Tea').set( true )
    assert(browser.checkbox(:name => "box6", :value => 'Tea').isSet?)
  end
  
  def test_checkboxes_access
    assert_equal("box1" , browser.checkboxes[1].name )
  end
  
  def test_checkbox_iterator
    assert_equal(13, browser.checkboxes.length)
    index = 0
    browser.checkboxes.each do |c|
      # puts "#{index}: #{c.name}"
      assert_equal( browser.checkbox(:index, index).name , c.name )
      assert_equal( browser.checkbox(:index, index).id, c.id )
      assert_equal( browser.checkbox(:index, index).value, c.value )
      index += 1
    end
    assert_equal(index, browser.checkboxes.length)
  end

  # bug 217
  tag_method :test_checkbox_access_by_ole_object, :fails_on_firefox
  def test_checkbox_access_by_ole_object
    ole = browser.checkboxes[1].locate
    browser.checkbox(:ole_object, ole).flash
  end
  
end

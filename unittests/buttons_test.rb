# feature tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Buttons < Test::Unit::TestCase
  include Watir::Exception
  def setup
    use_page "buttons1.html"
  end
  
  def aaatest_Button_to_s
    # i think the tests for to_s should be dropped. The output is not in a nice format to be tested, and the
    # individual properties are tested in the test_properties method
    
    b4 = ['name              b4',
        'type              button',
        'id                b5',
        'value             Disabled Button',
        'disabled          true']
    b1 = ['name              b1',
        'type              button',
        'id                b2',
        'value             Click Me',
        'disabled          false']
    
    assert_equal(b4, browser.button(:name, "b4").to_s)
    assert_equal(b1, browser.button(:caption, "Click Me").to_s)
    assert_equal(b1, browser.button(:index, 1).to_s)
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").to_s   }  
  end
  
  def test_properties
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").id   }  
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").name   }  
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").disabled   }  
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").type   }  
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").value   }  
    
    assert_equal("b1"  , browser.button(:index, 1).name ) 
    assert_equal("b2"  , browser.button(:index, 1).id ) 
    assert_equal("button"  , browser.button(:index, 1).type  ) 
    assert_equal("Click Me"  , browser.button(:index, 1).value  ) 
    assert_equal(false  , browser.button(:index, 1).disabled  ) 
    assert_equal("italic_button"  , browser.button(:name, "b1").class_name  ) 
    assert_equal(""  , browser.button(:name , "b4").class_name  ) 
        
    assert_equal("b1"  , browser.button(:id, "b2").name  ) 
    assert_equal("b2"  , browser.button(:id, "b2").id  ) 
    assert_equal("button"  , browser.button(:id, "b2").type  ) 
    
    assert_equal("b4"  , browser.button(:index, 2).name  ) 
    assert_equal("b5"  , browser.button(:index, 2).id  ) 
    assert_equal("button"  , browser.button(:index, 2).type  ) 
    assert_equal("Disabled Button"  , browser.button(:index, 2).value  ) 
    assert_equal(true  , browser.button(:index, 2).disabled  ) 
    
    assert_equal( "" , browser.button(:index, 2).title )
    assert_equal( "this is button1" , browser.button(:index, 1).title )
  end
  
  def test_button_using_default
    # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button( "Missing Caption").click   }  
    
    browser.button("Click Me").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_Button_click_only
    browser.button(:caption, "Click Me").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_button_click
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:caption, "Missing Caption").click   }  
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:id, "missingID").click   }  
    assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   browser.button(:caption, "Disabled Button").click   }  
    
    browser.button(:caption, "Click Me").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_Button_Exists
    assert(browser.button(:caption, "Click Me").exists?)   
    assert(browser.button(:caption, "Submit").exists?)   
    assert(browser.button(:name, "b1").exists?)   
    assert(browser.button(:id, "b2").exists?)   
    assert(browser.button(:caption, /sub/i).exists?)   
    
    assert(!browser.button(:caption, "missingcaption").exists?)   
    assert(!browser.button(:name, "missingname").exists?)   
    assert(!browser.button(:id, "missingid").exists?)   
    assert(!browser.button(:caption, /missing/i).exists?)   
  end
  
  def test_Button_Enabled
    assert($ie.button(:caption, "Click Me").enabled?)   
    assert(!browser.button(:caption, "Disabled Button").enabled?)   
    assert(!browser.button(:name, "b4").enabled?)   
    assert(!browser.button(:id, "b5").enabled?)   
    
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   browser.button(:name, "noName").enabled?  }  
  end
  
  def test_frame
    use_page "frame_buttons.html"
    assert(browser.frame("buttonFrame").button(:caption, "Click Me").enabled?)   
    assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { browser.button(:caption, "Disabled Button").enabled?}  
  end
  
end


# feature tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Buttons_XPath < Test::Unit::TestCase
    include Watir
    
    def setup
        $ie.goto($htmlRoot + "buttons1.html")
    end
   
    # Currently, Frames are not supported in XPath. 
    #def goto_frames_page()
    #    $ie.goto($htmlRoot + "frame_buttons.html")
    #end
    
    def aatest_Spinner
        s = Spinner.new
        i = 0
        while(i < 100)
            sleep 0.05
            print s.next
            i+=1
        end
        s = nil
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
        
        assert_equal(b4, $ie.button(:xpath, "//input[@name='b4']/").to_s)
        assert_equal(b1, $ie.button(:xpath, "//input[@value='Click Me']/").to_s)
        #assert_equal(b1, $ie.button(:index, 1).to_s)
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").to_s   }  
    end
    
    def test_properties
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").id   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").name   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").disabled   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").type   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").value   }  
        
        assert_equal("b1"  , $ie.button(:xpath, "//input[@id='b2']/").name  ) 
        assert_equal("b2"  , $ie.button(:xpath, "//input[@id='b2']/").id  ) 
        assert_equal("button"  , $ie.button(:xpath, "//input[@id='b2']/").type  ) 
        
    end
    
    
    def test_button_using_default
        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@value='Missing Caption']/").click   }  
        
        $ie.button(:xpath, "//input[@value='Click Me']/").click
        assert($ie.contains_text("PASS") )
    end
    
    def test_Button_click_only
        $ie.button(:xpath, "//input[@value='Click Me']/").click
        assert($ie.contains_text("PASS") )
    end
    
    def test_button_click
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@value='Missing Caption']/").click   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@id='MissingId']/").click   }  
        
        assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@value='Disabled Button']/").click   }  
        
        $ie.button(:xpath, "//input[@value='Click Me']/").click
        assert($ie.contains_text("PASS") )
    end
    
    def test_Button_Exists
        assert($ie.button(:xpath, "//input[@value='Click Me']/").exists?)   
        assert($ie.button(:xpath, "//input[@value='Submit']/").exists?)   
        assert($ie.button(:xpath, "//input[@name='b1']/").exists?)   
        assert($ie.button(:xpath, "//input[@id='b2']/").exists?)   
        
        assert_false($ie.button(:xpath, "//input[@value='Missing Caption']/").exists?)   
        assert_false($ie.button(:xpath, "//input[@name='missingname']/").exists?)   
        assert_false($ie.button(:xpath, "//input[@id='missingid']/").exists?)   
    end
    
    def test_Button_Enabled
        assert($ie.button(:xpath, "//input[@value='Click Me']/").enabled?)   
        assert_false($ie.button(:xpath, "//input[@value='Disabled Button']/").enabled?)   
        assert_false($ie.button(:xpath, "//input[@name='b4']/").enabled?)   
        assert_false($ie.button(:xpath, "//input[@id='b5']/").enabled?)   
        
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:xpath, "//input[@name='noName']/").enabled?  }  
    end
   
    # Currently, Frames are not supported in XPath. 
    #def test_frame
    #    goto_frames_page()
        
    #    assert($ie.frame("buttonFrame").button(:caption, "Click Me").enabled?)   
    #    assert_raises(  UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { $ie.button(:caption, "Disabled Button").enabled?}  
    #end
    
end


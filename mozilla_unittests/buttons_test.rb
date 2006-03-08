# feature tests for Buttons
# revision: $Revision: 1.35 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_Buttons < Test::Unit::TestCase
    include Watir
    
    def setup
        $ie.goto($htmlRoot + "buttons1.html")
    end
    
    def goto_frames_page()
        $ie.goto($htmlRoot + "frame_buttons.html")
    end
    
    #def test_Spinner
     #   s = Spinner.new
     #   i = 0
     #   while(i < 100)
     #       sleep 0.05
     #       print s.next
    #        i+=1
    #    end
    #    s = nil
    #end
    
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
        
        assert_equal(b4, $ie.button(:name, "b4").to_s)
        assert_equal(b1, $ie.button(:caption, "Click Me").to_s)
        assert_equal(b1, $ie.button(:index, 1).to_s)
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").to_s   }  
    end
    
    def test_properties
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").id   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").name   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").disabled   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").type   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").value   }  
        
        assert_equal("b1"  , $ie.button(:index, 1).name ) 
        assert_equal("b2"  , $ie.button(:index, 1).id ) 
        assert_equal("button"  , $ie.button(:index, 1).type  ) 
        assert_equal("Click Me"  , $ie.button(:index, 1).value  ) 
        assert_equal(false  , $ie.button(:index, 1).disabled  ) 
        assert_equal("italic_button"  , $ie.button(:name, "b1").class_name  ) 
        assert_equal(""  , $ie.button(:name , "b4").class_name  ) 

        
        assert_equal("b1"  , $ie.button(:id, "b2").name  ) 
        assert_equal("b2"  , $ie.button(:id, "b2").id  ) 
        assert_equal("button"  , $ie.button(:id, "b2").type  ) 
        
        assert_equal("b4"  , $ie.button(:index, 2).name  ) 
        assert_equal("b5"  , $ie.button(:index, 2).id  ) 
        assert_equal("button"  , $ie.button(:index, 2).type  ) 
        assert_equal("Disabled Button"  , $ie.button(:index, 2).value  ) 
        assert_equal(true  , $ie.button(:index, 2).disabled  ) 
        
        assert_equal( "" , $ie.button(:index, 2).title )
        assert_equal( "this is button1" , $ie.button(:index, 1).title )
    end
    
    
    def test_button_using_default
        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button( "Missing Caption").click   }  
        
        $ie.button("Click Me").click
        assert($ie.text.include?("PASS") )
    end
    
    def test_Button_click_only
        $ie.button(:caption, "Click Me").click
        assert($ie.text.include?("PASS") )
    end
    
    def test_button_click
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:caption, "Missing Caption").click   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:id, "missingID").click   }  
        
        assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ie.button(:caption, "Disabled Button").click   }  
        
        $ie.button(:caption, "Click Me").click
        assert($ie.text.include?("PASS") )
    end
    
    def test_Button_Exists
        assert($ie.button(:caption, "Click Me").exists?)   
        assert($ie.button(:caption, "Submit").exists?)   
        assert($ie.button(:name, "b1").exists?)   
        assert($ie.button(:id, "b2").exists?)   
        assert($ie.button(:caption, /sub/i).exists?)   
        
        assert_false($ie.button(:caption, "missingcaption").exists?)   
        assert_false($ie.button(:name, "missingname").exists?)   
        assert_false($ie.button(:id, "missingid").exists?)   
        assert_false($ie.button(:caption, /missing/i).exists?)   
    end
    
    def test_Button_Enabled
        assert($ie.button(:caption, "Click Me").enabled?)   
        assert_false($ie.button(:caption, "Disabled Button").enabled?)   
        assert_false($ie.button(:name, "b4").enabled?)   
        assert_false($ie.button(:id, "b5").enabled?)   
        
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").enabled?  }  
    end
    
    #def test_frame
       # goto_frames_page()
        
        #assert($ie.frame("buttonFrame").button(:caption, "Click Me").enabled?)   
       # assert_raises(  UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { $ie.button(:caption, "Disabled Button").enabled?}  
    #end
    
end


# feature tests for Buttons of type <input type = "button">
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Buttons < Test::Unit::TestCase
    include FireWatir
    
    def setup
        $ff.goto($htmlRoot + "buttons1.html")
    end
    
    def goto_frames_page()
        $ff.goto($htmlRoot + "frame_buttons.html")
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
    
    def test_Button_to_s
        # i think the tests for to_s should be dropped. The output is not in a nice format to be tested, and the
        # individual properties are tested in the test_properties method
        
        b4 = ['name:         b4',
        'type:         button',
        'id:           b5',
        'value:        Disabled Button',
        'disabled:     true']
        b1 = ['name:         b1',
        'type:         button',
        'id:           b2',
        'value:        Click Me',
        'disabled:     false']
        
        assert_equal(b4, $ff.button(:name, "b4").to_s)
        assert_equal(b1, $ff.button(:caption, "Click Me").to_s)
        assert_equal(b1, $ff.button(:index, 1).to_s)
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").to_s   }  
    end
   
    def test_properties
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").id   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").name   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").disabled   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").type   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").value   }  
        
        assert_equal("b1"  , $ff.button(:index, 1).name ) 
        assert_equal("b2"  , $ff.button(:index, 1).id ) 
        assert_equal("button"  , $ff.button(:index, 1).type  ) 
        assert_equal("Click Me"  , $ff.button(:index, 1).value  ) 
        assert_equal(false  , $ff.button(:index, 1).disabled  ) 
        assert_equal("italic_button"  , $ff.button(:name, "b1").class_name  ) 
        assert_equal(""  , $ff.button(:name , "b4").class_name  ) 

        
        assert_equal("b1"  , $ff.button(:id, "b2").name  ) 
        assert_equal("b2"  , $ff.button(:id, "b2").id  ) 
        assert_equal("button"  , $ff.button(:id, "b2").type  ) 
        
        assert_equal("b4"  , $ff.button(:index, 2).name  ) 
        assert_equal("b5"  , $ff.button(:index, 2).id  ) 
        assert_equal("button"  , $ff.button(:index, 2).type  ) 
        assert_equal("Disabled Button"  , $ff.button(:index, 2).value  ) 
        assert_equal(true  , $ff.button(:index, 2).disabled  ) 
        
        assert_equal( "" , $ff.button(:index, 2).title )
        assert_equal( "this is button1" , $ff.button(:index, 1).title )
    end
    
    
    def test_button_using_default
        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button( "Missing Caption").click   }  
        
        $ff.button("Click Me").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_Button_click_only
        $ff.button(:caption, "Click Me").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_button_click
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:caption, "Missing Caption").click   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:id, "missingID").click   }  
        
        assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ff.button(:caption, "Disabled Button").click   }  
        
        $ff.button(:caption, "Click Me").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_Button_Exists
        assert($ff.button(:caption, "Click Me").exists?)   
        assert($ff.button(:caption, "Submit").exists?)   
        assert($ff.button(:name, "b1").exists?)   
        assert($ff.button(:id, "b2").exists?)   
        assert($ff.button(:caption, /sub/i).exists?)   
        
        assert_false($ff.button(:caption, "missingcaption").exists?)   
        assert_false($ff.button(:name, "missingname").exists?)   
        assert_false($ff.button(:id, "missingid").exists?)   
        assert_false($ff.button(:caption, /missing/i).exists?)   
    end
    
    def test_Button_Enabled
        assert($ff.button(:caption, "Click Me").enabled?)   
        assert_false($ff.button(:caption, "Disabled Button").enabled?)   
        assert_false($ff.button(:name, "b4").enabled?)   
        assert_false($ff.button(:id, "b5").enabled?)   
        
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:name, "noName").enabled?  }  
     end

     def test_button2
        assert($ff.button(:caption, "Click Me2").exists?, 'Can\'t find Button with caption "Click Me2"')   
       
        assert($ff.button(:caption, "Disabled Button2").exists?, 'Can\'t find Button with caption "Disabled Button2"') 
        assert($ff.button(:caption, "Sign In").exists?, 'Can\'t find Button with caption "Sign In"')
        
        assert_equal("b6"  , $ff.button(:id, "b7").name ) 
        assert_equal("b7"  , $ff.button(:name, "b6").id ) 
        assert_equal("Click Me2"  , $ff.button(:id, "b7").value  ) 
        assert_equal(false  , $ff.button(:id, "b7").disabled  ) 
        assert_equal("italic_button"  , $ff.button(:name, "b6").class_name  ) 
        
        assert_equal("b8"  , $ff.button(:id, "b9").name ) 
        assert_equal("b9"  , $ff.button(:name, "b8").id ) 
        assert_equal("Disabled Button2"  , $ff.button(:id, "b9").value  ) 
        assert_equal(false  , $ff.button(:id, "b9").enabled?) 
        assert_equal(""  , $ff.button(:name, "b8").class_name  ) 
        assert_equal("Sign In", $ff.button(:caption, "Sign In").value)
        
        assert($ff.button(:caption, "Click Me").enabled?, 'Button wih caption "Click Me" should be enabled')   
      
        assert_false($ff.button(:caption, "Disabled Button2").enabled?, 'Button wih caption "Disabled Button2" should be disabled')   
        
        
        assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ff.button(:caption, "Disabled Button2").click   }  
        
        $ff.button(:caption, "Click Me2").click
        assert($ff.text.include?("PASS"), 'Clicking on "Click Me2" button should\'ve taken to the "PASS" page') 

     end
    
    def test_frame
        goto_frames_page()
        f = $ff.frame("buttonFrame")
        assert(f.button(:caption, "Click Me").enabled?)   
        #assert_raises(  UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { $ff.button(:caption, "Disabled Button").enabled?}  
    end
    
    def test_buttons
	    arrButtons = $ff.buttons
	    assert_equal(7, arrButtons.length)
        #arrButtons.each do |button|
            #puts button.to_s
       #end
      assert_equal("b2", arrButtons[1].id)
      assert_equal("b5", arrButtons[2].id)
      assert_equal("Submit", arrButtons[3].value)
      assert_equal("sub3", arrButtons[4].name)
      assert_equal("b7", arrButtons[5].id)
      assert_equal("b9", arrButtons[6].id)
      assert_equal("Sign In", arrButtons[7].value)
    end

    # Tests collection class
    def test_class_buttons
      arr_buttons = $ff.buttons
      arr_buttons.each do |b|
        assert(b.instance_of?(Button),"element class should be #{Button}; got #{b.class}")
      end
      # test properties
      assert_equal("b2", arr_buttons[1].id)
      assert_equal("b1", arr_buttons[1].name) 
      assert_equal("button", arr_buttons[1].type) 
      assert_equal("Click Me", arr_buttons[1].value) 
      assert_equal(false, arr_buttons[1].disabled) 
      assert_equal("italic_button", arr_buttons[1].class_name) 
      assert_equal( "this is button1", arr_buttons[1].title)
 
      assert_equal("b5", arr_buttons[2].id)
      assert_equal("b4", arr_buttons[2].name) 
      assert_equal("button", arr_buttons[2].type) 
      assert_equal("Disabled Button", arr_buttons[2].value) 
      assert_equal(true, arr_buttons[2].disabled) 
      assert_equal( "", arr_buttons[2].title)
      assert_equal("", arr_buttons[2].class_name) 

      assert_equal("Submit", arr_buttons[3].value)
      assert_equal("sub3", arr_buttons[4].name)
      assert_equal("b7", arr_buttons[5].id)
      assert_equal("b9", arr_buttons[6].id)
      assert_equal("Sign In", arr_buttons[7].value)




    end


end


# feature tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Buttons < Test::Unit::TestCase
    include Watir

    def goto_button_page()
        $ie.goto($htmlRoot + "buttons1.html")
    end

    def goto_frames_page()
        $ie.goto($htmlRoot + "frame_buttons.html")
    end

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
        goto_button_page()

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

   
    def test_button_using_default

        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....

       goto_button_page()
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button( "Missing Caption").click   }  

       $ie.button("Click Me").click
       assert($ie.contains_text("PASS") )
    end

    def test_Button_click_only
       goto_button_page()
       $ie.button(:caption, "Click Me").click
       assert($ie.contains_text("PASS") )
    end

    def test_button_click
       goto_button_page()
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:caption, "Missing Caption").click   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:id, "missingID").click   }  

       assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ie.button(:caption, "Disabled Button").click   }  

       $ie.button(:caption, "Click Me").click
       assert($ie.contains_text("PASS") )
    end

    def test_Button_Exists
       goto_button_page()
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
       goto_button_page()
       assert($ie.button(:caption, "Click Me").enabled?)   
       assert_false($ie.button(:caption, "Disabled Button").enabled?)   
       assert_false($ie.button(:name, "b4").enabled?)   
       assert_false($ie.button(:id, "b5").enabled?)   

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").enabled?  }  

    end

    def test_frame
        goto_frames_page()

       assert($ie.frame("buttonFrame").button(:caption, "Click Me").enabled?)   
       assert_raises(  UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { $ie.button(:caption, "Disabled Button").enabled?}  

        

    end


end



# tests for Buttons
# revision: $Revision$

require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'

$myDir = File.dirname(__FILE__)

class TC_Buttons < Test::Unit::TestCase

    def gotoButtonPage()
        $ie.goto("file://#{$myDir}/html/buttons1.html")
    end

    def gotoFramesPage()
        $ie.goto("file://#{$myDir}/html/frame_buttons.html")
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

    def test_Button_to_s
        gotoButtonPage()

        puts "Testing to_s   "
        line = "-"*30
        puts line 
        puts $ie.button(:name, "b4").to_s
        puts line

        puts $ie.button(:caption, "Click Me").to_s
        puts line

        puts $ie.button(:index, 1).to_s

        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").to_s   }  

    end

   
    def test_Button_UsingDefault

        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....

       gotoButtonPage()
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button( "Missing Caption").click   }  

       $ie.button("Click Me").click
       assert($ie.pageContainsText("PASS") )


    end

    def test_Button_click_only
       gotoButtonPage()
       $ie.button(:caption, "Click Me").click
       assert($ie.pageContainsText("PASS") )
    end

    def test_Button_click
       gotoButtonPage()
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:caption, "Missing Caption").click   }  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:id, "missingID").click   }  

       puts "failing line next..."
       assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ie.button(:caption, "Disabled Button").click   }  

       puts "Clicking the button"

       $ie.button(:caption, "Click Me").click
       assert($ie.pageContainsText("PASS") )
    end

    def test_Button_Exists
       gotoButtonPage()
       assert($ie.button(:caption, "Click Me").exists?)   
       assert($ie.button(:caption, "Submit").exists?)   
       assert($ie.button(:name, "b1").exists?)   
       assert($ie.button(:id, "b2").exists?)   

       assert_false($ie.button(:caption, "missingcaption").exists?)   
       assert_false($ie.button(:name, "missingname").exists?)   
       assert_false($ie.button(:id, "missingid").exists?)   
    end

    def test_Button_Enabled
       gotoButtonPage()
       assert($ie.button(:caption, "Click Me").enabled?)   
       assert_false($ie.button(:caption, "Disabled Button").enabled?)   
       assert_false($ie.button(:name, "b4").enabled?)   
       assert_false($ie.button(:id, "b5").enabled?)   

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.button(:name, "noName").enabled?  }  

    end

    def test_frame
        gotoFramesPage()

       assert($ie.frame("buttonFrame").button(:caption, "Click Me").enabled?)   
       assert_raises(  UnknownObjectException , "UnknownObjectException was supposed to be thrown ( no frame name supplied) " ) { $ie.button(:caption, "Disabled Button").enabled?}  

        

    end


end

$ie = IE.new

# tests for Buttons
# revision: $Revision$

require '../watir'

require 'test/unit'
require 'test/unit/ui/console/testrunner'

require 'testUnitAddons'
$myDir = File.dirname(__FILE__)

$LOAD_PATH << $myDir




class TC_Buttons < Test::Unit::TestCase


    def gotoButtonPage()
        $ie.goto("file://#{$myDir}/html/buttons1.html")
    end

    def gotoFramesPage()

    $ie.goto("file://#{$myDir}/html/frame_buttons.html")
    end


    def test_frame
        gotoFramesPage()

       $ie.showFrames

       assert_raises(UnknownFrameException, "UnknownFrameExceptionwas supposed to be thrown" ) {   $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
       assert_raises(UnknownObjectException, "UnknownObjectException supposed to be thrown" ) {   $ie.frame("buttonFrame2").button(:id, "b2").enabled?  }  

       assert($ie.frame("buttonFrame").button(:id, "b2").enabled?)   
    end


end

$ie = IE.new
# tests for Frames
# revision: $Revision$

require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'
require 'unittests/setup'

$myDir = Dir.getwd

class TC_Frames < Test::Unit::TestCase


   
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

    def test_presetFrame

        # with the preset frame functionality we are able to use the same frame for saeveral actions
        $ie.presetFrame( "buttonFrame" )
        assert_equal( "buttonFrame" , $ie.getCurrentFrame )


        assert($ie.button(:id, "b2").enabled?)
        assert_false($ie.button(:caption, "Disabled Button").enabled?)

        $ie.clearPresetFrame( )
        assert_equal( "" , $ie.getCurrentFrame )



    end

end


# feature tests for Frames
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.clearFrame
        $ie.clearPresetFrame
        $ie.goto($htmlRoot + "frame_buttons.html")
    end

    def test_frame
        $ie.showFrames
        assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
        assert_raises(UnknownObjectException) { $ie.frame("buttonFrame2").button(:id, "b2").enabled?  }  
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

class TC_NestedFrames < Test::Unit::TestCase
    include Watir
   
    def setup()
        $ie.clearFrame
        $ie.clearPresetFrame
        $ie.goto($htmlRoot + "nestedFrames.html")
    end

    def test_frame
        $ie.showFrames
        assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
        assert_raises(UnknownFrameException) { $ie.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  
        assert($ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   
        $ie.frame("nestedFrame").frame("senderFrame").textField(:index , "1" ).set("Hello")
        $ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click()
        assert($ie.frame("nestedFrame").frame("receiverFrame").textField(:name, "receiverText").verify_contains("Hello"))   
    end

end



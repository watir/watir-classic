# feature tests for Frames
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "frame_buttons.html")
    end

    def test_frame
        assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
        assert_raises(UnknownObjectException) { $ie.frame("buttonFrame2").button(:id, "b2").enabled?  }  
        assert($ie.frame("buttonFrame").button(:id, "b2").enabled?)   
        assert_false($ie.frame("buttonFrame").button(:caption, "Disabled Button").enabled?)
    end

    def test_presetFrame
        # with ruby's instance_eval, we are able to use the same frame for several actions
        results = $ie.frame("buttonFrame").instance_eval do [
            button(:id, "b2").enabled?, 
            button(:caption, "Disabled Button").enabled?
            ]
        end
        assert_equal([true, false], results)
    end

end

class TC_NestedFrames < Test::Unit::TestCase
    include Watir
   
    def setup()
        $ie.goto($htmlRoot + "nestedFrames.html")
    end

    def test_frame
        assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
        assert_raises(UnknownFrameException) { $ie.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  
        assert($ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   
        $ie.frame("nestedFrame").frame("senderFrame").textField(:index , "1" ).set("Hello")
        $ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click()
        assert($ie.frame("nestedFrame").frame("receiverFrame").textField(:name, "receiverText").verify_contains("Hello"))   
    end

end

class TC_IFrames < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "iframeTest.html")
    end

    def test_Iframe
       $ie.frame("senderFrame").textField(:name , "textToSend").set( "Hello World")
       $ie.frame("senderFrame").button(:index, 1).click
       assert( $ie.frame("receiverFrame").textField(:name , "receiverText").verify_contains("Hello World") )
    end

end   

require 'unittests/iostring'
class TC_show_frames < Test::Unit::TestCase
    include MockStdoutTestCase                
    
    def capture_and_compare(page, expected)
        $ie.goto($htmlRoot + page)
        $stdout = @mockout
        $ie.showFrames
        assert_equal(expected, @mockout)
    end
      
    def test_show_nested_frames
        capture_and_compare("nestedFrames.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 0 name: nestedFrame
frame  index: 1 name: nestedFrame2
END_OF_MESSAGE
    end

    def test_button_frames
        capture_and_compare("frame_buttons.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 0 name: buttonFrame
frame  index: 1 name: buttonFrame2
END_OF_MESSAGE
    end

    def test_iframes
        capture_and_compare("iframeTest.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 0 name: senderFrame
frame  index: 1 name: receiverFrame
END_OF_MESSAGE
    end

end




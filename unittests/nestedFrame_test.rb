# tests for nested Frames
# revision: $Revision$

require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase


   
    def gotoFramesPage()

       $ie.goto($htmlRoot + "nestedFrames.html")
    end


    def test_frame
       gotoFramesPage()

       $ie.showFrames

       assert_raises(UnknownFrameException, "UnknownFrameException was supposed to be thrown" ) {   $ie.frame("missingFrame").button(:id, "b2").enabled?  }  


       assert_raises(UnknownFrameException, "UnknownFrameException was supposed to be thrown" ) {   $ie.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  

       assert($ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   

       $ie.frame("nestedFrame").frame("senderFrame").textField(:index , "1" ).set("Hello")
       $ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click()

       assert($ie.frame("nestedFrame").frame("receiverFrame").textField(:name, "receiverText").verify_contains("Hello"))   
    end

    

end


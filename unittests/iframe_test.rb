# tests for IFrames
# revision: $Revision$

require 'unittests/setup'


class TC_IFrames < Test::Unit::TestCase


    def gotoPage()
        $ie.goto($htmlRoot + "iframeTest.html")
    end


    def test_Iframe
       gotoPage()

       $ie.frame("senderFrame").textField(:name , "textToSend").set( "Hello World")
       $ie.frame("senderFrame").button(:index, 1).click

       assert( $ie.frame("receiverFrame").textField(:name , "receiverText").verify_contains("Hello World") )

    end

   
end



# tests for Buttons
# revision: $Revision$

require '../watir'

require 'test/unit'
require 'test/unit/ui/console/testrunner'

require 'testUnitAddons'

$myDir = Dir.getwd




class TC_Buttons < Test::Unit::TestCase


    def gotoPage()
        $ie.goto("file://#{$myDir}/html/iframeTest.html")
    end


    def test_Iframe
       gotoPage()

       $ie.frame("senderFrame").textField(:name , "textToSend").set( "Hello World")
       $ie.frame("senderFrame").button(:index, 1).click

       assert( $ie.frame("receiverFrame").textField(:name , "receiverText").verify_contains("Hello World") )

    end

   
end

$ie = IE.new
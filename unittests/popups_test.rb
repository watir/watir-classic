# tests for javascript PopUps
# revision: $Revision$

$LOAD_PATH.<< File.join(File.dirname(__FILE__), '..')
require 'unittests/setup'

class TC_PopUps < Test::Unit::TestCase

    def gotoPopUpPage()
        $ie.goto("file://#{$myDir}/html/popups1.html")
    end

    def startClicker( button , waitTime = 3)

        w = WinClicker.new
        longName = $ie.dir.gsub("/" , "\\" )
        shortName = w.getShortFileName(longName)
        c = "start rubyw #{shortName }\\watir\\clickJSDialog.rb #{button } #{ waitTime} "
        puts "Starting #{c}"
        w.winsystem(c )   
        w=nil


    end


    def test_simple
        gotoPopUpPage()
        startClicker("OK" , 3)
        $ie.button("Alert").click
    end

    def test_confirm
        gotoPopUpPage()
        startClicker("OK" , 3)
        $ie.button("Confirm").click
        assert( $ie.textField(:name , "confirmtext").verify_contains("OK") )

        startClicker("Cancel" , 3)
        $ie.button("Confirm").click
        assert( $ie.textField(:name , "confirmtext").verify_contains("Cancel") )



    end


    def atest_Prompt
        gotoPopUpPage()
        startClicker("OK" , 3)
        $ie.button("Prompt").click


    end

end


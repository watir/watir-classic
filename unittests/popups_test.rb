# tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'
require 'unittests/setup'

class TC_PopUps < Test::Unit::TestCase

    def gotoPopUpPage()
        $ie.goto("file://#{$myDir}/html/popups1.html")
    end


    def test_simple
        gotoPopUpPage()
        c = "start #{$ie.dir.gsub("/" , "\\" )}\\clickJSDialog.rb OK 3"
        puts "Starting #{c}"
        w = WinClicker.new
        w.winsystem(c )   
        $ie.button("Alert").click
    end

    def test_confirm
        gotoPopUpPage()
        c = "start #{$ie.dir.gsub("/" , "\\" )}\\clickJSDialog.rb OK 3"
        puts "Starting #{c}"
        w = WinClicker.new
        w.winsystem(c )   
        $ie.button("Confirm").click
        assert( $ie.textField(:name , "confirmtext").verify_contains("OK") )

        c = "start #{$ie.dir.gsub("/" , "\\" )}\\clickJSDialog.rb Cancel 3"
        puts "Starting #{c}"
        w = WinClicker.new
        w.winsystem(c )   
        $ie.button("Confirm").click
        assert( $ie.textField(:name , "confirmtext").verify_contains("Cancel") )



    end


    def atest_Prompt
        gotoPopUpPage()
        c = "start #{$ie.dir.gsub("/" , "\\" )}\\clickJSDialog.rb Cancel 3  "
        puts "Starting #{c}"
        w = WinClicker.new
        w.winsystem(c )   
        $ie.button("Prompt").click


    end

end


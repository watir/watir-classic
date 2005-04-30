# feature tests for javascript PopUps
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_PopUps < Test::Unit::TestCase
    include Watir

    def setup
        $ie.goto("file://#{$myDir}/html/popups1.html")
    end

    def startClicker( button , waitTime = 0.5)
        w = WinClicker.new
        longName = $ie.dir.gsub("/" , "\\" )
        shortName = w.getShortFileName(longName)
        c = "start rubyw #{shortName }\\watir\\clickJSDialog.rb #{button } #{ waitTime} "
        puts "Starting #{c}"
        w.winsystem(c )   
        w=nil
    end

    def test_simple
        startClicker("OK")
        $ie.button("Alert").click
    end

    def test_confirm
        startClicker("OK")
        $ie.button("Confirm").click
        assert( $ie.text_field(:name , "confirmtext").verify_contains("OK") )

        startClicker("Cancel")
        $ie.button("Confirm").click
        assert( $ie.text_field(:name , "confirmtext").verify_contains("Cancel") )
    end

    def xtest_Prompt
        startClicker("OK")
        $ie.button("Prompt").click
    end
end


# feature tests for Divs
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Divs < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "div.html")
    end


    def test_Divs

       assert_raises(UnknownObjectException) {$ie.div(:id , "div77").click }
       assert_raises(UnknownObjectException) {$ie.div(:title , "div77").click }



       assert($ie.textField(:name, "text1").verify_contains("0") )  
       $ie.div(:id , "div3").click
       assert($ie.textField(:name, "text1").verify_contains("1") )  

       $ie.div(:id , "div4").click
       assert($ie.textField(:name, "text1").verify_contains("0") )  
    end

    def test_getText
       assert_raises(UnknownObjectException) {$ie.div(:id , "div77").getText }
       assert_raises(UnknownObjectException) {$ie.div(:title , "div77").getText }

       assert_equal("This div has an onClick that increments text1" ,   $ie.div(:id , "div3").getText.strip )
       assert_equal("This text is in a div with an id of div1 and title of test1" ,   $ie.div(:title , "Test1").getText.strip )

    end

    def test_getStyle

        assert_raises(UnknownObjectException) {$ie.div(:id , "div77").getStyle }
        assert_equal("blueText" ,   $ie.div(:id , "div2").getStyle )
        assert_equal("" ,   $ie.div(:id , "div1").getStyle )

    end

end
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
       assert_raises(UnknownObjectException) {$ie.div(:id , "div77").text }
       assert_raises(UnknownObjectException) {$ie.div(:title , "div77").text }

       assert_equal("This div has an onClick that increments text1" ,   $ie.div(:id , "div3").text.strip )
       assert_equal("This text is in a div with an id of div1 and title of test1" ,   $ie.div(:title , "Test1").text.strip )

    end

    def test_getStyle

        assert_raises(UnknownObjectException) {$ie.div(:id , "div77").style }
        assert_equal("blueText" ,   $ie.div(:id , "div2").style )
        assert_equal("" ,   $ie.div(:id , "div1").style )

    end


    #---- Span Tests ---

    def test_Spans

       assert_raises(UnknownObjectException) {$ie.span(:id , "span77").click }
       assert_raises(UnknownObjectException) {$ie.span(:title , "span77").click }



       assert($ie.textField(:name, "text2").verify_contains("0") )  
       $ie.span(:id , "span3").click
       assert($ie.textField(:name, "text2").verify_contains("1") )  

       $ie.span(:id , "span4").click
       assert($ie.textField(:name, "text2").verify_contains("0") )  
    end

    def test_get_span_text
       assert_raises(UnknownObjectException) {$ie.span(:id , "span77").text }
       assert_raises(UnknownObjectException) {$ie.span(:title , "span77").text }

       assert_equal("This span has an onClick that increments text2" ,   $ie.span(:id , "span3").text.strip )
       assert_equal("This text is in a span with an id of span1 and title of test2" ,   $ie.span(:title , "Test2").text.strip )

    end

    def test_get_span_style

        assert_raises(UnknownObjectException) {$ie.span(:id , "span77").style }
        assert_equal("blueText" ,   $ie.span(:id , "span2").style )
        assert_equal("" ,   $ie.span(:id , "span1").style )

    end





end
# feature tests for Divs
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Divs < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "div.html")
    end


    def test_divs

       assert_raises(UnknownObjectException) {$ie.div(:id , "div77").click }
       assert_raises(UnknownObjectException) {$ie.div(:title , "div77").click }



       assert($ie.textField(:name, "text1").verify_contains("0") )  
       $ie.div(:id , "div3").click
       assert($ie.textField(:name, "text1").verify_contains("1") )  

       $ie.div(:id , "div4").click
       assert($ie.textField(:name, "text1").verify_contains("0") )  
    end

    def test_div_properties

       assert_raises(UnknownObjectException) {$ie.div(:id , "div77").text }
       assert_raises(UnknownObjectException) {$ie.div(:title , "div77").text }

       assert_equal("This div has an onClick that increments text1" ,   $ie.div(:id , "div3").text.strip )
       assert_equal("This text is in a div with an id of div1 and title of test1" ,   $ie.div(:title , "Test1").text.strip )

        assert_raises(UnknownObjectException) {$ie.div(:id , "div77").style }
        assert_equal("blueText" ,   $ie.div(:id , "div2").style )
        assert_equal("" ,   $ie.div(:id , "div1").style )

        assert_raises(UnknownObjectException) {$ie.div(:index , 44).style }
        assert_equal("div1" ,      $ie.div(:index , 1).id )
        assert_equal("" ,          $ie.div(:index , 1).style )
        assert_equal("blueText" ,  $ie.div(:index , 2).style )
        assert_equal("Div" ,       $ie.div(:index , 2).type)
        assert_equal(""    ,       $ie.div(:index , 2).value)
        assert_equal(false ,       $ie.div(:index , 2).disabled)
        assert_equal(""    ,       $ie.div(:index , 2).name)
        assert_equal("div2",       $ie.div(:index , 2).id)

    end


    #---- Span Tests ---

    def test_spans

       assert_raises(UnknownObjectException) {$ie.span(:id , "span77").click }
       assert_raises(UnknownObjectException) {$ie.span(:title , "span77").click }



       assert($ie.textField(:name, "text2").verify_contains("0") )  
       $ie.span(:id , "span3").click
       assert($ie.textField(:name, "text2").verify_contains("1") )  

       $ie.span(:id , "span4").click
       assert($ie.textField(:name, "text2").verify_contains("0") )  
    end

    def test_span_properties
        assert_raises(UnknownObjectException) {$ie.span(:id , "span77").text }
        assert_raises(UnknownObjectException) {$ie.span(:title , "span77").text }

        assert_equal("This span has an onClick that increments text2" ,   $ie.span(:id , "span3").text.strip )
        assert_equal("This text is in a span with an id of span1 and title of test2" ,   $ie.span(:title , "Test2").text.strip )

        assert_raises(UnknownObjectException) {$ie.span(:id , "span77").style }
        assert_equal("blueText" ,   $ie.span(:id , "span2").style )
        assert_equal("" ,   $ie.span(:id , "span1").style )


        assert_raises(UnknownObjectException) {$ie.span(:index , 44).style }
        assert_equal("span1" ,     $ie.span(:index , 1).id )
        assert_equal("" ,          $ie.span(:index , 1).style )
        assert_equal("blueText" ,  $ie.span(:index , 2).style )
        assert_equal("Span" ,      $ie.span(:index , 2).type)
        assert_equal(""    ,       $ie.span(:index , 2).value)
        assert_equal(false ,       $ie.span(:index , 2).disabled)
        assert_equal(""    ,       $ie.span(:index , 2).name)
        assert_equal("span2",      $ie.span(:index , 2).id)

    end

end
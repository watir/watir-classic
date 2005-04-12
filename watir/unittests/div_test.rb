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


    def test_div_iterator
 
        assert_equal( 7 , $ie.divs.length)
        assert_equal( "div1" , $ie.divs[1].id )

        #puts "1.id is " + $ie.divs[1].id.to_s
        #puts "2.id is " + $ie.divs[2].id.to_s


        index =1
        $ie.divs.each do |s|
            puts "each - div= " + s.to_s
            assert_equal($ie.div(:index, index ).name , s.name )
            assert_equal($ie.div(:index, index ).id , s.id )
            assert_equal($ie.div(:index, index ).style , s.style )
            index +=1
        end
        assert_equal(index-1, $ie.divs.length)   # -1 as we add 1 at the end of the loop
    end


    def test_objects_in_div
 
        assert($ie.div(:id, 'buttons1').button(:index,1).exists? )
        assert_false($ie.div(:id, 'buttons1').button(:index,3).exists? )
        assert($ie.div(:id, 'buttons1').button(:name,'b1').exists? )

        assert($ie.div(:id, 'buttons2').button(:index,1).exists? )
        assert($ie.div(:id, 'buttons2').button(:index,2).exists? )
        assert_false($ie.div(:id, 'buttons1').button(:index,3).exists? )
        
        $ie.div(:id, 'buttons1').button(:index,1).click

        assert_equal( 'button1' ,   $ie.div(:id , 'text_fields1').text_field(:index,1).value)

        assert_equal( 3 , $ie.div(:id , 'text_fields1').text_fields.length )


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

    def test_span_iterator
 
        assert_equal( 7 , $ie.spans.length)
        assert_equal( "span1" , $ie.spans[1].id )

        #puts "1.id is " + $ie.spans[1].id.to_s
        #puts "2.id is " + $ie.spans[2].id.to_s


        index =1
        $ie.spans.each do |s|
            puts "each - span = " + s.to_s
            assert_equal($ie.span(:index, index ).name , s.name )
            assert_equal($ie.span(:index, index ).id , s.id )
            assert_equal($ie.span(:index, index ).style , s.style )
            index +=1
        end
        assert_equal(index-1, $ie.spans.length)   # -1 as we add 1 at the end of the loop
    end


    def test_objects_in_span
 
        assert($ie.span(:id, 'buttons1').button(:index,1).exists? )
        assert_false($ie.span(:id, 'buttons1').button(:index,3).exists? )
        assert($ie.span(:id, 'buttons1').button(:name,'b1').exists? )

        assert($ie.span(:id, 'buttons2').button(:index,1).exists? )
        assert($ie.span(:id, 'buttons2').button(:index,2).exists? )
        assert_false($ie.span(:id, 'buttons1').button(:index,3).exists? )
        
        $ie.span(:id, 'buttons1').button(:index,1).click

        assert_equal( 'button1' ,   $ie.span(:id , 'text_fields1').text_field(:index,1).value)

        assert_equal( 3 , $ie.span(:id , 'text_fields1').text_fields.length )


    end



end
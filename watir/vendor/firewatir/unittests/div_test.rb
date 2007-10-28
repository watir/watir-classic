# feature tests for Divs, Spans and P's
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Divs < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "div.html")
  end
  
  def test_divs
    assert_raises(UnknownObjectException) {$ff.div(:id , "div77").click }
    assert_raises(UnknownObjectException) {$ff.div(:title , "div77").click }
    
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
    $ff.div(:id , "div3").click
    assert($ff.text_field(:name, "text1").verify_contains("1") )  
    $ff.div(:id , "div4").click
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
  end
  
  def test_show_all_objects
    assert_equal(36, $ff.show_all_objects.length)
    assert_equal(3,$ff.div(:id,"text_fields1").show_all_objects.length)
   
    assert_equal(8,$ff.text_fields.length)
    assert_equal(3,$ff.div(:id,"text_fields1").text_fields.length)
  end
  
  def test_div_properties
    assert_raises(UnknownObjectException) {$ff.div(:id , "div77").text }
    assert_raises(UnknownObjectException) {$ff.div(:title , "div77").text }
    
    assert_equal("This div has an onClick that increments text1", $ff.div(:id , "div3").text.strip )
    assert_equal("This text is in a div with an id of div1 and title of test1",$ff.div(:title , "Test1").text.strip )
    
    assert_raises(UnknownObjectException) {$ff.div(:id , "div77").class_name }
    assert_equal("blueText" ,   $ff.div(:id , "div2").class_name )
    assert_equal("" ,   $ff.div(:id , "div1").class_name )
    
    assert_raises(UnknownObjectException) {$ff.div(:index , 44).class_name }
    assert_equal("div1" ,      $ff.div(:index , 1).id )
    assert_equal("" ,          $ff.div(:index , 1).class_name )
    assert_equal("blueText" ,  $ff.div(:index , 2).class_name )
    assert_equal(""    ,       $ff.div(:index , 2).value)
    #assert_equal(false ,       $ff.div(:index , 2).disabled)
    assert_equal(""    ,       $ff.div(:index , 2).name)
    assert_equal("div2",       $ff.div(:index , 2).id)
    #puts  $ff.div(:id,"text_fields1").to_s
  end
  
  def test_div_iterator
    assert_equal( 7 , $ff.divs.length)
    assert_equal( "div1" , $ff.divs[1].id )
    
    index =1
    $ff.divs.each do |s|
      # puts "each - div= " + s.to_s
      assert_equal($ff.div(:index, index ).name , s.name )
      assert_equal($ff.div(:index, index ).id , s.id )
      assert_equal($ff.div(:index, index ).class_name , s.class_name )
      index +=1
    end
    assert_equal(index-1, $ff.divs.length)   # -1 as we add 1 at the end of the loop
  end
  
  def test_objects_in_div
    assert($ff.div(:id, 'buttons1').button(:index,1).exists? )
    assert(!$ff.div(:id, 'buttons1').button(:index,3).exists? )
    assert($ff.div(:id, 'buttons1').button(:name,'b1').exists? )
    $ff.div(:id, 'buttons1').button(:name,'b1').click
    
    assert($ff.div(:id, 'buttons2').button(:index,1).exists? )
    assert($ff.div(:id, 'buttons2').button(:index,2).exists? )
    assert(!$ff.div(:id, 'buttons1').button(:index,3).exists? )
    
    $ff.div(:id, 'buttons1').button(:index,1).click
    
    assert_equal( 'button1' ,   $ff.div(:id , 'text_fields1').text_field(:index,1).value)
    
    #assert_equal( 3 , $ff.div(:id , 'text_fields1').text_fields.length )
   $ff.div(:id, 'text_fields1').text_field(:name, 'div_text1').set("drink me")
   assert_equal("drink me", $ff.div(:id, 'text_fields1').text_field(:name, 'div_text1').getContents)
 end
  
  #---- Span Tests ---
  def test_spans
    assert_raises(UnknownObjectException) {$ff.span(:id , "span77").click }
    assert_raises(UnknownObjectException) {$ff.span(:title , "span77").click }
    
    assert($ff.text_field(:name, "text2").verify_contains("0") )  
    $ff.span(:id , "span3").click
    assert($ff.text_field(:name, "text2").verify_contains("1") )  
    
    $ff.span(:id , "span4").click
    assert($ff.text_field(:name, "text2").verify_contains("0") )  
    
    #puts $ff.span(:id,"text_fields1").to_s
  end
  
  def test_span_properties
    assert_raises(UnknownObjectException) {$ff.span(:id , "span77").text }
    assert_raises(UnknownObjectException) {$ff.span(:title , "span77").text }
    
    assert_equal("This span has an onClick that increments text2" ,   $ff.span(:id , "span3").text.strip )
    assert_equal("This text is in a span with an id of span1 and title of test2" ,   $ff.span(:title , "Test2").text.strip )
    
    assert_raises(UnknownObjectException) {$ff.span(:id , "span77").class_name }
    assert_equal("blueText" ,   $ff.span(:id , "span2").class_name )
    assert_equal("" ,   $ff.span(:id , "span1").class_name )
    
    assert_raises(UnknownObjectException) {$ff.span(:index , 44).class_name }
    assert_equal("span1" ,     $ff.span(:index , 1).id )
    assert_equal("" ,          $ff.span(:index , 1).class_name )
    assert_equal("blueText" ,  $ff.span(:index , 2).class_name )
    assert_equal(""    ,       $ff.span(:index , 2).value)
    #assert_equal(false ,       $ff.span(:index , 2).disabled)
    assert_equal(""    ,       $ff.span(:index , 2).name)
    assert_equal("span2",      $ff.span(:index , 2).id)
  end
  
  def test_span_iterator
    assert_equal(7, $ff.spans.length)
    assert_equal("span1", $ff.spans[1].id)
    
    index = 1
    $ff.spans.each do |s|
      # puts "each - span = " + s.to_s
      assert_equal($ff.span(:index, index ).name , s.name )
      assert_equal($ff.span(:index, index ).id , s.id )
      assert_equal($ff.span(:index, index ).class_name , s.class_name )
      index += 1
    end
    assert_equal(index - 1, $ff.spans.length)   # -1 as we add 1 at the end of the loop
  end
  
  def test_objects_in_span
    assert($ff.span(:id, 'buttons1').button(:index,1).exists? )
    assert(!$ff.span(:id, 'buttons1').button(:index,3).exists? )
    assert($ff.span(:id, 'buttons1').button(:name,'b1').exists? )
    
    assert($ff.span(:id, 'buttons2').button(:index,1).exists? )
    assert($ff.span(:id, 'buttons2').button(:index,2).exists? )
    assert(!$ff.span(:id, 'buttons1').button(:index,3).exists? )
    
    $ff.span(:id, 'buttons1').button(:index,1).click
    
    assert_equal( 'button1' ,   $ff.span(:id , 'text_fields1').text_field(:index,1).value)
    $ff.span(:id , 'text_fields1').text_field(:index,1).set('text box inside span')
    assert_equal( 'text box inside span' ,   $ff.span(:id , 'text_fields1').text_field(:index,1).value)
   
    #assert_equal( 3 , $ff.span(:id , 'text_fields1').text_fields.length )
  end
  
  def test_p
    assert($ff.p(:id, 'number1').exists?)
    assert($ff.p(:index, 3).exists?)
    assert($ff.p(:title, 'test_3').exists?)
    
    assert(!$ff.p(:id, 'missing').exists?)
    assert(!$ff.p(:index, 8).exists?)
    assert(!$ff.p(:title, 'test_55').exists?)
    
    assert_raises( UnknownObjectException) {$ff.p(:id , 'missing').class_name }
    assert_raises( UnknownObjectException) {$ff.p(:id , 'missing').text }
    assert_raises( UnknownObjectException) {$ff.p(:id , 'missing').title }
    assert_raises( UnknownObjectException) {$ff.p(:id , 'missing').to_s }
    assert_raises( UnknownObjectException) {$ff.p(:id , 'missing').disabled }
    
    assert_equal(  'redText' , $ff.p(:index,1).class_name)
    assert_equal(  'P_tag_1' , $ff.p(:index,1).title)
    assert_equal(  'This text is in a p with an id of number2' , $ff.p(:index,2).text)
  end
  
  def test_p_iterator
    assert_equal( 3, $ff.ps.length)
    assert_equal( 'italicText', $ff.ps[2].class_name)
    assert_equal( 'number3', $ff.ps[3].id)
    
    count=1
    $ff.ps.each do |p|
      assert_equal('number'+count.to_s , p.id)
      count+=1
    end
    assert_equal( count-1 ,  $ff.ps.length)
  end
end

class TC_Divs_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showDivs
    $ff.goto($htmlRoot + "div.html")
    $stdout = @mockout
    $ff.showDivs
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 7 divs
div:   name: 
         id: div1
      class: 
      index: 1
div:   name: 
         id: div2
      class: blueText
      index: 2
div:   name: 
         id: div3
      class: 
      index: 3
div:   name: 
         id: div4
      class: 
      index: 4
div:   name: 
         id: buttons1
      class: 
      index: 5
div:   name: 
         id: buttons2
      class: 
      index: 6
div:   name: divName
         id: text_fields1
      class: divClass
      index: 7
END_OF_MESSAGE
  end
end

class TC_Spans_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showSpans
    $ff.goto($htmlRoot + "div.html")
    $stdout = @mockout
    $ff.showSpans
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 7 spans
span:  name: 
         id: span1
      class: 
      index: 1
span:  name: 
         id: span2
      class: blueText
      index: 2
span:  name: 
         id: span3
      class: 
      index: 3
span:  name: 
         id: span4
      class: 
      index: 4
span:  name: 
         id: buttons1
      class: 
      index: 5
span:  name: 
         id: buttons2
      class: 
      index: 6
span:  name: spanName
         id: text_fields1
      class: spanClass
      index: 7
END_OF_MESSAGE
  end
end

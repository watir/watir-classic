# feature tests for Forms
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Forms2 < Test::Unit::TestCase # Note: there is no TC_Forms
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "forms2.html")
  end
 
  def test_Form_Exists
    assert($ff.form(:name, "test2").exists?)   
    assert(!$ff.form(:name, "missing").exists?)   
    
    assert($ff.form("test2").exists?)   
    assert(!$ff.form( "missing").exists?)   

    assert($ff.form(:index,  1).exists?)   
    assert(!$ff.form(:index, 88).exists?)   
    
    assert($ff.form(:method, "get").exists?)   
    assert(!$ff.form(:method, "missing").exists?)   
    
    assert($ff.form(:id, 'f2').exists?)   
    assert(!$ff.form(:id, 'missing').exists?)   
    
    assert($ff.form(:action, /pass.html/).exists?)   
    assert(!$ff.form(:action, "missing").exists?)   
  end
  
  def test_ButtonInForm
    assert($ff.form(:name, "test2").button(:caption , "Submit").exists?)
  end     
  
  # The following tests from bug 2261 
  def test_form_html 
    assert_equal("\n<BR><INPUT value=\"Submit\" type=\"submit\">\n".downcase(), 
    $ff.form(:name, 'test2').html.downcase())
  end
  def test_form_flash
    assert_nothing_raised{ $ff.form(:name, 'test2').flash }
  end
  def test_form_sub_element
    assert_equal('Click Me', $ff.form(:index, 1).button(:name, 'b1').value)
  end
end

class TC_Form_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showforms
    $ff.goto($htmlRoot + "forms2.html")
    $stdout = @mockout
    $ff.showForms
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 4 forms
Form name: 
       id: 
   method: get
   action: pass.html
Form name: test2
       id: f2
   method: get
   action: pass2.html
Form name: test3
       id: 
   method: get
   action: pass2.html
Form name: test2
       id: 
   method: get
   action: pass2.html
END_OF_MESSAGE
  end
end

class TC_Forms3 < Test::Unit::TestCase
  include FireWatir
  def setup
    $ff.goto($htmlRoot + "forms3.html")
  end
  
  # The following tests from bug 2261 
  def test_p_in_form
    $ff.form(:name, 'buttonsubmit').p(:index, 1).text
  end
  
  def test_Form_Exists
    assert($ff.form(:name, "test2").exists?)   
    assert(!$ff.form(:name, "missing").exists?)   
    
    assert($ff.form("test2").exists?)   
    assert(!$ff.form( "missing").exists?)   
    
    assert($ff.form(:index,  1).exists?)   
    assert(!$ff.form(:index, 88).exists?)   
    
    assert($ff.form(:method, "get").exists?)   
    assert(!$ff.form(:method, "missing").exists?)   
    
    assert($ff.form(:action, "pass.html").exists?)   
    assert(!$ff.form(:action, "missing").exists?)   
  end
  
  def test_index_other_element_before_it
    # test for bug reported by Scott Pack,  http://rubyforge.org/pipermail/wtr-general/2005-June/002223.html
    assert_equal("check1" , $ff.checkbox(:index,1).name )
  end
  
  def test_reset
    $ff.text_field(:id, "t1").set("Hello, reset test!")
    assert_equal($ff.text_field(:id, 't1').getContents, 'Hello, reset test!')
    
    $ff.button(:id, "reset_button").click
    assert_equal("" , $ff.text_field(:id, 't1').getContents )
    
    # also verify it works under a form
    $ff.text_field(:id, "t1").set("reset test - using a form")
    assert_equal($ff.text_field(:id, 't1').getContents, 'reset test - using a form')
    
    $ff.form(:index,2).button(:index,2).click
    assert_equal("" , $ff.text_field(:id, 't1').getContents )
    
    # also verify it works under a form, this time using the :id attribute
    $ff.text_field(:id, "t1").set("reset test - using a form")
    assert_equal($ff.text_field(:id, 't1').getContents, 'reset test - using a form')
    
    $ff.form(:index,2).button(:id,'reset_button').click
    assert_equal("" , $ff.text_field(:id, 't1').getContents )
  end
  
##  def test_flash1
##    $ff.form(:name ,"test2").button(:caption , "Submit").flash
##  end 
#  
  def test_objects_with_same_name
    assert_equal('textfield' ,$ff.text_field( :name , 'g1').value )
    assert_equal('button'    ,$ff.button(     :name , 'g1').value )
    assert_equal('1'         ,$ff.checkbox(   :name , 'g1').value )
    assert_equal('2'         ,$ff.radio(      :name , 'g1').value )
   
    assert_equal('textfield' ,$ff.text_field( :name , /g1/).value )
    assert_equal('button'    ,$ff.button(     :name , /g1/).value )
    assert_equal('1'         ,$ff.checkbox(   :name , /g1/).value )
    assert_equal('2'         ,$ff.radio(      :name , /g1/).value )
    
    assert_equal('textfield_id' ,$ff.text_field( :id , 'g1').value )
    assert_equal('button_id'    ,$ff.button(     :id , 'g1').value )
    assert_equal('1_id'         ,$ff.checkbox(   :id , 'g1').value )
    assert_equal('2_id'         ,$ff.radio(      :id , 'g1').value )

    assert_equal('textfield_id' ,$ff.text_field( :id , /g1/).value )
    assert_equal('button_id'    ,$ff.button(     :id , /g1/).value )
    assert_equal('1_id'         ,$ff.checkbox(   :id , /g1/).value )
    assert_equal('2_id'         ,$ff.radio(      :id , /g1/).value )
  end
  
#  def test_flash2
#    $ff.button(:value, 'Click Me').flash
#    assert_raises( Watir::UnknownObjectException ) { $ff.text_field( :name , 'g177').flash }
#  end
  
  def test_submitWithImage
    assert( $ff.button(:alt , "submit").exists? )
    assert( $ff.button(:alt , /sub/).exists? )
    
    assert(! $ff.button(:alt , "missing").exists? )
    assert(! $ff.button(:alt , /missing/).exists? )
    
    #assert( $ff.button(:src , "file:///#{$myDir}/html/images/button.jpg").exists? )    # this doesnt work for everybody
    assert( $ff.button(:src , /button/).exists? )
    
    assert(! $ff.button(:src , "missing").exists? )
    assert(! $ff.button(:src , /missing/).exists? )
    assert_nothing_raised("raised an exception when it shouldnt have") { $ff.button(:src , /button/).click }
    
    assert( $ff.text.include?("PASS") )
  end
end

#class TC_Forms3_Display < Test::Unit::TestCase
#  include FireWatir
#  include MockStdoutTestCase # BUG in test: output not verified!                
#  def test_show_stuff
#    $ff.goto($htmlRoot + "forms3.html")
#    $stdout = @mockout
#    $ff.showAllObjects
#    puts $ff.getText
#    puts $ff.getHTML
#  end
#end

class TC_Forms4 < Test::Unit::TestCase
  include FireWatir
  def setup
    $ff.goto($htmlRoot + "forms4.html")
  end
  
  def test_find_text_field_ignoring_form
    assert_equal($ff.text_field(:name, 'name').getContents, 'apple') # should it raise a not-unique error instead?
  end
  
  def test_correct_form_field_is_found_using_form_name
    assert_equal($ff.form(:name, 'apple_form').text_field(:name, 'name').getContents, 'apple')
    assert_equal($ff.form(:name, 'banana_form').text_field(:name, 'name').getContents, 'banana')
  end
  
  def test_correct_form_field_is_found_using_form_index
    assert_equal($ff.form(:index, 1).text_field(:name, 'name').getContents, 'apple')
    assert_equal($ff.form(:index, 2).text_field(:name, 'name').getContents, 'banana')
  end
  
  def test_using_text_on_form
    $ff.form(:name, 'apple_form').text_field(:name, 'name').set('strudel')
    assert_equal($ff.form(:index, 1).text_field(:name, 'name').getContents, 'strudel')
  end 
  
  def test_submit
    $ff.form(:name, 'apple_form').submit
    assert( $ff.text.include?("PASS") )
  end
end

class TC_Hidden_Fields2 < Test::Unit::TestCase
  include FireWatir
  def setup
    $ff.goto($htmlRoot + "forms3.html")
  end
  
  def test_hidden
    
    # test using index
    assert( $ff.hidden(:index,1).exists? )
    assert( $ff.hidden(:index,2).exists? )
    assert(! $ff.hidden(:index,3).exists? )
    
    $ff.hidden(:index,1).value = 44
    $ff.hidden(:index,2).value = 55
    
    $ff.button(:value , "Show Hidden").click
    
    assert_equal("44"  , $ff.text_field(:name , "vis1").value ) 
    assert_equal("55"  , $ff.text_field(:name , "vis2").value )
   
    # test using name and ID
    assert( $ff.hidden(:name ,"hid1").exists? )
    assert( $ff.hidden(:id,"hidden_1").exists? )
    assert(! $ff.hidden(:name,"hidden_44").exists? )
    assert(! $ff.hidden(:id,"hidden_55").exists? )
    
    $ff.hidden(:name ,"hid1").value = 444
    $ff.hidden(:id,"hidden_1").value = 555
    
    $ff.button(:value , "Show Hidden").click
    
    assert_equal("444"  , $ff.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ff.text_field(:name ,"vis2").value )
    
    #  test the over-ridden append method
    $ff.hidden(:name ,"hid1").append("a")
    $ff.button(:value , "Show Hidden").click
    assert_equal("444a"  , $ff.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ff.text_field(:name ,"vis2").value )
    
    #  test the over-ridden clear method
    $ff.hidden(:name ,"hid1").clear
    $ff.button(:value , "Show Hidden").click
    assert_equal(""  , $ff.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ff.text_field(:name ,"vis2").value )
    
    # test using a form
    assert( $ff.form(:name , "has_a_hidden").hidden(:name ,"hid1").exists? )
    assert( $ff.form(:name , "has_a_hidden").hidden(:id,"hidden_1").exists? )
    assert(! $ff.form(:name , "has_a_hidden").hidden(:name,"hidden_44").exists? )
    assert(! $ff.form(:name , "has_a_hidden").hidden(:id,"hidden_55").exists? )
    
    $ff.form(:name , "has_a_hidden").hidden(:name ,"hid1").value = 222
    $ff.form(:name , "has_a_hidden").hidden(:id,"hidden_1").value = 333
    
    $ff.button(:value , "Show Hidden").click
   
    assert_equal("222"  , $ff.text_field(:name , "vis1").value ) 
    assert_equal("333"  , $ff.text_field(:name ,"vis2").value )
   
    # iterators
##    assert_equal(2, $ff.hiddens.length)
##    count =1
##    $ff.hiddens.each do |h|
##      case count
##      when 1
##        assert_equal( "", h.id)
##        assert_equal( "hid1", h.name)
##      when 2
##        assert_equal( "", h.name)
##        assert_equal( "hidden_1", h.id)
##      end
##      count+=1
##    end
#    
##    assert_equal("hid1" , $ff.hiddens[1].name )
##    assert_equal("hidden_1" , $ff.hiddens[2].id )
  end
end

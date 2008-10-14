# feature tests for Forms
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Forms2_XPath < Test::Unit::TestCase
  def setup
    goto_page "forms2.html"
  end
  
  def test_Form_Exists
    assert($ie.form(:xpath , "//form[@name='test2']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@name='missing']/").exists?)   
    
    assert($ie.form(:xpath , "//form[@method='get']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@method='missing']/").exists?)   
    
    assert($ie.form(:xpath , "//form[@action='pass.html']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@action='missing']/").exists?)   
  end
  
  def test_ButtonInForm
    assert($ie.form(:xpath , "//form[@name='test2']/").button(:caption , "Submit").exists?)
  end     
end

require 'unittests/iostring'
class TC_Form_Display_XPath < Test::Unit::TestCase
  include MockStdoutTestCase                
  def test_showforms
    goto_page "forms2.html"
    $stdout = @mockout
    $ie.show_forms
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

class TC_Forms3_XPath < Test::Unit::TestCase
  def setup
    goto_page "forms3.html"
  end
  
  def test_Form_Exists
    assert($ie.form(:xpath , "//form[@name='test2']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@name='missing']/").exists?)   
    
    assert($ie.form(:xpath , "//form[@method='get']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@method='missing']/").exists?)   
    
    assert($ie.form(:xpath , "//form[@action='pass.html']/").exists?)   
    assert_false($ie.form(:xpath , "//form[@action='missing']/").exists?)   
  end
  
  def test_getObject_when_non_watir_object_before_it
    # test for bug reported by Scott Pack,  http://rubyforge.org/pipermail/wtr-general/2005-June/002223.html
    assert_equal("check1" , $ie.checkbox(:index,1).name )
  end
  
  def test_showforms # add verification of output!
    $ie.show_forms
  end
  
  def test_reset
    
    $ie.text_field(:id, "t1").set("Hello, reset test!")
    assert_equal($ie.text_field(:id, 't1').value, 'Hello, reset test!')
    
    $ie.button(:caption, "Reset").click
    assert_equal("" , $ie.text_field(:id, 't1').value )
    
    # also verify it works under a form
    $ie.text_field(:id, "t1").set("reset test - using a form")
    assert_equal($ie.text_field(:id, 't1').value, 'reset test - using a form')
        
    # also verify it works under a form, this time using the :id attribute
    $ie.text_field(:id, "t1").set("reset test - using a form")
    assert_equal($ie.text_field(:id, 't1').value, 'reset test - using a form')    
  end
    
  def test_flash1
    $ie.form(:xpath , "//form[@name='test2']/").button(:caption , "Submit").flash
  end 
  
  def test_objects_with_same_name
    assert_equal('textfield' ,$ie.text_field( :name , 'g1').value )
    assert_equal('button'    ,$ie.button(    :name , 'g1').value )
    assert_equal('1'         ,$ie.checkbox(  :name , 'g1').value )
    assert_equal('2'         ,$ie.radio(     :name , 'g1').value )
    
    assert_equal('textfield_id' ,$ie.text_field( :id , 'g1').value )
    assert_equal('button_id'    ,$ie.button(    :id , 'g1').value )
    assert_equal('1_id'         ,$ie.checkbox(  :id , 'g1').value )
    assert_equal('2_id'         ,$ie.radio(     :id , 'g1').value )
  end
  
  def test_flash2
    $ie.button(:value, 'Click Me').flash
    assert_raises( Watir::UnknownObjectException ) { $ie.text_field( :name , 'g177').flash }
  end
  
  def test_showElements # add verification!
    $ie.show_all_objects
  end
  
  def test_showText
    puts $ie.text
  end
  
  def test_showHTML
    puts $ie.html
  end
  
  def test_submitWithImage
    assert( $ie.button(:alt , "submit").exists? )
    assert( $ie.button(:alt , /sub/).exists? )
    
    assert_false( $ie.button(:alt , "missing").exists? )
    assert_false( $ie.button(:alt , /missing/).exists? )
    
    #assert( $ie.button(:src , "file:///#{$myDir}/html/images/button.jpg").exists? )    # this doesnt work for everybody
    assert( $ie.button(:src , /button/).exists? )
    
    assert_false( $ie.button(:src , "missing").exists? )
    assert_false( $ie.button(:src , /missing/).exists? )
    assert_nothing_raised("raised an exception when it shouldnt have") { $ie.button(:src , /button/).click }
    
    assert( $ie.contains_text("PASS") )
  end
end

class TC_Forms4_XPath < Test::Unit::TestCase
  def setup
    goto_page "forms4.html"
  end
  
  def test_find_text_field_ignoring_form
    assert_equal($ie.text_field(:name, 'name').value, 'apple') # should it raise a not-unique error instead?
  end
  
  def test_correct_form_field_is_found_using_form_name
    assert_equal($ie.form(:xpath , "//form[@name='apple_form']/").text_field(:name, 'name').value, 'apple')
    assert_equal($ie.form(:xpath , "//form[@name='banana_form']/").text_field(:name, 'name').value, 'banana')
  end
  
  def test_using_text_on_form
    $ie.form(:xpath , "//form[@name='apple_form']/").text_field(:name, 'name').set('strudel')
    assert_equal($ie.form(:index, 1).text_field(:name, 'name').value, 'strudel')
  end 
  
  def test_submit
    $ie.form(:xpath , "//form[@name='apple_form']/").submit
    assert( $ie.contains_text("PASS") )
  end
end

class TC_Hidden_Fields_XPath < Test::Unit::TestCase
  def setup
    goto_page "forms3.html"
  end
  
  def test_hidden
    
    # test using index
    assert( $ie.hidden(:index,1).exists? )
    assert( $ie.hidden(:index,2).exists? )
    assert_false( $ie.hidden(:index,3).exists? )
    
    $ie.hidden(:index,1).value = 44
    $ie.hidden(:index,2).value = 55
    
    $ie.button(:value , "Show Hidden").click
    
    assert_equal("44"  , $ie.text_field(:name , "vis1").value ) 
    assert_equal("55"  , $ie.text_field(:name , "vis2").value )
    
    # test using name and ID
    assert( $ie.hidden(:name ,"hid1").exists? )
    assert( $ie.hidden(:id,"hidden_1").exists? )
    assert_false( $ie.hidden(:name,"hidden_44").exists? )
    assert_false( $ie.hidden(:id,"hidden_55").exists? )
    
    $ie.hidden(:name ,"hid1").value = 444
    $ie.hidden(:id,"hidden_1").value = 555
    
    $ie.button(:value , "Show Hidden").click
    
    assert_equal("444"  , $ie.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
    
    #  test the over-ridden append method
    $ie.hidden(:name ,"hid1").append("a")
    $ie.button(:value , "Show Hidden").click
    assert_equal("444a"  , $ie.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
    
    #  test the over-ridden clear method
    $ie.hidden(:name ,"hid1").clear
    $ie.button(:value , "Show Hidden").click
    assert_equal(""  , $ie.text_field(:name , "vis1").value ) 
    assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
    
    # test using a form
    assert( $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:name ,"hid1").exists? )
    assert( $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:id,"hidden_1").exists? )
    assert_false( $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:name,"hidden_44").exists? )
    assert_false( $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:id,"hidden_55").exists? )
    
    $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:name ,"hid1").value = 222
    $ie.form(:xpath , "//form[@name='has_a_hidden']/").hidden(:id,"hidden_1").value = 333
    
    $ie.button(:value , "Show Hidden").click
    
    assert_equal("222"  , $ie.text_field(:name , "vis1").value ) 
    assert_equal("333"  , $ie.text_field(:name ,"vis2").value )
    
    # iterators
    assert_equal(2, $ie.hiddens.length)
    count =1
    $ie.hiddens.each do |h|
      case count
      when 1
        assert_equal( "", h.id)
        assert_equal( "hid1", h.name)
      when 2
        assert_equal( "", h.name)
        assert_equal( "hidden_1", h.id)
      end
      count+=1
    end
    
    assert_equal("hid1" , $ie.hiddens[1].name )
    assert_equal("hidden_1" , $ie.hiddens[2].id )
  end
end

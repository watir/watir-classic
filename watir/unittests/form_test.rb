# feature tests for Forms
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Forms2 < Test::Unit::TestCase # Note: there is no TC_Forms1
  def setup
    uses_page "forms2.html"
  end
  
  def test_form_exists
    assert(browser.form(:name, "test2").exists?)   
    assert_false(browser.form(:name, "missing").exists?)   
    
    assert(browser.form("test2").exists?)   
    assert_false(browser.form("missing").exists?)   

    assert(browser.form(:index, 1).exists?)   
    assert_false(browser.form(:index, 88).exists?)   
    
    assert(browser.form(:method, "get").exists?)   
    assert_false(browser.form(:method, "missing").exists?)   
    
    assert(browser.form(:id, 'f2').exists?)   
    assert_false(browser.form(:id, 'missing').exists?)   
    
    assert(browser.form(:action, "pass.html").exists?)   
    assert_false(browser.form(:action, "missing").exists?)   
  end
  
  def test_button_in_form
    assert(browser.form(:name, "test2").button(:caption, "Submit").exists?)
  end     
  def test_form_sub_element
    assert_equal('Click Me', browser.form(:index, 1).button(:name, 'b1').value)
  end

  # The following tests form bug 2261 
  tag_method :test_form_outer_html, :fails_on_firefox
  def test_form_outer_html 
    expected = "\r\n<FORM id=f2 name=test2 action=pass2.html method=get><BR><INPUT type=submit value=Submit> </FORM>"
    assert_equal(expected, browser.form(:name, 'test2').html)
  end
  tag_method :test_form_inner_html, :fails_on_ie
  def test_form_inner_html
    expected = "\n<br><input value=\"Submit\" type=\"submit\">\n"
    assert_equal(expected, browser.form(:name, 'test2').html)
  end
  def test_form_flash
    assert_nothing_raised{ browser.form(:name, 'test2').flash }
  end
end

require 'unittests/iostring'
class TC_Form_Display < Test::Unit::TestCase
  include MockStdoutTestCase                
  def test_showforms
    goto_page "forms2.html"
    $stdout = @mockout
    browser.showForms
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
  def setup
    goto_page "forms3.html"
  end
  
  # The following tests form bug 2261 
  def test_p_in_form
    assert_equal "This form has a submit button that is an image", 
      browser.form(:name, 'buttonsubmit').p(:index, 1).text
  end
  
  # test for bug reported by Scott Pack,  http://rubyforge.org/pipermail/wtr-general/2005-June/002223.html
  def test_index_other_element_before_it
    assert_equal("check1" , browser.checkbox(:index,1).name)
  end
  
  tag_method :test_reset, :fails_on_firefox
  def test_reset
    browser.text_field(:id, "t1").set("Hello, reset test!")
    assert_equal(browser.text_field(:id, 't1').value, 'Hello, reset test!')
    
    browser.button(:caption, "Reset").click
    assert_equal("" , browser.text_field(:id, 't1').value)
    
    # also verify it works under a form
    browser.text_field(:id, "t1").set("reset test - using a form")
    assert_equal(browser.text_field(:id, 't1').value, 'reset test - using a form')
    
    browser.form(:index,2).button(:index,2).click
    assert_equal("" , browser.text_field(:id, 't1').value)
    
    # also verify it works under a form, this time using the :id attribute
    browser.text_field(:id, "t1").set("reset test - using a form")
    assert_equal(browser.text_field(:id, 't1').value, 'reset test - using a form')
    
    browser.form(:index,2).button(:id,'reset_button').click
    assert_equal("" , browser.text_field(:id, 't1').value)
  end
  
  def test_flash1
    assert_nothing_raised do
      browser.form(:name, "test2").button(:caption , "Submit").flash
    end
  end 
  
  def test_objects_with_same_name
    assert_equal('textfield' ,browser.text_field( :name, 'g1').value )
    assert_equal('button'    ,browser.button(     :name, 'g1').value )
    assert_equal('1'         ,browser.checkbox(   :name, 'g1').value )
    assert_equal('2'         ,browser.radio(      :name, 'g1').value )
    
    assert_equal('textfield' ,browser.text_field( :name, /g1/).value )
    assert_equal('button'    ,browser.button(     :name, /g1/).value )
    assert_equal('1'         ,browser.checkbox(   :name, /g1/).value )
    assert_equal('2'         ,browser.radio(      :name, /g1/).value )
    
    assert_equal('textfield_id' ,browser.text_field( :id, 'g1').value )
    assert_equal('button_id'    ,browser.button(     :id, 'g1').value )
    assert_equal('1_id'         ,browser.checkbox(   :id, 'g1').value )
    assert_equal('2_id'         ,browser.radio(      :id, 'g1').value )

    assert_equal('textfield_id' ,browser.text_field( :id, /g1/).value )
    assert_equal('button_id'    ,browser.button(     :id, /g1/).value )
    assert_equal('1_id'         ,browser.checkbox(   :id, /g1/).value )
    assert_equal('2_id'         ,browser.radio(      :id, /g1/).value )
  end
  
  def test_flash2
    browser.button(:value, 'Click Me').flash
    assert_raises(UnknownObjectException) { browser.text_field( :name , 'g177').flash }
  end
  
  def test_submitWithImage
    assert( browser.button(:alt, "submit").exists? )
    assert( browser.button(:alt, /sub/).exists? )
    
    assert_false( browser.button(:alt, "missing").exists? )
    assert_false( browser.button(:alt, /missing/).exists? )
    
    #assert( browser.button(:src , "file:///#{$myDir}/html/images/button.jpg").exists? )    # this doesnt work for everybody
    assert( browser.button(:src, /button/).exists? )
    
    assert_false( browser.button(:src, "missing").exists? )
    assert_false( browser.button(:src, /missing/).exists? )
    assert_nothing_raised("raised an exception when it shouldnt have") { browser.button(:src , /button/).click }
    
    assert( browser.text.include?("PASS") )
  end
end

class TC_Forms3_Display < Test::Unit::TestCase
  include MockStdoutTestCase # BUG in test: output not verified!                
  def test_show_stuff
    goto_page "forms3.html"
    $stdout = @mockout
    browser.show_all_objects
    puts browser.text
    puts browser.html
  end
end

class TC_Forms4 < Test::Unit::TestCase
  def setup
    uses_page "forms4.html"
  end
  
  def test_find_text_field_ignoring_form
    assert_equal(browser.text_field(:name, 'name').value, 'apple')
  end
  
  def test_correct_form_field_is_found_using_form_name
    assert_equal(browser.form(:name, 'apple_form').text_field(:name, 'name').value, 'apple')
    assert_equal(browser.form(:name, 'banana_form').text_field(:name, 'name').value, 'banana')
  end
  
  def test_correct_form_field_is_found_using_form_index
    assert_equal(browser.form(:index, 1).text_field(:name, 'name').value, 'apple')
    assert_equal(browser.form(:index, 2).text_field(:name, 'name').value, 'banana')
  end
  
  def test_using_text_on_form
    browser.form(:name, 'apple_form').text_field(:name, 'name').set('strudel')
    assert_equal(browser.form(:index, 1).text_field(:name, 'name').value, 'strudel')
  end 
  
  def test_submit
    browser.form(:name, 'apple_form').submit
    assert(browser.text.include?("PASS"))
  end
end

class TC_Hidden_Fields < Test::Unit::TestCase
  def setup
    goto_page "forms3.html"
  end
  
  def test_hidden
    
    # test using index
    assert( browser.hidden(:index, 1).exists? )
    assert( browser.hidden(:index, 2).exists? )
    assert_false( browser.hidden(:index, 3).exists? )
    
    browser.hidden(:index, 1).value = 44
    browser.hidden(:index, 2).value = 55
    
    browser.button(:value, "Show Hidden").click
    
    assert_equal("44", browser.text_field(:name, "vis1").value ) 
    assert_equal("55", browser.text_field(:name, "vis2").value )
    
    # test using name and ID
    assert( browser.hidden(:name, "hid1").exists? )
    assert( browser.hidden(:id, "hidden_1").exists? )
    assert_false( browser.hidden(:name, "hidden_44").exists? )
    assert_false( browser.hidden(:id, "hidden_55").exists? )
    
    browser.hidden(:name, "hid1").value = 444
    browser.hidden(:id, "hidden_1").value = 555
    
    browser.button(:value, "Show Hidden").click
    
    assert_equal("444", browser.text_field(:name, "vis1").value) 
    assert_equal("555", browser.text_field(:name, "vis2").value)
    
    # test the over-ridden append method
    browser.hidden(:name, "hid1").append("a")
    browser.button(:value, "Show Hidden").click
    assert_equal("444a", browser.text_field(:name, "vis1").value ) 
    assert_equal("555", browser.text_field(:name, "vis2").value )
    
    # test the over-ridden clear method
    browser.hidden(:name, "hid1").clear
    browser.button(:value, "Show Hidden").click
    assert_equal("", browser.text_field(:name, "vis1").value) 
    assert_equal("555", browser.text_field(:name, "vis2").value)
    
    # test using a form
    assert( browser.form(:name, "has_a_hidden").hidden(:name, "hid1").exists? )
    assert( browser.form(:name, "has_a_hidden").hidden(:id, "hidden_1").exists? )
    assert_false( browser.form(:name, "has_a_hidden").hidden(:name, "hidden_44").exists? )
    assert_false( browser.form(:name, "has_a_hidden").hidden(:id, "hidden_55").exists? )
    
    browser.form(:name, "has_a_hidden").hidden(:name, "hid1").value = 222
    browser.form(:name, "has_a_hidden").hidden(:id, "hidden_1").value = 333
    
    browser.button(:value, "Show Hidden").click
    
    assert_equal("222", browser.text_field(:name, "vis1").value) 
    assert_equal("333", browser.text_field(:name, "vis2").value)
    
    # iterators
    assert_equal(2, browser.hiddens.length)
    count = 1
    browser.hiddens.each do |h|
      case count
      when 1
        assert_equal("", h.id)
        assert_equal("hid1", h.name)
      when 2
        assert_equal("", h.name)
        assert_equal("hidden_1", h.id)
      end
      count += 1
    end
    
    assert_equal("hid1", browser.hiddens[1].name)
    assert_equal("hidden_1", browser.hiddens[2].id)
  end
end
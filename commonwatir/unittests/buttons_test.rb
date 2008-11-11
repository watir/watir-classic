# feature tests for Buttons
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Button < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "buttons1.html"
  end 

  def test_exceptions_on_methods
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").id }  
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").name }  
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").disabled }  
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").type }  
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").value }  
  end
  
  def test_exception_when_one_argument
    assert_raises(UnknownObjectException) { browser.button( "Missing Caption").click }  
  end    
  
  def test_exceptions_with_click
    assert_raises(UnknownObjectException)  { browser.button(:caption, "Missing Caption").click }  
    assert_raises(UnknownObjectException)  { browser.button(:id, "missingID").click }  
  end

  def test_disabled_exception
    assert_raises(ObjectDisabledException) { browser.button(:caption, "Disabled Button").click }  
  end
  
  def test_exception_with_enabled
    assert_raises(UnknownObjectException) { browser.button(:name, "noName").enabled?  }  
  end

  def test_properties
    assert_equal("b1", browser.button(:index, 1).name) 
    assert_equal("b2", browser.button(:index, 1).id) 
    assert_equal("button", browser.button(:index, 1).type) 
    assert_equal("Click Me", browser.button(:index, 1).value) 
    assert_equal(false, browser.button(:index, 1).disabled) 
    assert_equal("italic_button", browser.button(:name, "b1").class_name) 
    assert_equal("", browser.button(:name , "b4").class_name) 
    
    assert_equal("b1", browser.button(:id, "b2").name) 
    assert_equal("b2", browser.button(:id, "b2").id) 
    assert_equal("button", browser.button(:id, "b2").type) 
    
    assert_equal("b4", browser.button(:index, 2).name) 
    assert_equal("b5", browser.button(:index, 2).id) 
    assert_equal("button", browser.button(:index, 2).type) 
    assert_equal("Disabled Button", browser.button(:index, 2).value) 
    assert_equal(true, browser.button(:index, 2).disabled) 
    
    assert_equal("", browser.button(:index, 2).title)
    assert_equal("this is button1", browser.button(:index, 1).title)
  end
  
  def test_default_how
    browser.button("Click Me").click
    assert(browser.text.include?("PASS"))
  end
  
  def test_click_and_caption
    browser.button(:caption, "Click Me").click
    assert(browser.text.include?("PASS") )
  end
  
  def test_access_by_class
    assert_equal('b1', browser.button(:class, 'italic_button').name)
  end

  def test_access_by_class_name
    assert_equal('b1', browser.button(:class_name, 'italic_button').name)
  end
  
  def test_exists
    assert(browser.button(:caption, "Click Me").exists?)   
    assert(browser.button(:caption, "Submit").exists?)   
    assert(browser.button(:name, "b1").exists?)   
    assert(browser.button(:id, "b2").exists?)   
    assert(browser.button(:caption, /sub/i).exists?)   
    
    assert_false(browser.button(:caption, "missingcaption").exists?)   
    assert_false(browser.button(:name, "missingname").exists?)   
    assert_false(browser.button(:id, "missingid").exists?)   
    assert_false(browser.button(:caption, /missing/i).exists?)   
  end
  
  def test_enabled
    assert(browser.button(:caption, "Click Me").enabled?)   
    assert_false(browser.button(:caption, "Disabled Button").enabled?)   
    assert_false(browser.button(:name, "b4").enabled?)   
    assert_false(browser.button(:id, "b5").enabled?)   
  end

end
  
class TC_Button2 < Test::Unit::TestCase
  location __FILE__
  
  def setup
    uses_page "buttons2.html"
  end 

  def test_exists
    assert(browser.button(:caption, "Click Me2").exists?)   
    assert(browser.button(:caption, "Disabled Button2").exists?) 
    assert(browser.button(:caption, "Sign In").exists?)
  end

  def test_button2
    assert_equal("b6", browser.button(:id, "b7").name) 
    assert_equal("b7", browser.button(:name, "b6").id) 
    assert_equal("Click Me2", browser.button(:id, "b7").value) 
    assert_equal(false, browser.button(:id, "b7").disabled) 
    assert_equal("italic_button", browser.button(:name, "b6").class_name  ) 
    
    assert_equal("b8", browser.button(:id, "b9").name) 
    assert_equal("b9", browser.button(:name, "b8").id) 
    assert_equal("Disabled Button2", browser.button(:id, "b9").value) 
    assert_equal(false, browser.button(:id, "b9").enabled?) 
    assert_equal("", browser.button(:name, "b8").class_name) 
    assert_equal("Sign In", browser.button(:caption, "Sign In").value)
    
    assert(browser.button(:caption, "Click Me").enabled?)   
    
    assert_false(browser.button(:caption, "Disabled Button2").enabled?)   
    
    assert_raises(ObjectDisabledException) { browser.button(:caption, "Disabled Button2").click }  
    
    browser.button(:caption, "Click Me2").click
    assert(browser.text.include?("PASS")) 
  end

  tag_method :test_buttons_length, :fails_on_ie
  def test_buttons_length
    arrButtons = browser.buttons
    assert_equal(7, arrButtons.length)
  end

  def test_buttons
    arrButtons = browser.buttons
    assert_equal("b2", arrButtons[1].id)
    assert_equal("b5", arrButtons[2].id)
    assert_equal("Submit", arrButtons[3].value)
    assert_equal("sub3", arrButtons[4].name)
    assert_equal("b7", arrButtons[5].id)
    assert_equal("b9", arrButtons[6].id)
    assert_equal("Sign In", arrButtons[7].value)
  end
  
  # Tests collection class
  def test_class_buttons
    arr_buttons = browser.buttons
    arr_buttons.each do |b|
      assert_class b, 'Button' 
    end
    # test properties
    assert_equal("b2", arr_buttons[1].id)
    assert_equal("b1", arr_buttons[1].name) 
    assert_equal("button", arr_buttons[1].type) 
    assert_equal("Click Me", arr_buttons[1].value) 
    assert_equal(false, arr_buttons[1].disabled) 
    assert_equal("italic_button", arr_buttons[1].class_name) 
    assert_equal( "this is button1", arr_buttons[1].title)
    
    assert_equal("b5", arr_buttons[2].id)
    assert_equal("b4", arr_buttons[2].name) 
    assert_equal("button", arr_buttons[2].type) 
    assert_equal("Disabled Button", arr_buttons[2].value) 
    assert_equal(true, arr_buttons[2].disabled) 
    assert_equal( "", arr_buttons[2].title)
    assert_equal("", arr_buttons[2].class_name) 
    
    assert_equal("Submit", arr_buttons[3].value)
    assert_equal("sub3", arr_buttons[4].name)
    assert_equal("b7", arr_buttons[5].id)
    assert_equal("b9", arr_buttons[6].id)
    assert_equal("Sign In", arr_buttons[7].value)
  end

  def test_hash_syntax
    assert_equal('Click Me2', browser.button(:id => 'b7').value)
  end

  def test_class_and_index
    assert_equal('Click Me2', 
      browser.button(:class => 'italic_button', :index => 2).value)
  end

  def test_name_and_id #sick, but what the hell
    assert_equal('Disabled Button2',
      browser.button(:name => 'b8', :id => 'b9').value)
  end

  def test_not_found_with_multi
    exception = assert_raise(UnknownObjectException) do
      browser.button(:value => 'Click Me', :index => 2).name
    end
    assert_equal('Unable to locate element, using {:index=>2, :value=>"Click Me"}', 
      exception.message)
  end
end

class TC_Button_Frame < Test::Unit::TestCase
  location __FILE__ 

  def setup
    goto_page "frame_buttons.html"
  end

  def test_in_frame
    assert(browser.frame("buttonFrame").button(:caption, "Click Me").enabled?)
  end
  
  def test_error_in_frame
    assert_raises(UnknownObjectException) { browser.button(:caption, "Disabled Button").enabled?}  
  end
end


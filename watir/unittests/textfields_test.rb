# feature tests for Text Fields & Labels
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Fields < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "textfields1.html"
  end
  
  def test_text_field_exists
    assert($ie.text_field(:name, "text1").exists?)   
    assert(!$ie.text_field(:name, "missing").exists?)   
    
    assert($ie.text_field(:id, "text2").exists?)   
    assert(!$ie.text_field(:id, "alsomissing").exists?)   
    
    assert($ie.text_field(:beforeText, "This Text After").exists? )
    assert($ie.text_field(:afterText, "This Text Before").exists? )
    
    assert($ie.text_field(:beforeText, /after/i).exists? )
    assert($ie.text_field(:afterText, /before/i).exists? )
  end
  
  def test_text_field_dragContentsTo
    $ie.text_field(:name, "text1").dragContentsTo(:id, "text2")
    assert_equal($ie.text_field(:name, "text1").getContents, "") 
    assert_equal($ie.text_field(:id, "text2").getContents, "goodbye allHello World") 
  end
  
  def test_text_field_verify_contains
    assert($ie.text_field(:name, "text1").verify_contains("Hello World"))  
    assert($ie.text_field(:name, "text1").verify_contains(/Hello\sW/))  
    assert(!$ie.text_field(:name, "text1").verify_contains("Ruby"))  
    assert(!$ie.text_field(:name, "text1").verify_contains(/R/))  
    assert_raises(UnknownObjectException) { $ie.text_field(:name, "NoName").verify_contains("No field to get a value of") } 
    
    assert($ie.text_field(:id, "text2").verify_contains("goodbye all") )  
    assert_raises(UnknownObjectException) { $ie.text_field(:id, "noID").verify_contains("No field to get a value of") }          
  end
  
  def test_text_field_enabled
    assert(!$ie.text_field(:name, "disabled").enabled? )  
    assert($ie.text_field(:name, "text1").enabled? )  
    assert($ie.text_field(:id, "text2").enabled? )  
  end
  
  def test_text_field_readonly
    assert(!$ie.text_field(:name, "disabled").readonly? )  
    assert($ie.text_field(:name, "readOnly").readonly? )  
    assert($ie.text_field(:id, "readOnly2").readonly? )  
  end
  
  def test_text_field_get_contents
    assert_raises(UnknownObjectException) { $ie.text_field(:name, "missing_field").append("Some Text") }  
    assert_equal("Hello World", $ie.text_field(:name, "text1").getContents)  
  end
  
  def test_text_field_to_s
    expected = [
    build_to_s_regex("type", "text"),
    build_to_s_regex("id", ""),
    build_to_s_regex("name", "text1"),
    build_to_s_regex("value", "Hello World"),
    build_to_s_regex("disabled", "false"),
    build_to_s_regex("length", "20"),
    build_to_s_regex("max length", "20"),
    build_to_s_regex("read only", "false")
    ]
    items = $ie.text_field(:index, 1).to_s.split(/\n/)
    expected.each_with_index{|regex, x| assert_match(regex, items[x]) }
    expected[1] = build_to_s_regex("id", "text2")
    expected[2] = build_to_s_regex("name", "")
    expected[3] = build_to_s_regex("value", "goodbye all")
    expected[6] = build_to_s_regex("max length", "2147483647")  
      
    items = $ie.text_field(:index, 2).to_s.split(/\n/)
    expected.each_with_index{|regex, x| assert_match(regex, items[x]) }
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 999).to_s }  
  end
  
  def build_to_s_regex(lhs, rhs)
    Regexp.new("^#{lhs}: +#{rhs}$")
  end
  
  def test_text_field_append
    assert_raises(ObjectReadOnlyException) { $ie.text_field(:id, "readOnly2").append("Some Text") }  
    assert_raises(ObjectDisabledException) { $ie.text_field(:name, "disabled").append("Some Text") }  
    assert_raises(UnknownObjectException) { $ie.text_field(:name, "missing_field").append("Some Text") }  
    
    $ie.text_field(:name, "text1").append(" Some Text")
    assert_equal("Hello World Some Text", $ie.text_field(:name, "text1").getContents)  
  end
  
  def test_text_field_clear
    $ie.text_field(:name, "text1").clear
    assert_equal("", $ie.text_field(:name, "text1").getContents)  
  end
  
  def test_text_field_set
    $ie.text_field(:name, "text1").set("watir IE Controller")
    assert_equal("watir IE Controller" , $ie.text_field(:name, "text1").getContents)  
    # adding for issue: http://jira.openqa.org/browse/WTR-89
    $ie.text_field(:name, /reGex/i).set("pass")
    assert_equal("pass", $ie.text_field(:name, /REgEx/i).getContents)
  end
  
  def test_text_field_properties
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 199).value }  
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 199).name }  
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 199).id }  
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 199).disabled }  
    assert_raises(UnknownObjectException) { $ie.text_field(:index, 199).type }  
    
    assert_equal("Hello World" , $ie.text_field(:index, 1).value) 
    assert_equal("text"        , $ie.text_field(:index, 1).type)
    assert_equal("text1"       , $ie.text_field(:index, 1).name)
    assert_equal(""            , $ie.text_field(:index, 1).id)
    assert_equal(false         , $ie.text_field(:index, 1).disabled)
    
    assert_equal(""            , $ie.text_field(:index, 2).name)
    assert_equal("text2"       , $ie.text_field(:index, 2).id)
    
    assert($ie.text_field(:index, 4).disabled)
    
    assert_equal("This used to test :afterText", $ie.text_field(:name, "aftertest").title)
    assert_equal("", $ie.text_field(:index, 1).title)
    # adding for issue: http://jira.openqa.org/browse/WTR-89
    assert_equal("RegEx test", $ie.text_field(:name, /REgEx/i).value)
  end
  
  def test_text_field_iterators
    assert_equal(13, $ie.text_fields.length)
    
    # watir is 1 based, so this is the first text field
    assert_equal("Hello World" , $ie.text_fields[1].value)
    assert_equal("text1" , $ie.text_fields[1].name)
    assert_equal("password" , $ie.text_fields[$ie.text_fields.length].type)
    
    index = 1
    $ie.text_fields.each do |t|
      assert_equal($ie.text_field(:index, index).value, t.value) 
      assert_equal($ie.text_field(:index, index).id,    t.id)
      assert_equal($ie.text_field(:index, index).name,  t.name)
      index += 1
    end
    assert_equal(index - 1, $ie.text_fields.length)         
  end
  
  def test_JS_Events
    $ie.text_field(:name, 'events_tester').requires_typing.set('p')
    
    # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
    assert_equal( "keypresskeydownkeypresskeyup" , $ie.text_field(:name , 'events_text').value.gsub("\r\n" , "")  )
    $ie.button(:value , "Clear Events Box").click
    $ie.text_field(:name , 'events_tester').requires_typing.set('ab')
    
    # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
    assert_equal( "keypresskeydownkeypresskeyupkeydownkeypresskeyup" , $ie.text_field(:name , 'events_text').value.gsub("\r\n" , "") )
  end
  
  def test_password
    $ie.text_field(:name , "password1").set("secret")
    assert( 'secret' , $ie.text_field(:name , "password1").value )
    
    $ie.text_field(:id , "password1").set("top_secret")
    assert( 'top_secret' , $ie.text_field(:id, "password1").value )
  end
  
  def test_labels_iterator
    assert_equal(3, $ie.labels.length)
    assert_equal('Label For this Field' , $ie.labels[1].innerText.strip )
    assert_equal('Password With ID ( the text here is a label for it )' , $ie.labels[3].innerText )
    
    count=0
    $ie.labels.each do |l|
      count +=1
    end
    assert_equal(count, $ie.labels.length)
  end
  
  def test_label_properties
    assert_raises(UnknownObjectException) { $ie.label(:index,20).innerText } 
    assert_raises(UnknownObjectException) { $ie.label(:index,20).for } 
    assert_raises(UnknownObjectException) { $ie.label(:index,20).name } 
    assert_raises(UnknownObjectException) { $ie.label(:index,20).type } 
    assert_raises(UnknownObjectException) { $ie.label(:index,20).id } 
    
    assert(!$ie.label(:index,10).exists?) 
    assert(!$ie.label(:id,'missing').exists?) 
    assert($ie.label(:index,1).exists?) 
    
    assert_equal("", $ie.label(:index,1).id)
    assert(!    $ie.label(:index,1).disabled?) 
    assert(          $ie.label(:index,1).enabled?)
    
    assert_equal("label2", $ie.label(:index,2).id )
    
    assert_equal("Password With ID ( the text here is a label for it )" , $ie.label(:index,3).innerText)
    assert_equal("password1", $ie.label(:index,3).for)
  end

  def test_max_length_is_not_exceeded
    $ie.text_field(:name , 'text1').set("abcdefghijklmnopqrstuv")
    assert_equal("abcdefghijklmnopqrst", $ie.text_field(:name , 'text1').value )
  end

  def test_max_length
    assert_equal(20, $ie.text_field(:name , 'text1').maxLength )
  end
end
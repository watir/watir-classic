$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Fields_For_Chinese_Char < Test::Unit::TestCase
  
  def setup()
    use_page "textfields1.html"                 
  end
  
  def test_chinese_char_should_be_appended_to_text_field
    $ie.text_field(:name, "text1").append(" ĳĳ")
    assert_equal(  "Hello World ĳĳ" , $ie.text_field(:name, "text1").getContents )  
  end
  
  def test_mixed_char_should_be_appended_to_text_field
    $ie.text_field(:name, "text1").append(" ĳaĳa")
    assert_equal(  "Hello World ĳaĳa" , $ie.text_field(:name, "text1").getContents )  
  end
  
  def test_chinese_char_should_be_set_to_text_field
    $ie.text_field(:name, "text1").set("ĳĳ")
    assert_equal(  "ĳĳ" , $ie.text_field(:name, "text1").getContents )  
  end
  
  def test_mixed_char_should_be_set_to_text_field
    $ie.text_field(:name, "text1").set("ĳaĳa")
    assert_equal(  "ĳaĳa" , $ie.text_field(:name, "text1").getContents )  
  end
  
end
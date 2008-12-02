$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Fields_For_Chinese_Char < Test::Unit::TestCase
  
  def setup()
    goto_page "textfields1.html"                 
  end
  
  def test_chinese_char_should_be_appended_to_text_field
    browser.text_field(:name, "text1").append(" ĳĳ")
    assert_equal(  "Hello World ĳĳ" , browser.text_field(:name, "text1").value )  
  end
  
  def test_mixed_char_should_be_appended_to_text_field
    browser.text_field(:name, "text1").append(" ĳaĳa")
    assert_equal(  "Hello World ĳaĳa" , browser.text_field(:name, "text1").value )  
  end
  
  def test_chinese_char_should_be_set_to_text_field
    browser.text_field(:name, "text1").set("ĳĳ")
    assert_equal(  "ĳĳ" , browser.text_field(:name, "text1").value )  
  end
  
  def test_mixed_char_should_be_set_to_text_field
    browser.text_field(:name, "text1").set("ĳaĳa")
    assert_equal(  "ĳaĳa" , browser.text_field(:name, "text1").value )  
  end
  
end
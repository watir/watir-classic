# tests for textarea elements
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_TextArea < Test::Unit::TestCase
  include Watir
  
  def use_page page
    $ie.goto($htmlRoot + page)
  end

  def setup
    use_page 'textarea.html'
  end
  
  def test_elements_exist_or_not
    assert($ie.text_field(:name,"txtMultiLine1").exists?)
    assert($ie.text_field(:name,"txtMultiLine2").exists?)
    assert($ie.text_field(:name,"txtMultiLine3").exists?)
    assert($ie.text_field(:name,"txtReadOnly").exists?)
    
    assert($ie.text_field(:id,"txtMultiLine1").exists?)
    assert($ie.text_field(:id,"txtMultiLine2").exists?)
    assert($ie.text_field(:id,"txtMultiLine3").exists?)
    assert($ie.text_field(:id,"txtReadOnly").exists?)

    assert(!$ie.text_field(:name, "missing").exists?)   
    assert(!$ie.text_field(:name,"txtMultiLine4").exists?)
  end
  
  def test_to_s_bug
    # from a bug reported by Zeljko Filipin
    assert_nothing_raised { $ie.text_field(:id,"txtMultiLine3").to_s  }
  end
  
  def test_maxlength_bug
    # from another bug
    assert_nothing_raised { $ie.text_field(:id,"txtMultiLine3").append('foo')} 
  end
  
  def test_readonly_and_enabled
    assert(!$ie.text_field(:name, "txtMultiLine1").readonly? )  
    assert($ie.text_field(:name,"txtReadOnly").readonly?)
    
    assert(!$ie.text_field(:name, "txtDisabled").enabled? )  
    assert($ie.text_field(:id, "txtMultiLine1").enabled? )  
  end
  
  def test_verify_contains
    t1 = $ie.text_field(:name, "txtMultiLine1")
    assert(t1.verify_contains("Hello World") )  
    assert(t1.verify_contains(/el/) )  
    assert($ie.text_field(:name, "txtMultiLine2").verify_contains(/IE/))
  end
  
  def test_no_such_element
    assert_raises(UnknownObjectException) do
      $ie.text_field(:name, "NoName").verify_contains("de nada")
    end  
    assert_raises(UnknownObjectException) do
      $ie.text_field(:id, "noID").verify_contains("de nada")
    end
    assert_raises(UnknownObjectException) do
      $ie.text_field(:name, "txtNone").append("de nada")
    end  
  end
  def test_readonly_and_disabled_errors
    assert_raises(ObjectReadOnlyException) do
      $ie.text_field(:id, "txtReadOnly").append("de nada")
    end  
    assert_raises(ObjectDisabledException) do
      $ie.text_field(:name, "txtDisabled").append("de nada")
    end
    assert_raises(ObjectReadOnlyException) do
      $ie.text_field(:id, "txtReadOnly").append("Some Text")
    end
    assert_raises(ObjectDisabledException) do
      $ie.text_field(:name, "txtDisabled").append("Some Text")
    end
  end

  def test_append_set_and_clear
    $ie.text_field(:name, "txtMultiLine1").append(" Some Text")
    assert_equal("Hello World Some Text", 
      $ie.text_field(:name, "txtMultiLine1").getContents )  
    
    $ie.text_field(:name, "txtMultiLine1").set("watir IE Controller")
    assert_equal("watir IE Controller", 
      $ie.text_field(:name, "txtMultiLine1").getContents )  
    
    $ie.text_field(:name, "txtMultiLine2").clear
    assert_equal("" , $ie.text_field(:name, "txtMultiLine2").getContents )  
  end
  
end
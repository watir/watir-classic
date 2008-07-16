# feature tests for Javascript redirect
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Redirect < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "redirect.html")
  end
  
  def goto_multiple_redirect
    $ff.goto($htmlRoot + "redirect1.html")
  end

  def test_single_redirect
    assert_raises(UnknownObjectException) {$ff.div(:id , "div77").click }
    assert_raises(UnknownObjectException) {$ff.div(:title , "div77").click }
    
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
    $ff.div(:id , "div3").click
    assert($ff.text_field(:name, "text1").verify_contains("1") )  
    $ff.div(:id , "div4").click
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
  end
  
  def test_multiple_redirect
    goto_multiple_redirect()
    assert_raises(UnknownObjectException) {$ff.div(:id , "div77").click }
    assert_raises(UnknownObjectException) {$ff.div(:title , "div77").click }
    
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
    $ff.div(:id , "div3").click
    assert($ff.text_field(:name, "text1").verify_contains("1") )  
    $ff.div(:id , "div4").click
    assert($ff.text_field(:name, "text1").verify_contains("0") )  
  end
end

# feature tests for element and the elements collection

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Elements < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    uses_page "div.html"
  end
  
  def test_element
    assert_raises(UnknownObjectException) { browser.element(:id, "div77").click }
    assert_raises(UnknownObjectException) { browser.element(:title, "div77").click }
    assert_equal 'div2', browser.element(:class, 'blueText').id  
    assert_equal 'blueText', browser.element(:id, /div2/).class_name
    assert_equal Watir::HTMLElement, browser.element(:id, 'div2').class
  end
  
  def test_element_iterator
    assert_equal 3, browser.elements(:class, 'blueText').length
    assert_equal 3, browser.elements(:class, 'blueText').size
    assert_equal("span2", browser.elements(:class, 'blueText')[2].id)
    
    index = 1
    browser.elements(:id, /div/).each do |s|
      assert_equal(browser.div(:index,index).name, s.name)
      assert_equal(browser.div(:index,index).id, s.id)
      assert_equal(browser.div(:index,index).class_name , s.class_name)
      index += 1
    end
    assert_equal(index - 1, browser.elements(:id, /div/).length)   # -1 as we add 1 at the end of the loop
  end
  
  def test_element_enumerable
    match = browser.elements(:class, 'blueText').detect {|d| d.html =~ /SPAN/}
    assert_equal('span2', match.id)
  end
  
  def test_objects_in_element
    assert browser.element(:id, 'buttons1').button(:index,1).exists? 
    assert !browser.element(:id, 'buttons1').button(:index,3).exists? 
    assert browser.element(:id, 'buttons1').button(:name,'b1').exists? 
  end
  

end
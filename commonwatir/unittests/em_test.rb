$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Em < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "emphasis.html"
  end
  
  def test_exists
    assert browser.em(:id, "em-one").exists?, "Could not find <em> by :id"
    assert browser.em(:class, "em-class-one").exists?, "Could not find <em> by :class"
    assert browser.em(:xpath, "//em[@id='em-one']").exists?, "Could not find <em> by :xpath"
    assert browser.em(:index, 1).exists?, "Could not find <em> by :index"
  end
  
  def test_does_not_exist
    assert !browser.em(:id, 'no_such_id').exists?, "Found non-existing <em>"
  end
  
  def test_attribute_class_name
    assert_equal "em-class-one", browser.em(:id, "em-one").class_name
    assert_equal "", browser.em(:id, 'em-two').class_name
    assert_raises(UnknownObjectException) do
      browser.em(:id, 'no_such_id').class_name
    end
  end
  
  def test_attribute_id
    assert_equal "em-one", browser.em(:class, 'em-class-one').id
    assert_equal "", browser.em(:class, 'em-class-two').id
    assert_raises(UnknownObjectException) do
      browser.em(:id, 'no_such_id').id
    end
  end
  
  def test_attribute_title
    assert_equal "one", browser.em(:class, 'em-class-one').title
    assert_equal "", browser.em(:id, 'em-two').title
    assert_raises(UnknownObjectException) do
      browser.em(:id, 'no_such_id').title
    end
  end
  
  def test_attribute_text
    assert_equal  "one text", browser.em(:id, "em-one").text
    assert_equal "", browser.em(:class, 'em-class-two').text
    assert_raises(UnknownObjectException) do
      browser.em(:id, 'no_such_id').text
    end
  end
  
  def test_em_iterator
    assert_equal(3, browser.ems.length)
    assert_equal("two text", browser.ems[2].text)
    
    browser.ems.each_with_index do |em, idx|
      assert_equal browser.em(:index, idx+1).text, em.text
      assert_equal browser.em(:index, idx+1).id, em.id
      assert_equal browser.em(:index, idx+1).class_name, em.class_name
      assert_equal browser.em(:index, idx+1).title, em.title
    end
  end
    
end
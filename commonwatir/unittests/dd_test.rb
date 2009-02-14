$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Dd < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "definition_lists.html"
  end
  
  def test_exists
    assert browser.dd(:id, "someone").exists?, "Could not find <dd> by :id"
    assert browser.dd(:class, "name").exists?, "Could not find <dd> by :class"
    assert browser.dd(:xpath, "//dd[@id='someone']").exists?, "Could not find <dd> by :xpath"
    assert browser.dd(:index, 1).exists?, "Could not find <dd> by :index"
  end
  
  def test_does_not_exist
    assert !browser.dd(:id, 'no_such_id').exists?, "Found non-existing <dd>"
  end
  
  def test_attribute_class_name
    assert_equal "name", browser.dd(:id, "someone").class_name
    assert_equal "", browser.dd(:id, 'city').class_name
    assert_raises(UnknownObjectException) do
      browser.dd(:id, 'no_such_id').class_name
    end
  end
  
  def test_attribute_id
    assert_equal "someone", browser.dd(:class, 'name').id
    assert_equal "", browser.dd(:class, 'address').id
    assert_raises(UnknownObjectException) do
      browser.dd(:id, 'no_such_id').id
    end
  end
  
  def test_attribute_title
    assert_equal "someone", browser.dd(:class, 'name').title
    assert_equal "", browser.dd(:class, 'noop').title
    assert_raises(UnknownObjectException) do
      browser.dd(:id, 'no_such_id').title
    end
  end
  
  def test_attribute_text
    assert_equal  "John Doe", browser.dd(:id, "someone").text
    assert_equal "", browser.dd(:class, 'noop').text
    assert_raises(UnknownObjectException) do
      browser.dd(:id, 'no_such_id').text
    end
  end
  
  def test_dd_iterator
    assert_equal(11, browser.dds.length)
    assert_equal("education", browser.dds[2].title)
    
    browser.dds.each_with_index do |dd, idx|
      assert_equal(browser.dd(:index,idx+1).text, dd.text)
      assert_equal(browser.dd(:index,idx+1).id, dd.id)
      assert_equal(browser.dd(:index,idx+1).class_name , dd.class_name)
      assert_equal(browser.dd(:index,idx+1).title, dd.title)
    end
  end
    
end
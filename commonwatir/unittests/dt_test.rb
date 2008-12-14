$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Dt < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__
  
  def setup
    @html_dir = "#{File.dirname(__FILE__)}/html"
    uses_page "definition_lists.html"
  end
  
  def test_exists
    assert browser.dt(:id, "experience").exists?, "Could not find <dt> by :id"
    assert browser.dt(:class, "current-industry").exists?, "Could not find <dt> by :class"
    assert browser.dt(:xpath, "//dt[@id='experience']").exists?, "Could not find <dt> by :xpath"
    assert browser.dt(:index, 1).exists?, "Could not find <dt> by :index"
  end
  
  def test_does_not_exist
    assert !browser.dt(:id, 'no_such_id').exists?, "Found non-existing <dt>"
  end
  
  def test_attribute_class_name
    assert_equal "industry", browser.dt(:id, "experience").class_name
    assert_equal "", browser.dt(:id, 'education').class_name
    assert_raises(UnknownObjectException) do
      browser.dt(:id, 'no_such_id').class_name
    end
  end
  
  def test_attribute_id
    assert_equal "experience", browser.dt(:class, 'industry').id
    assert_equal "", browser.dt(:class, 'current-industry').id
    assert_raises(UnknownObjectException) do
      browser.dt(:id, 'no_such_id').id
    end
  end
  
  def test_attribute_title
    assert_equal "experience", browser.dt(:id, 'experience').title
    assert_equal "", browser.dt(:class, 'noop').title
    assert_raises(UnknownObjectException) do
      browser.dt(:id, 'no_such_id').title
    end
  end
  
  def test_attribute_text
    assert_equal  "Experience", browser.dt(:id, "experience").text
    assert_equal "", browser.dt(:class, 'noop').text
    assert_raises(UnknownObjectException) do
      browser.dt(:id, 'no_such_id').text
    end
  end
  
  def test_dts_iterator
    assert_equal(11, browser.dts.length)
    assert_equal("experience", browser.dts[1].id)
    
    browser.dts.each_with_index do |dt, idx|
      assert_equal(browser.dt(:index,idx+1).text, dt.text)
      assert_equal(browser.dt(:index,idx+1).id, dt.id)
      assert_equal(browser.dt(:index,idx+1).class_name , dt.class_name)
      assert_equal(browser.dt(:index,idx+1).title, dt.title)
    end
  end
    
end
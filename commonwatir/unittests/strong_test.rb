$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Strong < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    uses_page "phrase_elements.html"
  end
  
  def test_exists
    assert browser.strong(:id, "strong_id").exists?, "Could not find <strong> by :id"
    assert browser.strong(:class, "strong_class").exists?, "Could not find <strong> by :class"
    assert browser.strong(:xpath, "//strong[@id='strong_id']").exists?, "Could not find <strong> by :xpath"
    assert browser.strong(:index, 1).exists?, "Could not find <strong> by :index"
    assert browser.strong(:text, /this is a/).exists?, "Could not finr <strong> by :text"
  end
  
  def test_strong_iterator
    assert_equal(2, browser.strongs.length)
    assert_equal("this is a strong", browser.strongs[1].text)
    
    browser.strongs.each_with_index do |strong, idx|
      assert_equal(browser.strong(:index,idx+1).text, strong.text)
      assert_equal(browser.strong(:index,idx+1).id, strong.id)
      assert_equal(browser.strong(:index,idx+1).class_name , strong.class_name)
      assert_equal(browser.strong(:index,idx+1).title, strong.title)
    end
  end
    
end
# feature tests for attaching to existing IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_ExistingWindow < Test::Unit::TestCase
  include Watir

  def setup
    goto_page 'buttons1.html'
    @original_timeout = IE.attach_timeout
  end
  def teardown
    IE.attach_timeout = @original_timeout
  end

  def test_find_window
    ie = IE.find(:title, 'Test page for buttons')
    assert_equal("Test page for buttons", ie.title)
  end
  
  def test_find_window_misses
    ie = IE.find(:title, 'no such window')
    assert_nil ie
  end

  def test_missing_window
    IE.attach_timeout = 0.1
    assert_raises(NoMatchingWindowFoundException) { IE.attach(:title, "missing") }
    assert_raises(NoMatchingWindowFoundException) { IE.attach(:title, /missing/) }
    assert_raises(NoMatchingWindowFoundException) { IE.attach(:url, "missing") }
    assert_raises(NoMatchingWindowFoundException) { IE.attach(:url, /missing/) }
  end    
  
  def test_existing_window
    ie3 = nil
    ie3 = IE.attach(:title , /buttons/i)
    assert_equal("Test page for buttons", ie3.title)
    ie3 = nil
    
    ie3 = IE.attach(:title , "Test page for buttons")
    assert_equal("Test page for buttons", ie3.title)
    ie3 = nil
    
    ie3 = IE.attach(:url, /buttons1.html/)
    assert_equal("Test page for buttons", ie3.title)
    ie3 = nil
    
    #hard to test :url with explicit text
  end
end


# feature tests for white space

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_WhiteSpace < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "whitespace.html"
  end 

  def test_text_with_nbsp
    assert_equal 'Login', browser.link(:index => 1).text
  end

  def test_nbsp_beginning_and_end
    assert browser.link(:text, 'Login').exists?
  end
  
  def test_single_nbsp
    assert_equal "Test for nbsp.", browser.span(:id, 'single_nbsp').text
  end
  
  def test_multiple_spaces
    assert_equal "Test for multiple spaces.", browser.span(:id, 'multiple_spaces').text
  end
  
  def test_multiple_spaces_access
    assert_equal 'multiple_spaces', browser.span(:text, "Test for multiple spaces.").id
  end
  
  def test_space_tab
    assert_equal "Test for space and tab.", browser.span(:id, 'space_tab').text
  end
  
  def test_space_w_cr
    assert_equal "Test for space and cr.", browser.span(:id, 'space_w_cr').text
  end
end

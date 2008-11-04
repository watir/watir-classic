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

  def test_nbsp
    assert browser.link(:text, 'Login').exists?
  end
end

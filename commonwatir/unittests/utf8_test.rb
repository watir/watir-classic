# encoding: utf-8

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'base64'

class TC_Utf8 < Test::Unit::TestCase
  location __FILE__

  def setup
    uses_page "utf8.html"
  end

  def test_is_correct_encoding
    txt = browser.div(:id, 'utf8_string').text
    if RUBY_VERSION =~ /^1\.8/
      assert_equal("\303\246\303\270\303\245", txt)
    else
      assert(txt.force_encoding("UTF-8").valid_encoding?, "#{txt.inspect} is not valid UTF-8")
    end
  end

  def test_utf8_text_field_set
    utf8_str = 'w6ljb2xlIMOgIGxvbA=='
    browser.text_field(:id, 'input').set Base64.decode64(utf8_str)
    browser.button(:id, 'button').click
    assert_equal(utf8_str, browser.text_field(:id, 'output').value)
  end

  def test_utf8_text_field_value
    utf8_str = 'w6ljb2xlIMOgIGxvbA=='
    browser.text_field(:id, 'input').value = Base64.decode64(utf8_str)
    browser.button(:id, 'button').click
    assert_equal(utf8_str, browser.text_field(:id, 'output').value)
  end
end

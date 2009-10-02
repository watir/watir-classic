# encoding: utf-8

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

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

end



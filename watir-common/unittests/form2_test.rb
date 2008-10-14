$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Form_Entertainment < Test::Unit::TestCase
  location __FILE__
  def setup
    uses_page "entertainment_com.html"
  end
  def test_bare_button
    assert_nothing_raised do
      browser.button(:src, Regexp.new('/images/button_continue.gif')).click 
    end
  end

  # http://jira.openqa.org/browse/WTR-80
  tag_method :test_button_in_form, :fails_on_ie
  def test_button_in_form
    assert_nothing_raised do
      browser.form(:name, 'shipaddress').button(:src, Regexp.new('/images/button_continue.gif')).click 
    end
  end
end 
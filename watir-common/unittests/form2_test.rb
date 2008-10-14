$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Form_Entertainment < Test::Unit::TestCase
  location __FILE__
  tags :fails_on_ie, :fails_on_firefox  
  def setup
    uses_page "entertainment_com.html"
  end
  def test_button_in_form
    assert_nothing_raised do
      browser.form(:name, 'shipaddress').button(:src, 'https://www.entertainment.com/images/button_continue.gif').click 
    end
  end
end 
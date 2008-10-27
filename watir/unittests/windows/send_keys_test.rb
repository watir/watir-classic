# feature tests for IE#send_keys
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Fields < Test::Unit::TestCase
  def setup
    goto_page "textfields1.html"
  end
  
  def test_tabbing
    browser.text_field(:name, 'text1').focus
    browser.send_keys('{tab}')
    browser.send_keys('Scooby')
    assert('Scooby', browser.text_field(:name, 'beforetest').value)
  end
  
  def test_enter
    browser.text_field(:name, 'text1').focus
    browser.send_keys('{tab}{tab}{tab}{tab}{tab}')
    browser.send_keys('Dooby{enter}')
    sleep 0.2
    assert(browser.text.include?('PASS'))
  end
  
  def test_autoregistration
    Watir::_unregister('AutoItX3.dll')
    assert_raises(WIN32OLERuntimeError) { WIN32OLE.new('AutoItX3.Control') }
    assert_nothing_raised { browser.send_keys('{tab}') }
  end    
end

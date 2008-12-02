# feature tests for Goto
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_error_checker < Test::Unit::TestCase
    
  def test_simple_checker
    button_checker = Proc.new do |ie|  
      raise RuntimeError, "text 'buttons' is missing"  if ! ie.contains_text(/buttons/)
    end
    
    browser.add_checker button_checker
    assert_raises( RuntimeError ) { goto_page('forms3.html') }
    assert_nothing_raised { goto_page('buttons1.html') }
    
    browser.disable_checker button_checker
    assert_nothing_raised { goto_page('forms3.html') }
  end
  
end

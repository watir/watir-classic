# feature tests for Goto
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_error_checker< Test::Unit::TestCase
  include Watir
  
  def goto_page(page)
    $ie.goto($htmlRoot + page)
  end
  
  def test_simple_checker
    button_checker = Proc.new{
      |ie|  raise RuntimeError, "text 'buttons' was missing"  if !ie.pageContainsText(/buttons/)
    }
    
    $ie.add_checker(button_checker )
    assert_raises( RuntimeError ) { goto_page('forms3.html') }
    assert_nothing_raised { goto_page('buttons1.html') }
    
    $ie.disable_checker( button_checker )
    assert_nothing_raised { goto_page('forms3.html') }
    
  end
  
  
end

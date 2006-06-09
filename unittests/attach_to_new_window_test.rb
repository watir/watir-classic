# feature tests for attaching to new IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/testcase'

class TC_NewWindow< Watir::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "new_browser.html")
    IE.attach_timeout = 0.2
  end
  def teardown
    IE.attach_timeout = 0.2
  end
  
  def test_simply_attach_to_new_window
    $ie.link(:text, 'New Window').click
    ie_new = IE.attach(:title, 'Pass Page')
    assert(ie_new.text.include?('PASS'))
    ie_new.close
  end
  
  def test_attach_to_new_window_using_separate_process
    $ie.eval_in_spawned_process "link(:text, 'New Window').click"
    IE.attach_timeout = 2.0
    ie_new = IE.attach(:title, 'Pass Page')
    assert(ie_new.text.include?('PASS'))
    ie_new.close
  end
  
  def test_attach_to_new_window_using_click_no_wait
    $ie.link(:text, 'New Window').click_no_wait
    IE.attach_timeout = 2.0
    ie_new = IE.attach(:title, 'Pass Page')
    assert(ie_new.text.include?('PASS'))
    ie_new.close
  end
  
  def test_click_no_wait_works_in_a_container
    $ie.p(:index, 1).link(:text, 'New Window').click_no_wait
    IE.attach_timeout = 2.0
    ie_new = IE.attach(:title, 'Pass Page')
    assert(ie_new.text.include?('PASS'))
    ie_new.close
  end
  
  def test_attach_to_slow_window_works_with_delay
    $ie.span(:text, 'New Window Slowly').click
    sleep 0.8
    ie_new = IE.attach(:title, 'Test page for buttons')
    assert(ie_new.text.include?('Blank page to fill in the frames'))
    ie_new.close
  end    
  
  def test_attach_to_slow_window_works_without_waiting
    $ie.span(:text, 'New Window Slowly').click
    IE.attach_timeout = 3.0
    ie_new = IE.attach(:title, 'Test page for buttons')
    assert(ie_new.text.include?('Blank page to fill in the frames'))
    ie_new.close
  end    
  
  def test_attach_timesout_when_window_takes_too_long
    $ie.text_field(:name, 'delay').set('2')
    $ie.span(:text, 'New Window Slowly').click
    assert_raise(Watir::Exception::NoMatchingWindowFoundException) do
      IE.attach(:title, 'Test page for buttons')
    end
    sleep 2.0 # clean up
    IE.attach(:title, 'Test page for buttons').close
  end        
  
end

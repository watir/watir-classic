# tests of click_no_wait for links in frames
# revision: $Revision: 1078 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Frame_Links < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "frame_links.html")
  end
  
  def test_click_in_a_frame
    $ie.frame('linkFrame').link(:text, 'test1').click
    assert($ie.frame('linkFrame').text.include?('Links2-Pass'))
  end
  
  def test_click_no_wait_in_a_frame
    $ie.frame('linkFrame').link(:text, 'test1').click_no_wait
    wait_until(2){$ie.frame('linkFrame').text.include?('Links2-Pass')}
    assert($ie.frame('linkFrame').text.include?('Links2-Pass'))
  end  
  
end

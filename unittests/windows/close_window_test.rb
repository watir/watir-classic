# feature tests for closed windows
# revision: $Revision: 958 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') if $0 == __FILE__
require 'unittests/setup'

class TC_CloseWindow < Watir::TestCase
  execute :sequentially
  
  def setup
    $ie.goto($htmlRoot + "new_browser.html")
  end
  
  # reproduces defect http://jira.openqa.org/browse/WTR-16
  def test_close_window_with_button
    $ie.link(:text, 'New Window').click
    ie_new = Watir::IE.attach(:title, 'Pass Page')
    assert(ie_new.text.include?('PASS'))
    assert_nothing_raised {ie_new.close}
  end
end
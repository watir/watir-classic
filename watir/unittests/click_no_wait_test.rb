$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class ClickNoWait_Tests < Watir::TestCase

  def setup
    goto_page 'click_no_wait.html'
  end

  def test_click_no_wait
    message_div = browser.div(:id => 'div1')
    assert_equal("nothing", message_div.text)
    browser.link(:id => 'link1').click_no_wait
    assert_equal("message!", message_div.text)
  end

  def test_spawned_click_no_wait_command
    assert_equal("start rubyw -e \"some command\"", browser.link(:id => 'link1').send(:__spawned_no_wait_command, "some command"))
  end

end

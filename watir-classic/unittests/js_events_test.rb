# feature tests for JavaScript events

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_JSEvents < Test::Unit::TestCase
  def setup
    goto_page "javascriptevents.html"
  end

  def test_keyboard_event
    browser.text_field(:index, 0).fire_event("onkeyup")
    assert(browser.div(:id, 'event_name').text == 'onkeyup')
  end

  def test_mouse_event
    browser.text_field(:index, 0).fire_event("onmouseup")
    assert(browser.div(:id, 'event_name').text == 'onmouseup')
  end

  def test_html_event
    browser.select_list(:index, 0).fire_event("onchange")
    assert(browser.div(:id, 'event_name').text == 'onchange')
  end

  def test_execute_script
    assert_equal(browser.execute_script("2+2").to_i, 4)
    assert_nil(browser.execute_script("null"))
  end

end

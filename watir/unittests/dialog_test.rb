# Feature tests for Dialog class

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Dialog_Test < Test::Unit::TestCase
  tags :must_be_visible
  include Watir
  
  def setup
    goto_page 'JavascriptClick.html'
  end    
  def teardown
    begin 
      javascript_dialog.button("OK").click
    rescue
    end
  end
  
  def test_alert_without_bonus_script
    browser.button(:id, 'btnAlert').click_no_wait
    javascript_dialog.button("OK").click
    assert_match(/Alert button!/, browser.text_field(:id, "testResult").value)
  end

  def test_button_name_not_found
    browser.button(:id, 'btnAlert').click_no_wait
    assert_raises(::RAutomation::UnknownButtonException) {javascript_dialog.button("Yes").click}
    javascript_dialog.button("OK").click
  end

  def test_exists
    assert_false(javascript_dialog.exists?)
    browser.button(:id, 'btnAlert').click_no_wait
    Watir::Wait.until(5) {javascript_dialog.exists?}
    javascript_dialog.button("OK").click
  end

  def test_leaves_dialog_open
    # should be closed in teardown
    browser.button(:id, 'btnAlert').click_no_wait
  end

  def test_copy_array_elements
    a = ['a', 'b', 'c']
    copy = Array.new(a)
    c = []
    code = _code_that_copies_readonly_array(a, "c")
    eval code
    assert_equal copy, c
  end

  def test_confirm_ok
    browser.button(:value, 'confirm').click_no_wait
    Watir::Wait.until(5) {javascript_dialog.exists?}
    javascript_dialog.button("OK").click
    assert_equal "You pressed the Confirm and OK button!", browser.text_field(:id, 'testResult').value
  end

  def xtest_confirm_cancel
    browser.button(:value, 'confirm').click_no_wait
    assert javascript_dialog.exists?
    javascript_dialog.button("Cancel").click
    assert_equal "You pressed the Confirm and Cancel button!", browser.text_field(:id, 'testResult').value
  end

  def test_dialog_close
    javascript_dialog.close
    assert !javascript_dialog.exists?
  end
  
end
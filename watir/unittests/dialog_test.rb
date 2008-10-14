# Feature tests for Dialog class
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/dialog'

class TC_Dialog_Test < Test::Unit::TestCase
  tags :must_be_visible
  include Watir
  
  def setup
    goto_page 'JavascriptClick.html'
  end    
  def teardown
    begin 
      sleep 0.4 # XXX 
      dialog.button('OK').click
    rescue
    end
  end
  
  def test_alert_without_bonus_script
    $ie.button(:id, 'btnAlert').click_no_wait
    sleep 0.4 # FIXME: need to be able to poll for window to exist
    dialog.button("OK").click
    assert_match(/Alert button!/, $ie.text_field(:id, "testResult").value)  
  end
  
  def test_button_name_not_found
    $ie.button(:id, 'btnAlert').click_no_wait
    sleep 0.4 # FIXME replace with dialog.exists?
    assert_raises(UnknownObjectException) { dialog.button("Yes").click }
    dialog.button("OK").click
  end
  
  def xtest_exists
    autoit = WIN32OLE.new('AutoItX3.Control')
    assert_false( dialog.exists?) # known bug: finds main window instead of dialog!
    $ie.button(:id, 'btnAlert').click_no_wait
    sleep 0.4 # FIXME: need to add polling
    assert dialog.exists?
    dialog.button('OK').click
  end
  
  def test_leaves_dialog_open
    # should be closed in teardown
    $ie.button(:id, 'btnAlert').click_no_wait
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
    $ie.button(:value, 'confirm').click_no_wait
    assert dialog.exists?
    dialog.button('OK').click
    assert_equal "You pressed the Confirm and OK button!", $ie.text_field(:id, 'testResult').value
  end
  
  def xtest_confirm_cancel
    $ie.button(:value, 'confirm').click_no_wait
    assert dialog.exists?
    dialog.button('Cancel').click
    assert_equal "You pressed the Confirm and Cancel button!", $ie.text_field(:id, 'testResult').value
  end
  
  def test_dialog_close
    dialog.close
    assert !dialog.exists? 
  end
  
end
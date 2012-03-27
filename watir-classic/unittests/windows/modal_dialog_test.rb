# feature tests for modal web dialog support

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir-classic/close_all'

class TC_ModalDialog < Watir::TestCase
  include Watir
  
  def setup
    @original_timeout = IE.attach_timeout
    goto_page 'modal_dialog_launcher.html'
    IE.attach_timeout = 10.0
  end

  def teardown
    if browser
      while browser.modal_dialog.exists?(0) do
        browser.modal_dialog.close
        sleep 0.5
      end
    end
  end


  def test_modal_simple_use_case
    browser.button(:value, 'Launch Dialog').click_no_wait
    modal = browser.modal_dialog

    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', browser.text_field(:name, 'modaloutput').value)
  end

  def test_wait_should_not_block
    browser.button(:value, 'Launch Dialog').click_no_wait
    modal = browser.modal_dialog

    modal.text_field(:name, 'modal_text').set('hello')
    modal.wait

    modal.button(:value, 'Close').click
  end

  def test_modal_dialog_use_case_default
    browser.button(:value, 'Launch Dialog').click_no_wait

    modal = browser.modal_dialog
    assert_not_nil modal

    # Make sure that we have attached to modal and that the hwnd method
    # is working properly to show the HWND of our parent.
    assert_not_equal(browser.hwnd, modal.hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    assert !browser.modal_dialog.exists?
    assert_equal('hello', browser.text_field(:name, 'modaloutput').value)
  end

  def test_double_modal
    browser.button(:value, 'Launch Dialog').click_no_wait
    browser.modal_dialog.button(:text, 'Another Modal').click_no_wait
    assert_nothing_raised {
      Watir::Wait.until {browser.modal_dialog.title == 'Pass Page'}
    }
    browser.modal_dialog.close
    browser.modal_dialog.close
  end

  def xtest_modal_with_frames
    browser.button(:value, 'Launch Dialog').click_no_wait
    modal1 = browser.modal_dialog
    modal1.button(:value, 'Modal with Frames').click_no_wait
    modal2 = browser.modal_dialog
    modal2.frame('buttonFrame').button(:value, 'Click Me').click
    assert(modal2.frame('buttonFrame').text.include?('PASS'))
    modal2.frame('buttonFrame').button(:value, 'Close Window').click
    modal1.close
  end

  def test_modal_exists
    browser.button(:value, 'Launch Dialog').click_no_wait
    modal = browser.modal_dialog
    assert(modal.exists?)
    modal.button(:value, 'Close').click
    assert_false(modal.exists?)
  end

end

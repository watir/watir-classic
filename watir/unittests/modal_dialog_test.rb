# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ModalDialog < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
  end

  def teardown
    if $ie and $ie.enabled_popup(0)
      modal = $ie.modal_dialog
      modal.document.parentWindow.close if modal
    end
  end

  def test_modal_use_case
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.attach_modal('Modal Dialog')

    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  def test_wait_should_not_block
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.attach_modal('Modal Dialog')

    modal.text_field(:name, 'modal_text').set('hello')
    modal.wait

    modal.button(:value, 'Close').click
  end

  # Using the modal_dialog method the default "how" is :hwnd which
  # lets us guarantee we attach to the correct IE instance.
  def test_modal_dialog_use_case_default
    $ie.button(:value, 'Launch Dialog').click_no_wait

    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog

    # Make sure that we have attached to modal and that the hwnd method
    # is working properly to show the HWND of our parent.
    assert_not_equal($ie.hwnd, modal.hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    # Assert that we no longer have any popups
    assert_nil($ie.enabled_popup(1))
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :hwnd parameter.
  def test_modal_dialog_use_case_hwnd
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog(:hwnd)

    # Make sure that we have attached to modal and that the hwnd method
    # is working properly to show the HWND of our parent.
    assert_not_equal($ie.hwnd, modal.hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    # Assert that we no longer have any popups
    assert(!$ie.enabled_popup(1))
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :title parameter.
  def test_modal_dialog_use_case_title
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog(:title, 'Modal Dialog')

    # Make sure that we have attached to modal and that the hwnd method
    # is working properly to show the HWND of our parent.
    assert_not_equal($ie.hwnd, modal.hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    # Assert that we no longer have any popups
    assert(!$ie.enabled_popup(1))
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :title parameter with regexp match
  def xtest_modal_dialog_use_case_title_regexp
    $ie.button(:value, 'Launch Dialog').click_no_wait
    # Test that enabled_popup sees a popup window.
    assert_not_nil($ie.enabled_popup)

    modal = $ie.modal_dialog(:title, /dal Dia/)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    # Assert that we no longer have any popups
    assert(!$ie.enabled_popup(1))
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply an invalid "how" value
  def test_modal_dialog_use_case_invalid
    $ie.button(:value, 'Launch Dialog').click_no_wait
    assert_raise(ArgumentError) { modal = $ie.modal_dialog(:esp) }

    # Now close modal to clean up
    $ie.modal_dialog.button(:value, 'Close').click
  end
end
# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ModalDialog < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
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
    modal = $ie.modal_dialog

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :hwnd parameter.
  def test_modal_dialog_use_case_hwnd
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :title parameter.
  def test_modal_dialog_use_case_title
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:title, 'Modal Dialog')

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :title parameter with regexp match
  def test_modal_dialog_use_case_title_regexp
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:title, /dal Dia/)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
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
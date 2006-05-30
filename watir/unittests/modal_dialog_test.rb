# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ModalDialog < Watir::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
  end

  def xteardown # XXX need to improve timeout logic
    if $ie 
      begin
        modal = $ie.modal_dialog
        modal.close if modal 
      rescue TimeOutException, NoMatchingWindowFoundException 
      end
    end
  end

  def assert_no_modals
    IE.attach_timeout = 0.2 
    begin
      assert_raises(NoMatchingWindowFoundException) do
        $ie.modal_dialog
      end
    ensure
      IE.attach_timeout = 2.0
    end
  end 
     
  def test_modal_simple_use_case
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:title, 'Modal Dialog')

    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  def test_wait_should_not_block
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:title, 'Modal Dialog')

    modal.text_field(:name, 'modal_text').set('hello')
    modal.wait

    modal.button(:value, 'Close').click
  end

  def test_modal_dialog_use_case_default
    $ie.button(:value, 'Launch Dialog').click_no_wait

    modal = $ie.modal_dialog
    assert_not_nil modal

    # Make sure that we have attached to modal and that the hwnd method
    # is working properly to show the HWND of our parent.
    assert_not_equal($ie.hwnd, modal.hwnd)

    # Once attached just treat the modal_dialog like any IE or Frame
    # object.
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click

    assert_no_modals
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # Now explicitly supply the :title parameter.
  def test_modal_dialog_use_case_title
    $ie.button(:value, 'Launch Dialog').click_no_wait

    modal = $ie.modal_dialog(:title, 'Modal Dialog')
    assert_not_equal($ie.hwnd, modal.hwnd)

    assert_equal('Modal Dialog', modal.title)

    assert(modal.text.include?('Enter some text:'))
    modal.button(:value, 'Close').click
  end

  # Now explicitly supply the :title parameter with regexp match
  def test_modal_dialog_use_case_title_regexp
    assert_raises(ArgumentError){$ie.modal_dialog(:title, /dal Dia/)}
  end

  # Now explicitly supply an invalid "how" value
  def test_modal_dialog_use_case_invalid
    assert_raise(ArgumentError) { $ie.modal_dialog(:esp) }
  end
end
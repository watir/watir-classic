# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'watir/close_all'

if VERSION == '1.8.2'
class TC_ModalDialog < Watir::TestCase
  include Watir
  
  def setup
    goto_page 'modal_dialog_launcher.html'
  end

  def teardown 
    if $ie 
      while $ie.close_modal do; end
    end
    sleep 0.1
  end

  def assert_no_modals
    IE.attach_timeout = 0.2 
    begin
      assert_raises(NoMatchingWindowFoundException) do
        $ie.modal_dialog
      end
    ensure
      IE.reset_attach_timeout
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

  def test_double_modal
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal1 = $ie.modal_dialog
    modal1.button(:text, 'Another Modal').click_no_wait
    modal2 = modal1.modal_dialog
    assert_equal modal2.title, 'Pass Page'
    modal2.close
    modal1.close
  end
  
  def xtest_modal_with_frames
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal1 = $ie.modal_dialog
    modal1.button(:value, 'Modal with Frames').click_no_wait
    modal2 = $ie.modal_dialog
    modal2.frame('buttonFrame').button(:value, 'Click Me').click
    assert(modal2.frame('buttonFrame').text.include?('PASS'))    
    modal2.frame('buttonFrame').button(:value, 'Close Window').click
    modal1.close
  end
  
  def test_modal_exists
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = $ie.modal_dialog(:title, 'Modal Dialog')
    assert(modal.exists?)
    modal.button(:value, 'Close').click
    assert_false(modal.exists?)
  end
        
end
end
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


end
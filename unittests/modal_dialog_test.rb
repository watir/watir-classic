# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'watir/dialog'

class TC_ModalDialog < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "modal_dialog_launcher.html")
  end
  
  def test_modal_use_case
    $ie.eval_in_spawned_process "button(:value, 'Launch Dialog').click"
    modal = IE.attach(:title, 'Modal Dialog')
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end
end
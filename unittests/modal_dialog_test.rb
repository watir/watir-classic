# feature tests for modal web dialog support
# revision: $Revision$

# Use our modified win32ole library
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'watir', 'win32ole')
require 'win32ole'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'Win32API'

class TC_ModalDialog < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + 'modal_dialog_launcher.html')
  end
  
  def test_modal_use_case
    $ie.button(:value, 'Launch Dialog').click_no_wait
    modal = IE.attach_modal('Modal Dialog -- Web Page Dialog')

    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

end

class ModalPage < Watir::IE
  def initialize(document)
    @document = document
    set_fast_speed
    @ie = $ie.ie
    @url_list = []
    @error_checkers = []
  end  
  def document
    return @document
  end
end
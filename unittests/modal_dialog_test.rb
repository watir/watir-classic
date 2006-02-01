# feature tests for modal web dialog support
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'
require 'Win32API'

class TC_ModalDialog < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "modal_dialog_launcher.html")
  end
  
  def test_modal_use_case
    $ie.button(:value, 'Launch Dialog').click_no_wait
    sleep 0.4
    modal = attach_modal(:title, 'Modal Dialog')
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end
  
  def attach_modal(attribute, title)
    dll_path = "#{@@dir}/watir/IEDialog/Release/IEDialog.dll".gsub('/', '\\')
    fnGetUnknown = Win32API.new(dll_path, 'GetUnknown', ['p', 'p'], 'v')
    intPointer = " " * 4	#will contain the int value of the IUnknown*
    fnGetUnknown.call(title, intPointer)  
    
    intArray = intPointer.unpack('L')
    intUnknown = intArray.first
    puts intUnknown
    
    htmlDoc = WIN32OLE.connect_unknown(intUnknown);
  end
end
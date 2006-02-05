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
    sleep 1
    modal = attach_modal('Modal Dialog -- Web Page Dialog')
    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # this will find the IEDialog.dll file in its build location
  @@iedialog_file = (File.expand_path(File.dirname(__FILE__)) + "/../watir/IEDialog/Release/IEDialog.dll").gsub('/', '\\')

  def attach_modal(title)
    fnFindWindowEx = Win32API.new('user32.dll', 'FindWindowEx', ['l', 'l', 'p', 'p'], 'l')
    hwnd_modal = fnFindWindowEx.call(0, 0, nil, title)
    assert(hwnd_modal > 0)
     
    fnGetUnknown = Win32API.new(@@iedialog_file, 'GetUnknown', ['l', 'p'], 'v')
    intPointer = " " * 4 # will contain the int value of the IUnknown*
    fnGetUnknown.call(hwnd_modal, intPointer)
    
    intArray = intPointer.unpack('L')
    intUnknown = intArray.first
    assert(intUnknown > 0)
    
    htmlDoc = WIN32OLE.connect_unknown(intUnknown)    
    ModalPage.new(htmlDoc)
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
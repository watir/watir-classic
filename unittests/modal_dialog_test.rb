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
    modal = attach_modal('Modal Dialog -- Web Page Dialog')

    assert(modal.text.include?('Enter some text:'))
    modal.text_field(:name, 'modal_text').set('hello')
    modal.button(:value, 'Close').click
    assert_equal('hello', $ie.text_field(:name, 'modaloutput').value)
  end

  # this will find the IEDialog.dll file in its build location
  @@iedialog_file = (File.expand_path(File.dirname(__FILE__)) + "/../watir/IEDialog/Release/IEDialog.dll").gsub('/', '\\')
  @@fnFindWindowEx = Win32API.new('user32.dll', 'FindWindowEx', ['l', 'l', 'p', 'p'], 'l')
  @@fnGetUnknown = Win32API.new(@@iedialog_file, 'GetUnknown', ['l', 'p'], 'v')

  def attach_modal(title)
    hwnd_modal = 0
    until_with_timeout(10) do
      hwnd_modal = @@fnFindWindowEx.call(0, 0, nil, title)
      hwnd_modal > 0
    end
     
    intPointer = " " * 4 # will contain the int value of the IUnknown*
    @@fnGetUnknown.call(hwnd_modal, intPointer)
    
    intArray = intPointer.unpack('L')
    intUnknown = intArray.first
    assert(intUnknown > 0)
      
    htmlDoc = WIN32OLE.connect_unknown(intUnknown)    
    ModalPage.new(htmlDoc)
  end

  def until_with_timeout(timeout) # block
    start_time = Time.now
    until yield or Time.now - start_time > timeout do
      sleep 0.05
    end
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
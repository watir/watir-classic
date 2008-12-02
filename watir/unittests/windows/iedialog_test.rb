# unit tests for iedialog.dll and customized win32ole.so
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'unittests/setup'
require 'Win32API'

class TC_IEDialog < Test::Unit::TestCase
  include Watir 

  # this will find the IEDialog.dll file in its build location
  @@iedialog_file = (File.expand_path(File.dirname(__FILE__)) + "/../../lib/watir/IEDialog/Release/IEDialog.dll").gsub('/', '\\')
  
  # commented out because it currently requires a manual click
  # a better idea would be to automate the click...
  def xtest_connect_to_iedialog 
    # make sure we can connect to the IEDialog.dll
    fnShowString = Win32API.new(@@iedialog_file, 'ShowString', ['p'], 'v')
    fnShowString.call("from ruby!") # blocks
  end

  def test_find_window   
    goto_page "pass.html"
    fnFindWindow = Win32API.new('user32.dll', 'FindWindow', ['p', 'p'], 'l')
    hwnd = fnFindWindow.call(nil, "Pass Page - Microsoft Internet Explorer")
    assert(hwnd != 0)
  end

  def test_all    
    goto_page "pass.html"

    fnFindWindow = Win32API.new('user32.dll', 'FindWindow', ['p', 'p'], 'l')
    hwnd = fnFindWindow.call(nil, "Pass Page - Microsoft Internet Explorer")

    fnGetUnknown = Win32API.new(@@iedialog_file, 'GetUnknown', ['l', 'p'], 'v')
    intPointer = " " * 4 # will contain the int value of the IUnknown*
    fnGetUnknown.call(hwnd, intPointer)
    
    intArray = intPointer.unpack('L')
    intUnknown = intArray.first

    assert(intUnknown > 0)
    
    htmlDoc = nil
    assert_nothing_raised{htmlDoc = WIN32OLE.connect_unknown(intUnknown)}
    scriptEngine = htmlDoc.Script
    
    # now we get the HTML DOM object!
    doc2 = scriptEngine.document
    body = doc2.body
    assert_match(/^PASS/, body.innerHTML.strip)    
  end
end


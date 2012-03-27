$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')
require 'Win32API'
require 'unittests/setup'

# This test makes sure that the win32ole changes will return
# the dom using GetUnknown, which is added via the win32ole patch
class TC_Win32OLE < Test::Unit::TestCase

  def setup
    # this will find the IEDialog.dll file in its build location
    @iedialog_file = (File.expand_path(File.dirname(__FILE__)) + "/../lib/watir-classic/IEDialog/Release/IEDialog.dll").gsub('/', '\\')

    @ie = Watir::IE.new
    @ie.goto 'www.google.com'
  end

  def teardown
    @ie.close
  end

  def test_win32ole_modifications
    fnGetUnknown = Win32API.new(@iedialog_file, 'GetUnknown', ['p', 'p'], 'v')
    intPointer = " " * 4 # will contain the int value of the IUnknown*
    fnGetUnknown.call(@ie.hwnd, intPointer)
    assert_true intPointer
    intArray = intPointer.unpack('L')
    intUnknown = intArray.first
    htmlDoc = WIN32OLE.connect_unknown(intUnknown);
    scriptEngine = htmlDoc.Script

    # now we get the HTML DOM object!
    body =  scriptEngine.document.body
    assert(body.innerHTML =~ /html/)
  end
end

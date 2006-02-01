require 'Win32API'
require 'win32ole'
 
#test, make sure we can connect to the IEDialog.dll
fnShowString = Win32API.new('IEDialog', 'ShowString', ['p'], 'v')
fnShowString.call("from ruby!") 


ie = WIN32OLE.new('InternetExplorer.Application')
ie.visible = true
 
#my home page is google
ie.gohome
 
webbrowser = ie.Application
 
#wait for google page to be displayed
puts webbrowser.Busy
sleep(5)
puts webbrowser.Busy

fnGetUnknown = Win32API.new('IEDialog', 'GetUnknown', ['p', 'p'], 'v')

intPointer = " " * 4	#will contain the int value of the IUnknown*
fnGetUnknown.call("Google - Microsoft Internet Explorer", intPointer)

intArray = intPointer.unpack('L')
intUnknown = intArray.first
puts intUnknown

htmlDoc = WIN32OLE.connect_unknown(intUnknown);
puts htmlDoc

scriptEngine = htmlDoc.Script
puts scriptEngine

#now we get the HTML DOM object!
doc2 = scriptEngine.document
puts doc2

body = doc2.body
puts body.innerHTML



#
#  clickJSDialog.rb 
#
#
# This file contains the JS clicker when it runs as a separate process

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
puts $LOAD_PATH
require 'watir/winClicker'

button = "OK"
button = ARGV[0] unless ARGV[0] == nil
sleepTime = 0
sleepTime = ARGV[1] unless ARGV[1] == nil


clicker= WinClicker.new
result = clicker.clickJavaScriptDialog( button )
clicker = nil

#
#  clickJSDialog.rb 
#
#
# This file contains the JS clicker when it runs as a seperate process

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

puts $LOAD_PATH


require 'winClicker'
button = "OK"
button = ARGV[0] unless ARGV[0] == nil
sleepTime = 0
sleepTime = ARGV[1] unless ARGV[1] == nil


clicker= WinClicker.new
result = clicker.clickJavaScriptDialog( button )
clicker = nil

# write what happened to a temp file
#fileName ENV["temp"]
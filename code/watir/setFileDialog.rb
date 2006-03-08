#
#  setFileDialog.rb 
#
#
# This file contains the file dialog when it runs as a separate process

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '..'))
puts $LOAD_PATH
require 'watir/winClicker'

filepath = "invalid path passed to setFileDialog.rb"
filepath = ARGV[0] unless ARGV[0] == nil

title = ARGV[1] unless ARGV[1] == nil
clicker= WinClicker.new
clicker.setFileRequesterFileName(filepath, title)
clicker = nil

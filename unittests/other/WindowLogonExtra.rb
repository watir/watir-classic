$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__

require 'watir/WindowHelper'


helper = WindowHelper.new
helper.logon('Connect to clio.lyris.com')
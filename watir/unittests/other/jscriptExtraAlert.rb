$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib') 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'commonwatir', 'lib') 

require 'watir/WindowHelper'

helper = WindowHelper.new
helper.push_alert_button
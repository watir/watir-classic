$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib') 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'watir-common', 'lib') 

require 'watir/WindowHelper'

helper = WindowHelper.new
helper.push_alert_button
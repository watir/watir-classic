$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib') 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'watir-common', 'lib') 
require 'watir'

ie = Watir::IE.attach(:title, 'Alert Test')
ie.button(:id, 'btnAlert').click

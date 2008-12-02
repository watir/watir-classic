$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', 'lib') 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..', '..', 'commonwatir', 'lib') 
require 'watir'

ie = Watir::IE.attach(:title, 'Alert Test')
ie.button(:id, 'btnAlert').click

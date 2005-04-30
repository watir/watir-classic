$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'watir'

ie = Watir::IE.attach(:title, 'Alert Test')
ie.button(:id, 'btnAlert').click

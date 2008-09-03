$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED
require 'watir'

ie = Watir::IE.attach(:title, 'Alert Test')
ie.button(:id, 'btnAlert').click

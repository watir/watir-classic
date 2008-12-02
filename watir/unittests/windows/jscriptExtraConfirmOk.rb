$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', '..') unless $SETUP_LOADED

require 'watir/WindowHelper'


helper = WindowHelper.new
helper.push_confirm_button_ok
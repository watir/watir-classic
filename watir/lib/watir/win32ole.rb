# load the correct version of win32ole

# Use our modified win32ole library
$LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__), '..', 'watir', 'win32ole'))
require 'win32ole'


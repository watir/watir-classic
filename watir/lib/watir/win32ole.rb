# load the correct version of win32ole

# Use our modified win32ole library for Ruby 1.8.2 only
if RUBY_VERSION == '1.8.2'
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'watir', 'win32ole')
end
require 'win32ole'


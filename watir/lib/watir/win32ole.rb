# load the correct version of win32ole

# Use our modified win32ole library

if RUBY_VERSION =~ /^1\.8/
  $LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__), '..', 'watir', 'win32ole', '1.8.7'))
# WIP
#elsif RUBY_VERSION =~ /^1\.9/
#  $LOAD_PATH.unshift  File.expand_path(File.join(File.dirname(__FILE__), '..', 'watir', 'win32ole', '1.9.2'))
else
  # loading win32ole from stdlib
end


require 'win32ole'

WIN32OLE.codepage = WIN32OLE::CP_UTF8

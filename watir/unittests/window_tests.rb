TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

require 'unittests/js_events_test'
require 'unittests/modal_dialog_test'
require 'unittests/attachToExistingWindow_test.rb'
require 'unittests/attach_to_new_window_test.rb'
require 'unittests/jscript_test.rb'


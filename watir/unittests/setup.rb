$SETUP_LOADED = true

$myDir = File.expand_path(File.dirname(__FILE__))
$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
$htmlRoot =  "file:///#{$myDir}/html/" 

require 'unittests/setup/options'

# use local development versions of watir, firewatir, watir-common if available
topdir = File.join(File.dirname(__FILE__), '..')
libs = []
libs << File.join(topdir, 'lib')
libs << File.join(topdir, '..', 'firewatir', 'lib')
libs << File.join(topdir, '..', 'watir-common', 'lib')
libs.each { |lib| $LOAD_PATH.unshift File.expand_path(lib) }

require 'unittests/setup/browser'
require 'watir/testcase'
require 'unittests/setup/filter'
require 'unittests/setup/watir-unittest'

# Standard Tags
# :must_be_visible
# :creates_windows
# :unreliable (test fails intermittently)

=begin
Test Suites
* all_tests -- all the tests in the unittests directory (omits "other")
* window_tests -- window intensive tests
=end

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
end

# not in all tests!
$window_tests =
    [
     'attach_to_existing_window', # could actually run robustly as part of the core suite!
     'attach_to_new_window', # creates new window
     'close_window', # creates new window
     'frame_links', # visible
     'iedialog', # visible
     #ie-each
     'js_events', # is always visible
     'jscript',
     'modal_dialog', # modal is visible
     #new 
     'open_close',
     'send_keys', # visible
    ].collect {|x| "unittests/windows/#{x}_test.rb"}


$SETUP_LOADED = true
$myDir = File.expand_path(File.dirname(__FILE__))

require 'unittests/setup/options'

# use local development versions of firewatir, watir-common if available
topdir = File.join(File.dirname(__FILE__), '..')
libs = []
libs << File.join(topdir, 'lib')
libs << File.join(topdir, '..', 'firewatir', 'lib')
libs << File.join(topdir, '..', 'watir-common', 'lib')
libs.each { |lib| $LOAD_PATH.unshift File.expand_path(lib) }

# libraries used by feature tests
require 'watir'

options = Watir::UnitTest::Options.new.execute

# move this to execute?
case options[:browser]
when 'ie'
  # this line must execute before loading test/unit, otherwise IE will close *before* the tests run.
  at_exit {$ie.close if $ie && $ie.exists?; Watir::IE.quit} # close ie at completion of the tests
  $ie = Watir::IE.new
  $ie.speed = options[:speed].to_sym
  $browser = $ie
when 'firefox'
  require 'firewatir'
  at_exit {$browser.close if $browser}
  $browser = FireWatir::Firefox.new
end

require 'test/unit'
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

$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
# if you run the unit tests from a local file system use this line
$htmlRoot =  "file:///#{$myDir}/html/" 
# if you run the unit tests from a web server use this line
#   $htmlRoot =  "http://localhost:8080/watir/html/"

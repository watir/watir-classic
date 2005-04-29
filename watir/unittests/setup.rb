# libraries used by feature tests
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir

$all_tests = Dir["unittests/*_test.rb"]
$failing_tests = ["unittests/popups_test.rb"] + ["unittests/images_test.rb"]
$noisy_tests = ['unittests/image_saveas_test.rb'] + ['unittests/screen_capture_test.rb'] + ['unittests/filefield_test.rb']
$core_tests = $all_tests - ($failing_tests + $noisy_tests)

def start_ie_with_logger
  $ie = Watir::IE.new()
  $ie.typingspeed = 0
  $ie.defaultSleepTime = 0.01
end

def set_local_dir
  $myDir = File.expand_path(File.dirname(__FILE__))
  $myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  # if you run the unit tests form a local file system use this line
  $htmlRoot =  "file://#{$myDir}/html/" 
  # if you run the unit tests from a web server use this line
  #   $htmlRoot =  "http://localhost:8080/watir/html/"
end

start_ie_with_logger
set_local_dir


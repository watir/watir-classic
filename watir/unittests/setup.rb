END {$ie.close} # close ie at completion of the tests

# libraries used by feature tests
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
end

def their_unit_tests x; "unittests/#{x}_test.rb"; end
$failing_tests = 
    ['popups', # has problems when run in a suite (is ok when run alone); 
               # must be visible
               # will be revised to use autoit 
               # takes 15 seconds to run
     'images'  # 
     ].collect {|x| their_unit_tests x}
$tests_that_must_be_visible = # don't work when run with the -b switch (fail or hang), 
                              # or else are visible nontheless
  [#'image_saveas', 
    'screen_capture', # is always visible; takes 25 secons
    'filefield', # is always visible; takes 40 seconds 
    'jscript',
    'js_events' # is always visible
    ].collect {|x| their_unit_tests x}

$non_core_tests = $failing_tests + $tests_that_must_be_visible
$core_tests = $all_tests - $non_core_tests

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


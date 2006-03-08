END {$ie.close if $ie} # close ie at completion of the tests

# libraries used by feature tests
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["mozilla_unittests/*_test.rb"]
end

$non_core_tests = 
    ['popups', # has problems when run in a suite (is ok when run alone); 
               # must be visible
               # will be revised to use autoit 
               # takes 15 seconds to run
     'images', # save file must must be visible
     'screen_capture', # is always visible; takes 25 seconds
     'filefield', # is always visible; takes 40 seconds 
     'jscript',
     'javascript', # Need more robust way to Handle Javascript pop ups
     'js_events', # is always visible
     'minmax', # becomes visible
     'dialog', # visible
     'send_keys', # visible
     #'attach_to_new_window', # creates new window
     'modal_dialog' # modal is visible
    ].collect {|x| "mozilla_unittests/#{x}_test.rb"}

$core_tests = $all_tests - $non_core_tests

def start_ie_with_logger
  $ie = Watir::Firefox.new()
#  $ie.logger = Watir::WatirLogger.new( 'debug.txt', 4, 10000 )
  #$ie.set_fast_speed
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


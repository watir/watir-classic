# libraries used by feature tests
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'

def start_ie_with_logger
#  logger = Watir::WatirLogger.new(File.join(File.dirname(__FILE__), 'test.txt') ,5, 65535 * 2)
  $ie = Watir::IE.new()
#  $ie.set_logger(logger)
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
# libraries
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

# local
require 'unittests/testUnitAddons'

logger = WatirLogger.new(File.join(File.dirname(__FILE__), 'test.txt') ,5, 65535 * 2)
$ie = IE.new(logger)
$myDir = File.expand_path(File.dirname(__FILE__))
$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos

# if you run the unit tests form a local file system use this line
$htmlRoot =  "file://#{$myDir}/html/" 

# if you run the unit tests from a web server use this line
#   $htmlRoot =  "http://localhost:8080/watir/html/"

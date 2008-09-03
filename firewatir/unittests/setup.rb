END {$ff.close if $ff} # close ff at completion of the tests
$SETUP_LOADED = true

topdir = File.join(File.dirname(__FILE__), '..')
firewatir_lib = File.join(topdir, '..', 'firewatir', 'lib')
watir_common_lib = File.join(topdir, '..', 'watir-common', 'lib')
$LOAD_PATH.unshift firewatir_lib
$LOAD_PATH.unshift watir_common_lib

# libraries used by feature tests
require 'firewatir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'firewatir/testUnitAddons'
require 'unittests/iostring'

Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
end
$non_core_tests = [  ].collect {|x| "unittests/#{x}_test.rb"}

$core_tests = $all_tests - $non_core_tests

def start_ff_with_logger
  $ff = FireWatir::Firefox.new()
#  $ff.logger = Watir::WatirLogger.new( 'debug.txt', 4, 10000 )
  #$ff.set_fast_speed
end

def set_local_dir
  $myDir = File.expand_path(File.dirname(__FILE__))
  $myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  # if you run the unit tests form a local file system use this line
  $htmlRoot =  "file://#{$myDir}/html/" 
  # if you run the unit tests from a web server use this line
  #   $htmlRoot =  "http://localhost:8080/watir/html/"
end

start_ff_with_logger
set_local_dir


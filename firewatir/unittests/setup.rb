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

$core_tests = $all_tests

  $ff = FireWatir::Firefox.new()
  $myDir = File.expand_path(File.dirname(__FILE__))
  $myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos
  $htmlRoot =  "file://#{$myDir}/html/" 


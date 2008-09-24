$SETUP_LOADED = true

$myDir = File.expand_path(File.dirname(__FILE__))
$myDir.sub!( %r{/cygdrive/(\w)/}, '\1:/' ) # convert from cygwin to dos

topdir = File.join(File.dirname(__FILE__), '..')
libs = []
libs << File.join(topdir, '..', 'firewatir', 'lib')
libs << File.join(topdir, '..', 'watir-common', 'lib')
libs << File.join(topdir, '..', 'watir-common') # for the unit tests

libs.each { |lib| $LOAD_PATH.unshift File.expand_path(lib) }

require 'firewatir'
END {$ff.close if $ff} # close ff at completion of the tests

require 'firewatir/testUnitAddons'
require 'unittests/iostring'

require 'unittests/setup/options'
require 'unittests/setup/filter'
require 'unittests/setup/watir-unittest'

module Watir::UnitTest
  alias :uses_page :goto_page
end

commondir = File.join(topdir, '..', 'watir-common')
$all_tests = []
Dir.chdir topdir do
  $all_tests += Dir["unittests/*_test.rb"]
end
Dir.chdir commondir do
  $all_tests += Dir["unittests/*_test.rb"]
end

$browser = $ff = FireWatir::Firefox.new()

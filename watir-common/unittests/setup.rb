$SETUP_LOADED = true

$myDir = File.expand_path(File.dirname(__FILE__))

# use local development versions of watir, firewatir, watir-common if available
topdir = File.join(File.dirname(__FILE__), '..')
libs = []
libs << File.join(topdir, 'lib')
libs << File.join(topdir, '..', 'firewatir', 'lib')
libs << File.join(topdir, '..', 'watir', 'lib')
libs.each { |lib| $LOAD_PATH.unshift File.expand_path(lib) }

require 'unittests/setup/lib'

topdir = File.join(File.dirname(__FILE__), '..')
Dir.chdir topdir do
  $all_tests = Dir["unittests/*_test.rb"]
end

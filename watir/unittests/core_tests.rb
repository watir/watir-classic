# these are the tests that run reliably and invisibly

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'watir'

$HIDE_IE = true

require 'unittests/setup'

Dir.chdir TOPDIR
$core_tests.each {|x| require x}

# these are the tests that run reliably and invisibly

$HIDE_IE = true

TOPDIR = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH.unshift TOPDIR
require 'unittests/setup'

Dir.chdir TOPDIR
$core_tests.each {|x| require x}

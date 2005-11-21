# these are the tests that run reliably and invisibly

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

Dir.chdir TOPDIR
$core_tests.each {|x| require x unless x =~ /xpath/}

$HIDE_IE = true
$ie.visible = false

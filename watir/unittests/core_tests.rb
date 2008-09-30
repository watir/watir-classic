# these are the non-xpath tests that do not need to be visible

$HIDE_IE = true

TOPDIR = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH.unshift TOPDIR
require 'unittests/setup'

Dir.chdir TOPDIR
$all_tests.each {|x| require x}

Watir::UnitTest.filter_out do |test|
  test.class.to_s =~ /xpath/i
end
Watir::UnitTest.filter_out_tests_tagged :must_be_visible 

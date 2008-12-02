TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

Dir.chdir TOPDIR
$all_tests.each {|x| require x }

Watir::UnitTest.filter_out do |t|
  t.class.to_s !~ /xpath/i
end
TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

Dir.chdir TOPDIR
$all_tests.each {|x| require x}

Watir::UnitTest.filter = proc do |test|
  test.class.to_s !~ /xpath/i &&
  test.class.tags.include?(:must_be_visible) 
end

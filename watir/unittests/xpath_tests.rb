TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

Dir.chdir TOPDIR
$all_tests.each {|x| require x }

# Note: filters must return true to mark a match (non-nil is not enough).
Watir::UnitTest.filter = proc do |t| 
  ! (t.class.to_s =~ /xpath/i).nil?
end

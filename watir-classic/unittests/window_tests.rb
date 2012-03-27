TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

ENV['watir_visible'] = 'true'

require 'unittests/setup.rb'

Dir.chdir TOPDIR
$window_tests.each {|x| require x}


# these are the tests that run reliably and invisibly

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'unittests/setup.rb'

Dir.chdir TOPDIR

#tests = ["unittests/test.rb",
#        "unittests/test_xpath.rb"
#       ]

#tests.each { |x| require x }
$core_tests.each {|x| require x }

#$HIDE_IE = true
#$ff.visible = false

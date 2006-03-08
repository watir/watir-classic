# these are the tests that run reliably and invisibly

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'mozilla_unittests/setup.rb'

Dir.chdir TOPDIR

#tests = ["mozilla_unittests/test.rb",
#        "mozilla_unittests/test_xpath.rb"
#       ]

#tests.each { |x| require x }
$core_tests.each {|x| require x }

#$HIDE_IE = true
#$ie.visible = false

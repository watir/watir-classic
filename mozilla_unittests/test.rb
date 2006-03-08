# these are the tests that run reliably and invisibly

TOPDIR = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH.unshift TOPDIR

require 'mozilla_unittests/setup.rb'

Dir.chdir TOPDIR

tests = ["mozilla_unittests/javascript_test.rb",
         "mozilla_unittests/links_xpath_test.rb"
        ]

tests.each { |x| require x }
#$core_tests.each {|x| require x unless x =~ /xpath/}

#$HIDE_IE = true
#$ie.visible = false

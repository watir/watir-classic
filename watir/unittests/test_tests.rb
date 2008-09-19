$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')

require 'unittests/setup'
require 'unittests/buttons_test'

Watir::UnitTest::filter_for :cosmetic


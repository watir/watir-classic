$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..')

require 'unittests/setup'
require 'unittests/checkbox_test'

Watir::UnitTest.filter = proc do |test|
  !test.tagged?(:firewatir_bug)
end


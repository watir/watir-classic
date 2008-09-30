# this file needs to be loaded before 'test/unit' to ensure that our
# test runner is used instead (defined in the at_exit block below).

require 'test/unit/collector/objectspace'

# Modify the Test::Unit runner in Eclipse, so it only runs our tests
module Test::Unit
  module RDT
    def self.buildSuite filename
      collector = Test::Unit::Collector::ObjectSpace.new 
      collector.filter = Watir::UnitTest.filter
      collector.collect filename
    end
  end
end

# Invoke default test runner so it only runs our tests
at_exit do
  unless $! || Test::Unit.run?
    runner = Test::Unit::AutoRunner.new false
    runner.filters = Watir::UnitTest.filter 
    exit runner.run
  end
end

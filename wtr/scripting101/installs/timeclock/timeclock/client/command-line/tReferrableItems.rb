require 'timeclock/client/command-line/tutil'
require 'timeclock/client/ReferrableItems'

# Note that ReferrableItems currently live in client, not client/command-line.
# But it's more convenient to test them here.

module Timeclock
  module Client
    module CommandLine

      class ReferrableItemsTests < InterfaceTestCase

        def setup
          super
          @items = ReferrableItems.new
        end

        def test_record_is_one_based
          rec = FinishedRecord.new(Time.now, 1.minute, Job.named('hi'))
          @items.build_index([rec])
          assert_equal(rec, @items[1])
        end

        def test_bounds_checking
          rec1 = FinishedRecord.new(Time.now, 1.minute, Job.named('hi'))
          rec2 = ActiveRecord.new(Time.now, 10.minutes, Job.named('bye'))
          @items.build_index([rec1, rec2])

          # Like Ruby arrays, out-of-bounds indices yield nil.
          assert_equal(nil, @items[0])
          assert_equal(nil, @items[3])

          valid, invalid = @items.validate([0, 1, 2, 3])
          assert_equal([1, 2], valid)
          assert_equal([0, 3], invalid)

          # Empty array if all valid or all invalid
          valid, invalid = @items.validate([1, 2])
          assert_equal([1, 2], valid)
          assert_equal([], invalid)

          valid, invalid = @items.validate([-33, 333])
          assert_equal([], valid)
          assert_equal([-33, 333], invalid)
        end
      end
    end
  end
end

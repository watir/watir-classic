# These were extracted out from other code, so they are mostly tested
# through use.

require 'timeclock/util/RichlyCallingWrapper'
require 'timeclock/util/RichlyCalledWrapper'

module Timeclock
  class RichlyCallingWrappers < Test::Unit::TestCase

    class EndPoint
      def hi
        'hi'
      end
    end

    def test_basic
      chain = RichlyCallingWrapper.new(RichlyCalledWrapper.new(EndPoint.new))
      assert_equal('hi', chain.hi)
    end

  end
end


module Timeclock
  module Client
    class ClientTestCase < Test::Unit::TestCase

      def assert_message(expected, actual)
        expected = expected.after_dots  # also works just to strip left whitespace
        assert_equal(expected, actual)
      end

      def test_dummy
        # Tests are autorun. test::unit whines unless there's an
        # actual test in this (abstract) class.
      end
    end
  end
end

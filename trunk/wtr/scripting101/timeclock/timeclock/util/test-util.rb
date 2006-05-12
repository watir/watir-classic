require 'timeclock/marshalled/include-all'
require 'test/unit'

module Test
  module Unit
    module Assertions

      def assert_exception_with_message(exception_class, expected_message)
        begin
          yield
        rescue exception_class
          assert_equal(expected_message, $!.message)
        rescue
          flunk("Wrong exception #{$!.inspect} raised.")
        else
          flunk("No exception raised.")
        end
      end

      def assert_whine(problem, *args)
        begin
          yield
        rescue TimeclockError
          assert_equal(problem, $!.code)
          assert_equal(args, $!.args)
        rescue
          flunk("Wrong exception #{$!.inspect} raised.")
        else
          flunk("No exception raised.")
        end
      end


      todo 'Gather all assertion helpers - product and unit - here?'
      
      ### Tests

      class TestUtilitiesTest < Test::Unit::TestCase

        require 'timeclock/util/Whine'
        include Timeclock::Whine

        def test_exception_with_message
          assert_exception_with_message(AssertionFailedError, 'No exception raised.') {
            assert_exception_with_message(Exception, 'irrelevant') {
              "returns a string"
            }
          }

         assert_exception_with_message(AssertionFailedError, "Wrong exception \#<FloatDomainError: included message> raised.") {
            
            assert_exception_with_message(ArgumentError, 'irrelevent') {
              raise FloatDomainError, 'included message'
            }
          }

          # Note that match is "is_a?" rather than class equality.
          assert_exception_with_message(StandardError, "a message") {
            raise ArgumentError, "a message"
          }

          # Note: dependent on way Test::Unit prints failure messages.
          assert_exception_with_message(AssertionFailedError, %Q{<"hi"> expected but was\n<"bye">.}) {
            assert_exception_with_message(ArgumentError, 'hi') {
              raise ArgumentError, 'bye'
            }
          }
        end

        def test_assert_whine
          # Note: these checks are dependent on the way that Test::Unit
          # prints assertion failures.
          assert_exception_with_message(AssertionFailedError, 'No exception raised.') {
            assert_whine(:irrelevant) {
              "returns a string"
            }
          }

         assert_exception_with_message(AssertionFailedError, "Wrong exception \#<FloatDomainError: included message> raised.") {
            
            assert_whine(:irrelevant, 'irrelevent') {
              raise FloatDomainError, 'included message'
            }
          }


          assert_exception_with_message(AssertionFailedError, "<:hi> expected but was\n<:bye>.") {
            assert_whine(:hi, 'irrelevant') {
              whine(:bye, 'irrelevant')
            }
          }


          assert_exception_with_message(AssertionFailedError, %Q{<["hi"]> expected but was\n<["bye"]>.}) {
            assert_whine(:irrelevant, 'hi') {
              whine(:irrelevant, 'bye')
            }
          }
        end

      end
    end
  end
end

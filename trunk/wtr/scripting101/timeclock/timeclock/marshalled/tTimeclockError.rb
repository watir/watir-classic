require 'timeclock/marshalled/TimeclockError'


module Timeclock
  module Marshalled

    # Exception also has an 'args' field, but that's adequately tested
    # through use.

    class TimeclockErrorTests < Test::Unit::TestCase

      def test_exception_return_self
        e = TimeclockError.new('hi', :code)
        assert(e.object_id == e.exception.object_id)

        # Typical use.
        begin
          raise TimeclockError, "hi"
        rescue TimeclockError => e
          assert(e.object_id == e.exception.object_id)
          begin
            raise e
          rescue TimeclockError => new_e
            assert(e.object_id == new_e.object_id)
          end
        end
      end

      def test_exception_override
        
        e = TimeclockError.new('hi', :a_code)
        new_e = e.exception('bye')
        assert_equal('bye', new_e.message)
        assert_equal(:a_code, new_e.code)
      end
    end  
  end
end

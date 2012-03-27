# encoding: utf-8

module Watir
  module Wait
    extend self

    class TimeoutError < StandardError
    end

    #
    # Wait until the block evaluates to true or times out.
    #

    def until(timeout = 60, &block)
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        result = yield(self)
        return result if result
        sleep 0.1
      end

      raise TimeoutError, "timed out after #{timeout} seconds"
    end

    #
    # Wait while the block evaluates to true or times out.
    #
    def while(timeout = 60, &block)
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        return unless yield(self)
        sleep 0.1
      end

      raise TimeoutError, "timed out after #{timeout} seconds"
    end

  end # Wait
end # Watir
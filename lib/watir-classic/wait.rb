# encoding: utf-8

module Watir
  module Wait
    extend self

    class TimeoutError < StandardError
    end

    # Wait until the block evaluates to true or times out.
    #
    # @example
    #   Watir::Wait.until(5) { browser.text_field.exists? }
    #
    # @param [Fixnum] timeout timeout to wait until block returns true.
    # @yieldparam [self] instance instance of self.
    # @raise [TimeoutError] when timeout exceeds.
    # @see WaitHelper
    # @see ElementExtensions
    def until(timeout = 60, &block)
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        result = yield(self)
        return result if result
        sleep 0.1
      end

      raise TimeoutError, "timed out after #{timeout} seconds"
    end

    # Wait while the block evaluates to true or times out.
    #
    # @example
    #   Watir::Wait.while(5) { browser.text_field.exists? }
    #
    # @param [Fixnum] timeout timeout to wait while block returns true.
    # @yieldparam [self] instance instance of self.
    # @raise [TimeoutError] when timeout exceeds.
    # @see WaitHelper
    # @see ElementExtensions    
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

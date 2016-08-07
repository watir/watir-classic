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
    def until(timeout = nil, message = nil, &block)
      timeout ||= Watir.default_timeout
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        result = yield(self)
        return result if result
        sleep 0.1
      end

      raise TimeoutError, message_for(timeout, message)
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
    def while(timeout = nil, message = nil, &block)
      timeout ||= Watir.default_timeout
      end_time = ::Time.now + timeout

      until ::Time.now > end_time
        return unless yield(self)
        sleep 0.1
      end

      raise TimeoutError, message_for(timeout, message)
    end

      private

      def message_for(timeout, message)
        err = "timed out after #{timeout} seconds"
        err << ", #{message}" if message

        err
      end

  end # Wait
end # Watir

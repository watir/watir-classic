# encoding: utf-8

module Watir
  # This module adds some helper methods for asynchronous testing.
  module ElementExtensions

    # Wraps an {Element} so that any subsequent method calls are
    # put on hold until the element is present on the page.
    #
    # @private
    class WhenPresentDecorator
      def initialize(element, timeout)
        @element = element
        @timeout = timeout
      end

      def method_missing(m, *args, &block)
        Watir::Wait.until(@timeout) { @element.present? }
        @element.send(m, *args, &block)
      end
    
      # Returns element id
      def id
        Watir::Wait.until(@timeout) { @element.present? }
        @element.id
      end

    end

    # @return [Boolean] true when element exists and is visible, false otherwise.
    def present?
      exists? && visible? rescue false
    end

    # Waits until the element is present before calling its methods.
    #
    # @example
    #   browser.button(:id, 'foo').when_present.click
    #
    # @example
    #   browser.div(:id, 'bar').when_present { |div| ... }
    #
    # @example
    #   browser.p(:id, 'baz').when_present(60).text
    #
    # @param [Fixnum] timeout seconds to wait before timing out.
    # @raise [Watir::Wait::TimeoutError] will be raised when element is not
    #   present within specified timeout.
    def when_present(timeout = nil)
      timeout ||= Watir.default_timeout
      if block_given?
        Watir::Wait.until(timeout) { self.present? }
        yield self
      else
        return WhenPresentDecorator.new(self, timeout)
      end
    end

    # Wait until element is present before continuing.
    #
    # @raise [Watir::Wait::TimeoutError] will be raised when element is not
    #   present within specified timeout.
    def wait_until_present(timeout = nil)
      timeout ||= Watir.default_timeout
      Watir::Wait.until(timeout) { self.present? }
    end

    # Wait while element is present before continuing.
    #
    # @raise [Watir::Wait::TimeoutError] will be raised when element is still present
    #   after specified timeout.
    def wait_while_present(timeout = nil)
      timeout ||= Watir.default_timeout
      Watir::Wait.while(timeout) { self.present? }
    end

  end # module ElementExtensions
end

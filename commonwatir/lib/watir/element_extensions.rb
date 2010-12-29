# encoding: utf-8

module Watir
# This assumes that Element#visible? is defined
  module ElementExtensions

    #
    # Wraps a {Celerity,Watir}::Element so that any subsequent method calls are
    # put on hold until the element is present on the page.
    #

    class WhenPresentDecorator
      def initialize(element, timeout)
        @element = element
        @timeout = timeout
      end

      def method_missing(m, *args, &block)
        unless @element.respond_to?(m)
          raise NoMethodError, "undefined method `#{m}' for #{@element.inspect}:#{@element.class}"
        end

        Watir::Wait.until(@timeout) { @element.present? }
        @element.send(m, *args, &block)
      end
    
      # Returns element id
      def id
        Watir::Wait.until(@timeout) { @element.present? }
        @element.id
      end

    end

    #
    # Returns true if the element exists and is visible on the page
    #

    def present?
      exists? && visible?
    end

    #
    # Waits until the element is present.
    #
    # Optional argument:
    #
    #   timeout   -  seconds to wait before timing out (default: 60)
    #
    #     browser.button(:id, 'foo').when_present.click
    #     browser.div(:id, 'bar').when_present { |div| ... }
    #     browser.p(:id, 'baz').when_present(60).text
    #

    def when_present(timeout = 60)
      if block_given?
        Watir::Wait.until(timeout) { self.present? }
        yield self
      else
        return WhenPresentDecorator.new(self, timeout)
      end
    end

    def wait_until_present(timeout = 60)
      Watir::Wait.until(timeout) { self.present? }
    end

    def wait_while_present(timeout = 60)
      Watir::Wait.while(timeout) { self.present? }
    end

  end # module ElementExtensions
end

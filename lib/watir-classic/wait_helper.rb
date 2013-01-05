module Watir
  module WaitHelper
    # Wait until block evaluates to true or times out.
    #
    # @example
    #   browser.wait_until(5) { browser.text_field.exists? }
    #
    # @see Wait
    # @see ElementExtensions
    def wait_until(*args, &blk)
      Wait.until(*args, &blk)
    end

    # Wait while block evaluates to true or times out.
    #
    # @example
    #   browser.wait_while(5) { browser.text_field.exists? }
    #
    # @see Wait
    # @see ElementExtensions
    def wait_while(*args, &blk)
      Wait.while(*args, &blk)
    end
  end
end

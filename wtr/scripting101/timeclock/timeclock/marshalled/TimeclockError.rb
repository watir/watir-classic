module Timeclock
  module Marshalled

    todo 'There must be a better way to handle TimeclockError'
    # I would like this to work like the example in the Pickaxe book, in
    # which you can raise an exception-with-state like this:
    #   raise TimeclockError.new(code), "a message"
    #
    # However, I can't get it to work. The problem is how to get
    # TimeclockError#exception to work with a new message, as in
    #
    # ...
    #   rescue TimeclockError => exception
    #     raise exception, "new message"
    # 
    # I don't actually want to do that, but that's (in effect) what
    # drb does. How can TimeclockError#exception be implemented so that
    # it copies in a new message without there being a message argument
    # to the constructor?

    class TimeclockError < StandardError
      attr_accessor :code, :args
      
      def initialize(message="", code=nil, args=[])
        super message
        @code = code
        @args = args
      end

      def inspect
        "Timeclock error (#{code.inspect}): #{message}"
      end

      def exception(message = nil)
        return self if message.nil?

        TimeclockError.new(message, self.code, self.args)
      end
    end

  end
end

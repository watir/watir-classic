module Timeclock
  module Marshalled

    class Command

      attr_reader :name, :args

      def initialize(name, args)
        @name = name
        @args = args
      end

      def to_s
        "Command '#{name}', #{args.join(', ')}"
      end
    end
  end
end

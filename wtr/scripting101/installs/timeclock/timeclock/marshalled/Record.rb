require 'timeclock/util/misc'

module Timeclock
  module Marshalled
    class Record    # abstract
      attr_reader :time_started, :job, :time_accumulated
      attr_accessor :persistent_id

      def initialize(time_started, time_accumulated, job)
        @time_started = time_started
        @time_accumulated = time_accumulated
        @job = job
      end

      # See notes in ActiveRecord about why there is not a setter for
      # @time_accumulated.
      def shorten_time_accumulated(seconds)
        @time_accumulated -= seconds
      end
        
      def running?
        subclass_responsibility
      end

      def paused?
        subclass_responsibility
      end

      def stopped?
        subclass_responsibility
      end

      todo 'Consider whether record equality should be by persistent_id.'
      # There has been a bug caused because I assumed a Ruby function
      # worked by pointer equality instead of '=='-equality. It seems
      # error prone not to define == to be across-invocations-pointer-
      # equality (that is, equal persistent-ids). If there's another bug,
      # change == to use persistent-id equality
      def ==(other)
        return false unless other.kind_of?(self.class)

        self.time_started == other.time_started &&
          self.time_accumulated == other.time_accumulated &&
          self.job == other.job
      end

      def <=>(other)
        self.time_started <=> other.time_started
      end
    end      
  end
end

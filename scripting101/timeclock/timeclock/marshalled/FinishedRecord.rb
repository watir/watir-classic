require 'timeclock/marshalled/Record'

module Timeclock
  module Marshalled

    class FinishedRecord < Record
      attr_writer :time_accumulated # Enable setting in addition to getting

      def initialize(time_started, time_accumulated, job)
        $trace.announce(lines("Creating record for '#{job.name}'.",
                              "It started at #{time_started}, accumulated #{time_accumulated}."))
        super
      end

      def running?
        false
      end

      def paused?
        false
      end

      def stopped?
        true
      end

      def inspect
        sprintf("<FinishedRecord %s: %s for %s from %s>",
                persistent_id, job.full_name,
                time_accumulated, time_started)
      end
      
    end
  end
end

require 'timeclock/util/misc'
require 'timeclock/marshalled/Job'
require 'timeclock/marshalled/FinishedRecord'
require 'timeclock/client/PrettyTimes'

module Timeclock
  module Client

    # Converts server records into strings.
    class RecordStringifier
      def initialize(record)
        @record = record
        @time_stringifier = PrettyTimes.columnar
      end

      def start_date_time
        @time_stringifier.date_time(@record.time_started)
      end

      def cumulative_hours
        @time_stringifier.hours(@record.time_accumulated)
      end

      def job
        if @record.job.is_subjob?
          @record.job.parent.name
        else
          @record.job.name
        end
      end

      def subjob
        if @record.job.is_subjob?
          @record.job.name
        else
          ""
        end
      end

      def full_job_name
        @record.job.full_name
      end

      def summary
        retval = sprintf("%s from %s on %s",
                       cumulative_hours, start_date_time, full_job_name)
        if @record.running?
          retval << " (running)"
        elsif @record.paused?
          retval << " (paused)"
        end

        retval
      end

    end
  end
end

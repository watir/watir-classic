require 'timeclock/util/InterestingTimes'

module Timeclock
  module Marshalled

    class RecordFilter

      # RecordFilter is pluggable with any block that answers true if
      # a given record should be *retained*.
      def initialize(&block)
        @match_block = block
      end

      def run(records)
        records.find_all { | record | record_matches?(record) }
      end

      def record_matches?(record)
        @match_block.call(record)
      end

      ## RecordFilter subclasses are used when the filter is sent across
      ## the wire. Blocks cannot be marshalled. 

      def self.by_job_full_name(job_full_name)
        RecordFilterByJobFullName.new(job_full_name)
      end

      def self.by_month_to_time(target_time)
        RecordFilterByMonthToTime.new(target_time)
      end

      def self.by_time_interval(inclusive_start, inclusive_end)
        RecordFilterByTimeInterval.new(inclusive_start, inclusive_end)
      end

      def self.recent(relative_to)
        RecordFilterByRecent.new(relative_to)
      end
    end

    class RecordFilterByTimeInterval < RecordFilter

      def initialize(inclusive_start, inclusive_end)
        @inclusive_start = inclusive_start
        @inclusive_end = inclusive_end
      end
      
      def record_matches?(record)
          (@inclusive_start .. @inclusive_end) === record.time_started
      end
    end

    class RecordFilterByMonthToTime < RecordFilterByTimeInterval
      def initialize(target_time)
        super(InterestingTimes.beginning_of_month(target_time), target_time)
      end
    end

    class RecordFilterByRecent < RecordFilterByTimeInterval
      def initialize(now)
        super(InterestingTimes.yesterday(now), now)
      end
    end

    class RecordFilterByJobFullName < RecordFilter
      def initialize(job_full_name)
        @job_full_name = job_full_name
      end

      def record_matches?(record)
        (record.job.full_name == @job_full_name) || 
          (record.job.is_subjob? &&
           record.job.parent.full_name == @job_full_name)
      end
    end
  end
end

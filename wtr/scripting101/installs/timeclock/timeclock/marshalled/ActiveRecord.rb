require 'timeclock/util/misc'
require 'timeclock/marshalled/Record'

module Timeclock
  module Marshalled

    module JobState
      RUNNING = "running"
      STOPPED = "stopped"
      PAUSED = "paused"
    end

    class ActiveRecord < Record
      attr_reader :state
      attr_accessor :potential_restart_volunteer, :most_recent_time_started
      # Note that there is no setter for time_accumulated. That's because
      # the getter is a complicated calculation. rec.time_accumulated += 5
      # is unlikely to work correctly. Use shorten_time_accumulated instead
      # (in the superclass).
      
      def self.start(job, start_time)
        new(start_time, 0, job)
      end

      def initialize(time_started, time_accumulated, job)
        super
        @potential_restart_volunteer = false
        restart(time_started)
      end

      def restart(restart_time)
        @most_recent_time_started = restart_time
        @state = JobState::RUNNING
        self
      end

      def stop(stop_time)
        record_elapsed_time(stop_time) unless @state == JobState::PAUSED
        @state = JobState::STOPPED
        self
      end

      def pause(pause_time)
        record_elapsed_time(pause_time)
        @state = JobState::PAUSED
        self
      end

      def time_accumulated
        if running?
          @time_accumulated + most_recent_time_accumulated
        else
          @time_accumulated
        end
      end

      # When the job is running, this calculation shows elapsed time
      # since last started. The starting time was given explicitly by
      # the client. The current time is implicit, which means this
      # calculation is assumed to be done by the client. (The server
      # might be in a different time zone.)

      def most_recent_time_accumulated
        Time.now - @most_recent_time_started
      end

      def restart_volunteer?
        paused? and @potential_restart_volunteer
      end

      def running?
        @state == JobState::RUNNING
      end

      def paused?
        @state == JobState::PAUSED
      end

      def stopped?
        flunk("The caller is supposed to know that an ActiveRecord is never in the stopped state.")
      end

      def inspect
        "(ActiveRecord #{persistent_id}: #{@job.name} #{@time_started.to_i}/#{@time_accumulated}/#{state}/pot_volunteer=#{@potential_restart_volunteer})"
      end

      def ==(other)
        super(other) && self.state == other.state
      end

      private
      def record_elapsed_time(mark)
        @time_accumulated += (mark - @most_recent_time_started)
      end

    end
  end
end 

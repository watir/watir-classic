require 'timeclock/marshalled/ActiveRecord'
require 'timeclock/marshalled/FinishedRecord'
require 'timeclock/util/Whine'
require 'timeclock/util/Steps'

## Keeps track of all the jobs that have been started but not stopped
## yet.

module Timeclock
  module Server

    class ActiveJobManager
      include Whine
      include Steps

      attr_reader :active_records

      def initialize(all_records)
        @all_records = all_records
        @active_records = {}       # [Job] produces an ActiveRecord
      end

      # I've had two bugs that led to two jobs simultaneously running!
      def assert_at_most_one_running
        running = @active_records.values.find_all { | ar | ar.running? } 
        assert(running.size < 2)
      end

      # Utilities for manipulating instance variables in synchrony.
      def link_in(active_record)
        assert(@active_records.has_key?(active_record.job) == false)
        assert(@all_records.record_with_id(active_record.persistent_id).nil?)
        @active_records[active_record.job] = active_record
        @all_records.add active_record
      end

      def unlink(active_record)
        assert(@active_records.delete(active_record.job))
        unlinked = @all_records.delete(@all_records.record_with_id(active_record.persistent_id))
        assert(unlinked)
        unlinked
      end
      
      private :link_in, :unlink



      # Particular jobs of interest

      def running
        @active_records.values.find { | ar | ar.running? }
      end

      def restart_volunteer
        @active_records.values.find { | ar | ar.restart_volunteer? }
      end

      def active_background
        @active_records.values.find { | ar | ar.potential_restart_volunteer }
      end


      # Predicates

      def any_active?
        not @active_records.empty?
      end

      def running?(job)
        return false unless @active_records.has_key?(job)
        @active_records[job].running?
      end

      def paused?(job)
        return false unless @active_records.has_key?(job)
        @active_records[job].paused?
      end

      def stopped?(job)
        @active_records.has_key?(job) == false
      end


      # Logging that's done in more than one place.

      def log_pause(new_rec, restorable, desired_time)
        log_change(:paused, :new => new_rec,
                            :restorable => restorable,
                            :at => desired_time)
      end


      ## Changing state and undoing changes
      ##  Here's the beef.

      def start(job, desired_time, set_active_background=false)
        whine_if(running?(job),
                  :job_already_started, job.full_name)

        # I'm teetering on the edge of a Null Object here.
        if running
          restorable = running.dup
          new_rec = running.pause(desired_time)
          log_pause(new_rec, restorable, desired_time)
        end

        if @active_records.has_key?(job)
          restorable = @active_records[job].dup
          @active_records[job].restart(desired_time)
          log_change(:resumed, :new => @active_records[job],
                               :restorable => restorable,
                               :at => desired_time)
        else
          new_record = ActiveRecord.start(job, desired_time)
          link_in(new_record)
          new_record.potential_restart_volunteer = set_active_background
          log_change(:started, :new => new_record,
                               :at => desired_time)
        end
        assert_at_most_one_running
        job
      end

      # Undo resumption (starting of a paused job)
      def restore_resumed_record(previous_version)
        erased = unlink(previous_version)
        link_in(previous_version)
        log_change(:restored_resumed_record,
                   :erased => erased,
                   :restored_record => previous_version)
        assert_at_most_one_running
      end

      # Undo initial creation.
      def unstart_running_job(job)
        # The job argument is used only for sanity checking: we'd better
        # be unstarting the running job.
        ar = running
        assert(ar)
        assert(ar.job == job)
        unlink(ar)
        log_change(:undid_start, :record => ar)
        assert(running.nil?)
      end



      def stop(job, desired_time)
        whine_if(stopped?(job),
                 :job_already_stopped, job.full_name)

        ar = @active_records[job]
        restorable = ar.dup   # ar about to be changed
        unlink(ar)
        ar.stop(desired_time)
        log_change(:stopped,
                   :new => ar,
                   :at => desired_time,
                   :restorable => restorable)

        record = FinishedRecord.new(ar.time_started, ar.time_accumulated, job)
        @all_records.add(record)
        log_change(:added_finished_record, :record => record)

        volunteer = restart_volunteer
        start(volunteer.job, desired_time) if volunteer
        assert_at_most_one_running

        record
      end

      def restore_stopped_record(previous_version)
        link_in(previous_version)
        log_change(:restored_stopped_record,
                   :restored_record => previous_version)
        assert_at_most_one_running
      end



      def pause(desired_time, ignore_volunteer = false)
        whine_if(running.nil?, :no_job_to_pause)

        # Find volunteer before pausing in case it's the volunteer who's
        # being paused.
        volunteer = restart_volunteer unless ignore_volunteer

        restorable = running.dup
        paused_ar = running.pause(desired_time)
        log_pause(paused_ar, restorable, desired_time)

        start(volunteer.job, desired_time) if volunteer
        assert_at_most_one_running
        paused_ar.job
      end

      def restore_paused_record(previous_version)
        erased = unlink(previous_version)
        link_in(previous_version)
        log_change(:restored_paused_record,
                   :erased => erased,
                   :restored_record => previous_version)
        assert_at_most_one_running
      end



      def inspect
        "<ActiveJobManager: #{@active_records.inspect}>"
      end
    end
  end
end 

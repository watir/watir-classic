require 'timeclock/util/misc'
require 'timeclock/util/Whine'
require 'timeclock/util/Steps'
require 'timeclock/server/ActiveJobManager'
require 'timeclock/server/PersistentUser'

require 'timeclock/marshalled/include-all'

require 'drb'

module Timeclock
  module Server

    class Session

      include DRb::DRbUndumped  # pass these by reference
      include Whine
      include Steps

      attr_reader :jobs, :user, :persistent_user

      def initialize(user)
        # could make @jobs a Job and use the subjobs list as the master list of
        # all jobs, but it saves exactly one if statement.
        @user = user
        @persistent_user = PersistentUser.new(@user)
        empty_session!
        load if @persistent_user.exists?
        $trace.announce "Session for #{user} starts with " +
          "#{jobs.length} jobs, #{records.length} records."
        $trace.event "Initially with jobs: #{jobs.inspect}"
        $trace.event "Initially with records: #{records.inspect}"
        $trace.event "Initially tracking #{@active_job_manager.inspect}"
      end


      # This is a somewhat lame way of flushing dirty data to disk after
      # a call. The advantage is that each public method is annotated
      # with whether it changes state (strictly, whether it can change state).
      # That makes it less likely that changes won't be flushed (without the
      # hassle of having each data type signal that it's dirty). 
      # The disadvantage is that the caller has to remember to call the
      # 'after' method (though this could be construed an advantage if you
      # don't want to go to disk).
      Method_changes_state = {}
      def self.changes_state(message)
        Method_changes_state[message] = true
      end

      def after(message)
        save if Method_changes_state[message]
      end
      

      ##### The API

      changes_state :empty_session!
      def empty_session!
        @jobs = JobHash.new
        @records = RecordList.new
        @active_job_manager = ActiveJobManager.new(@records)
        true
      end

      def load
        @jobs, @records, @active_job_manager = @persistent_user.load
        true
      end

      def save
        @persistent_user.save(@jobs, @records, @active_job_manager)
        true
      end

      # This doesn't change state - it destroys it.
      def forget_everything
        empty_session!
        PersistentUser.new(@user).delete
      end


      changes_state :accept_job
      def accept_job(job)
        if job.is_subjob?
          if not @jobs.has_parent_of?(job)          # not even parent present.
            accept_job(job.parent)
            # Accepting the parent also installs this subjob.
            log_change(:job_created, :job => job)
          elsif not @jobs.job_has_this_child?(job)  # parent doesn't have this.
            log_change(:job_created, :job => job)
            log_change(:job_exists, :job => job.parent)
            @jobs.install_child(job)
          else                                # parent does have an older copy.
            log_change(:job_exists, :job => job)
            # We always replace an old job with new.
            # That updates attributes.
            @jobs.install_child(job)
          end
        elsif not @jobs.has_key?(job.name)          # job not present
          log_change(:job_created, :job => job)
          @jobs[job.name] = job
        else                                        # older copy present
          log_change(:job_exists, :job => job)
          # We always replace an old job with new.
          # That updates attributes.
          @jobs[job.name] = job
        end
        true
      end

      def find_job_named(full_name)
        job_name, subjob_name = Job.parse_full_name(full_name)

        whine_unless(jobs.has_key?(job_name),
                     :no_such_job, job_name)

        job = jobs[job_name]
        return job unless subjob_name

        whine_unless(job.subjobs.has_key?(subjob_name),
                     :no_such_subjob, job_name, subjob_name)

        job.subjobs[subjob_name]
      end

      changes_state :forget_job
      def forget_job(full_name)
        job = find_job_named(full_name)
        whine_unless(@active_job_manager.stopped?(job),
                     :forgetting_active_job)

        if job.is_subjob?
          assert(job == @jobs.delete_child(job))
        else
          assert(job == @jobs.delete(job.name))
        end
        log_change(:forgot_job, :job => job)
        true
      end

      changes_state :background
      def background(full_name)
        # Make no changes until we know the new background job really
        # exists.
        new_background = find_job_named(full_name)

        old_background = @jobs.background_job
        old_background.unmake_background if old_background
          
        new_background.make_background

        if old_background
          log_change(:swapped_background, :old_background => old_background,
                                          :new_background => new_background)
        else
          log_change(:first_background,   :new_background => new_background)
        end
        new_background
      end
      

      changes_state :forget_background
      def forget_background
        background = @jobs.background_job
        whine_if(background.nil?, :forget_background_but_no_background_job)
        
        background.unmake_background
        log_change(:forgot_background, :old_background => background,
                   :currently_in_use => @active_job_manager.active_background)
      end


      changes_state :start
      def start(job_or_string, desired_time, set_as_background_job = false)
        job = ensure_job(job_or_string)
        @active_job_manager.start(job, desired_time, set_as_background_job)
      end

      changes_state :start_background_job
      def start_background_job(desired_time)
        whine_if(@active_job_manager.any_active?, :start_background_but_jobs_are_active)
        assert(nil == @active_job_manager.active_background)
        
        background = @jobs.background_job
        whine_unless(background, :start_background_but_no_background_job)
        
        $trace.event("Starting the background job #{background.inspect}")
        start(background, desired_time, true)
        background
      end

      def running?(job_or_string)
        job = ensure_job(job_or_string)
        @active_job_manager.running?(job)
      end
      

      changes_state :pause
      def pause(desired_time)
        $trace.event("Pausing current job.")
        @active_job_manager.pause(desired_time)
      end

      changes_state :pause_without_resumption
      def pause_without_resumption(desired_time)
        $trace.event("Pausing current job without resuming background.")
        @active_job_manager.pause(desired_time, :no_resumption)
      end

      def paused?(job_or_string)
        job = ensure_job(job_or_string)
        @active_job_manager.paused?(job)
      end


      changes_state :stop
      def stop(job_or_string, time)
        $trace.event("Stopping job '#{job_or_string.inspect}'.")
        job = ensure_job(job_or_string)
        @active_job_manager.stop(job, time)
      end

      changes_state :quick_stop
      def quick_stop(time)
        whine_unless(@active_job_manager.running, :no_job_to_stop)
        
        job_to_stop = @active_job_manager.running.job
        $trace.event("Quick-stopping running job #{job_to_stop.inspect}")
        stop(job_to_stop, time)
      end

      changes_state :stop_all
      def stop_all(time)
        $trace.event("Stopping all jobs.")

        stopped = @active_job_manager.active_records.keys.collect { | job |
          stop(job, time)
        }
        sorted_records = stopped.sort
        log_change(:stopped_all_jobs, :records => sorted_records)
        sorted_records
      end

      def stopped?(job_or_string)
        job = ensure_job(job_or_string)
        @active_job_manager.stopped?(job)
      end



      changes_state :add_record
      def add_record(record)
        $trace.event("Adding record #{record.inspect}")
        @records.add(record)
        log_change(:added_finished_record, :record => record)
        record
      end

      changes_state :forget_records
      def forget_records(*records)
        records.each { | given_record | 
          match = @records.record_with_id(given_record.persistent_id)
          if not match
            log_change(:unknown_record_to_forget, :record => given_record)
          else
            $trace.event("Forgetting record #{match.inspect}")

            stop_first = match.is_a? ActiveRecord
            if stop_first
              # Time.at(0) below: the record resulting from the
              # stop is supposed to be deleted and never reused. Suppose
              # it is, in error. Then picking a completely bogus stop
              # time (giving a highly negative elapsed time) makes the
              # bug more obvious.
              match = stop(match.job, Time.at(0))
            end
            @records.delete_if { | rec | rec.persistent_id == match.persistent_id }
            log_change(:forgot_record, :record => match,
                                       :from_stop => stop_first)
          end
        }
        nil
      end

      def records(*filters)
        retval = @records

        filters.each { | filter | 
          retval = filter.run(retval)
        }
        retval
      end

      changes_state :shorten
      def shorten(persistent_id, seconds)
        target = records.record_with_id(persistent_id)
        $trace.event("Shortening #{target.inspect} by #{seconds} seconds.")
        target.shorten_time_accumulated(seconds)
        log_change(:record_shortened, :record => target, :amount => seconds)
        target
      end

      def active_records
        @active_job_manager.active_records
      end


      # Undoing means taking each change recorded in a change_log and
      # undoing it. There's a 1-many mapping between 'doing' methods
      # and changes. Moreover, a particular change may be caused by
      # any of several methods. 

      changes_state :undo
      def undo(change_log)
        change_log.reverse.each { | entry |
          case entry.name
          when :added_finished_record
            record = entry[:record]
            forget_records(record)
          when :record_shortened
            shorten(entry[:record].persistent_id, -entry[:amount])
          when :swapped_background, :forgot_background
            background(entry[:old_background].full_name)
          when :first_background
            forget_background
          when :forgot_record
            record = entry[:record]
            add_record(record)
          when :stopped
            @active_job_manager.restore_stopped_record(entry[:restorable])
          when :stopped_all_jobs
            # Each stopped job will have its own change recorded. Undo that. 
          when :started
            @active_job_manager.unstart_running_job(entry[:new].job)
          when :resumed
            @active_job_manager.restore_resumed_record(entry[:restorable])
          when :paused
            @active_job_manager.restore_paused_record(entry[:restorable])
          when :job_created
            forget_job(entry[:job].full_name)
          when :forgot_job
            accept_job(entry[:job])
          when :job_exists, :unknown_record_to_forget
            # Nothing to undo in these cases.
          else
            flunk("That Marick guy forgot to write the code to undo #{entry.name}.")
          end
        }
      end

      # Utilities
      private

      def ensure_job(job_or_string)
        return job_or_string if job_or_string.is_a? Job
        find_job_named(job_or_string)
      end

    end
  end 
end

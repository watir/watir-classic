require 'timeclock/util/misc'
require 'timeclock/util/InterestingTimes'
require 'timeclock/util/Steps'
require 'timeclock/util/Whine'

require 'timeclock/client/RecordStringifier'
require 'timeclock/client/FriendlyTimes'
require 'timeclock/client/ReferrableItems'

require 'timeclock/marshalled/include-all'

# Superclass for all Actions. An /action/ is invoked when the user types
# a /command/ on the command line or pushes a button on a GUI. 
# Actions call /methods/ on the remote /session/ and turn the results into
# legible text.
#
# Actions are something like a GoF Command pattern, but there's not one
# instance for each invocation. Undoing is done rather differently.

module Timeclock
  module Client

    class Action
      include FriendlyTimes
      include Steps
      include Whine

      attr_reader :name_symbol        # the name of this action

      def initialize(name_symbol, session, referrables, symbol_of_success)
        @name_symbol = name_symbol
        @session = session

        # A "referrable" is something printed by a previous Action that
        # can be referred to by a later Action. Typically, these are
        # records from the 'records' action.
        @referrables = referrables

        # Actions who care about the success of other Actions observe
        # (in the GoF sense) this symbol. There is currently one success
        # symbol for all actions.
        @symbol_of_success = symbol_of_success
      end

      def run(*args)
        subclass_must_implement
        # It would be natural to implement this thusly:
        #       @session.send(@name_symbol, *args)
        # That way, any subclass that didn't require special processing
        # could just defer to the superclass. As it is, they have to
        # define their own run method that does this:
        #       @session.command(*args)
        # How come?
        # 1. @session uses method_missing to trampoline messages
        #    across the wire. That saves having to define each 
        #    remote method there, as well as on the server side. 
        # 2. In the command-line implementation, all the top-level
        #    commands are defined as private in Object. 
        # 3. method_missing obeys public/private rules, so the second
        #    version (@session.command...) works even when the name_symbol
        #    is the name of a top-level command.
        # 4. send ignores those rules, so sending some name_symbols -
        #    those that are both user commands and methods on the
        #    remote session - will invoke the top-level command.
        #    Recursion city.
        #
        # Note: could also construct "@session.command(*args)" here
        # and eval it - but that seems too gross a kludge.
      end

      # I don't define any of these in this superclass because I
      # want each writer of a new action to have to think which is
      # appropriate. If the writer forgets to use one of them, there'll
      # be a missing method failure quickly.

      # These control how the quick_start action works.

      def self.invalidates_pause_memory
        class_eval "def forget_last_pause?; true;   end"
        class_eval "def new_pause?;         false;  end"
      end

      def self.irrelevant_to_pause_memory
        class_eval "def forget_last_pause?; false;   end"
        class_eval "def new_pause?;         false;   end"
      end

      def self.causes_new_pause
        class_eval "def forget_last_pause?; true;   end"
        class_eval "def new_pause?;         true;   end"
      end

      # These determine whether a command can do something that can be
      # undone. Note that not every command that *can* do something
      # actually *does* something. In the latter cases, the undo - just
      # like the do - is a no-op.

      def self.undoable
        class_eval "def changes_state?; true; end"
      end

      def self.nothing_to_undo
        class_eval "def changes_state?; false; end"
      end


      # This is overridden if an action is not to use the system clock.
      # See the 'at' command.
      @@specific_time_desired = nil
      
      # At what time has the user indicated she desires this
      # command to take place?
      def desired_time
        @@specific_time_desired || Time.now
      end

    end
  end
end


##### JOB ACTIONS

# Those actions that deal mainly with jobs.
# Actions are tested indirectly, mainly by the command-line tests.

require 'timeclock/client/Action'

module Timeclock
  module Client

    public

    ## Job

    class JobAction < Action
      undoable
      invalidates_pause_memory
      # Consider
      #   pause
      #   job 'foo'
      #   start
      # Maybe she expects 'foo' to start.

      def run(full_name)
        job_name, subjob_name = Job.parse_full_name(full_name)
        job = Job.named(job_name)
        if subjob_name
          subjob = Job.named_with_parent(subjob_name, job)
          @session.accept_job(subjob)
        else
          @session.accept_job(job)
        end
      end
    end


    # forget_job

    class ForgetJobAction < Action
      undoable
      invalidates_pause_memory
      # It would probably be safe to maintain pause memory, but it does
      # no harm to invalidate it. This is a rare operation.

      def run(full_name)
        @session.forget_job(full_name)
      end

    end


    ## Background

    class BackgroundAction < Action
      undoable
      irrelevant_to_pause_memory

      def run(full_name)
        @session.background(full_name)
      end
    end


    ## Forget_background

    class ForgetBackgroundAction < Action
      undoable
      irrelevant_to_pause_memory

      def run
        @session.forget_background
      end
    end

    ## Jobs

    class JobsAction < Action
      nothing_to_undo
      irrelevant_to_pause_memory

      def run
        @session.jobs
      end
    end        
  end
end

### RECORD ACTIONS
# Those actions that deal mainly with records.
# Actions are tested indirectly, mainly by the command-line tests.

require 'timeclock/client/Action'

module Timeclock
  module Client
    
    public

    ## add_record

    class AddRecordAction < Action
      undoable
      irrelevant_to_pause_memory

      def run(*args)
        time_started = job_fullname = duration = nil
        
        args.each { | arg |
          if arg.is_a? Integer
            duration = arg
          elsif likely_time?(arg)
            time_started = time_from(arg)
          else
            job_fullname = arg
          end
        }
        
        whine_unless(time_started, :no_starting_time)
        whine_unless(job_fullname, :no_job)
        whine_unless(duration, :no_accumulated_time)
        
        record = FinishedRecord.new(time_started, duration,
                                    @session.find_job_named(job_fullname))
        @session.add_record(record)
      end

    end


    ## records and friends

    class RecordsAction < Action
      nothing_to_undo
      irrelevant_to_pause_memory

      def run(job_fullname = nil, *filters)
        if job_fullname
          filters << RecordFilter.by_job_full_name(job_fullname)
        end
        @session.records(*filters)
      end
    end

    class ThisMonthAction < RecordsAction
      def run(job_fullname = nil)
        stop_time = Time.now
        super(job_fullname, RecordFilter.by_month_to_time(stop_time))
      end
    end

    class LastMonthAction < RecordsAction
      def run(job_fullname = nil)
        stop_time = InterestingTimes.beginning_of_month(Time.now)-1
        filter = RecordFilter.by_month_to_time(stop_time)
        super(job_fullname, filter)
      end
    end

    class RecentAction < RecordsAction
      def run(job_fullname = nil)
        filter = RecordFilter.recent(Time.now)
        super(job_fullname, filter)
      end
    end


    ## Shorten and lengthen

    class ShortenAction < Action
      undoable
      irrelevant_to_pause_memory

      def run(record_number, amount)
        target_record = @referrables[record_number]
        shortened = @session.shorten(target_record.persistent_id, amount)
        
        assert(shortened.time_started == target_record.time_started)
        assert(shortened.job == target_record.job)
        assert(shortened.persistent_id == target_record.persistent_id)
      end
    end

    class LengthenAction < ShortenAction
      def run(record_number, amount)
        super(record_number, -amount)
      end
    end


    ## forget

    class ForgetAction < Action
      undoable
      invalidates_pause_memory
      # Consider
      #  start 'foo'
      #  pause
      #  records
      #  forget 1
      #  start
      # Does she expect the forgotten record to resume?


      def run(*record_numbers)
        valid_numbers, invalid_numbers = @referrables.validate(record_numbers)
        whine_unless(invalid_numbers.empty?,
                     :invalid_record_numbers, invalid_numbers)
        
        records = valid_numbers.collect { | number |
          @referrables[number]
        }

        @session.forget_records(*records)
      end
    end
  end
end

### TIMING ACTIONS
# Those actions that mainly affect the ongoing recording of time.
# Actions are tested indirectly, mainly by the command-line tests.

require 'timeclock/client/Action'

module Timeclock
  module Client
    public

    ## Active

    class ActiveAction < Action
      nothing_to_undo
      irrelevant_to_pause_memory

      def run
        @session.active_records
      end
    end


    ## start

    class StartAction < Action
      undoable
      invalidates_pause_memory
      

      def run(full_name)
        @session.start(full_name, desired_time)
      end

    end


    ## Quick_start

    class QuickStartAction < StartAction

      def initialize(*args)
        super
        @symbol_of_success.add_observer(self)
        @implicit_argument = nil
      end
      
      def run
        if @implicit_argument
          super(@implicit_argument)
        else
          whine(:no_job_recently_paused)
        end
      end

      def update(normal_result)  # observer callback
        action = normal_result.action
        if action.new_pause?
          @implicit_argument = @session.last_value.full_name
        elsif action.forget_last_pause?
          @implicit_argument = nil
        end
      end
    end


    ## Start_day

    class StartDayAction < Action
      undoable
      invalidates_pause_memory

      def run
        step(:start_background_job) {
          @session.start_background_job(desired_time)
        }
      end
    end


    ## Stop

    class StopAction < Action
      undoable
      invalidates_pause_memory


      def run(full_name)
        @session.stop(full_name, desired_time)
      end

    end
    

    ## Quick_stop

    class QuickStopAction < StopAction

      def run
        @session.quick_stop(desired_time)
      end
    end


    ## Stop_day

    class StopDayAction < Action
      undoable
      invalidates_pause_memory

      def run
        @session.stop_all(desired_time)
      end


    end


    ## Pause

    class PauseAction < Action
      undoable
      causes_new_pause

      def run
        @session.pause(desired_time)
      end

    end


    ## Pause_day

    class PauseDayAction < PauseAction
      def run
        @session.pause_without_resumption(desired_time)
      end
    end

    ## At
    class AtAction < Action
      # The commands contained within the do...end block may be undoable,
      # but At itself does nothing worth undoing.
      nothing_to_undo
      irrelevant_to_pause_memory

      def run(desired_time_string, &block)
        begin
          @@specific_time_desired =
            checking_time_from(desired_time_string)
          block.call
        ensure
          @@specific_time_desired = nil
        end
      end
    end
  end
end


### UNDO
# The undo action.

require 'timeclock/client/Action'

module Timeclock
  module Client
    
    public

    class UndoAction < Action
      nothing_to_undo
      invalidates_pause_memory

      def initialize(*args)
        super

        @undo_history = []
        @redo_future = []

        # Observe so that we know which successful actions might
        # later be undone.
        @symbol_of_success.add_observer(self)
      end

      def undone_result
        @redo_future.last
      end

      def update(normal_result)
        if normal_result.action.changes_state?
          @undo_history << normal_result
        end
      end

      def run
        whine_if(@undo_history.empty?, :nothing_to_undo)
        @redo_future << @undo_history.pop
        @session.undo(undone_result.change_log)
      end
    end
  end
end

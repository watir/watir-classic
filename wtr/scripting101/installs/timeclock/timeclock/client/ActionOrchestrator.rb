require 'fluid'
require 'observer'

require 'timeclock/util/misc'
require 'timeclock/util/InterestingTimes'
require 'timeclock/util/Steps'
require 'timeclock/util/Whine'

require 'timeclock/client/RecordStringifier'
require 'timeclock/client/FriendlyTimes'
require 'timeclock/client/ReferrableItems'
require 'timeclock/client/Action'
require 'timeclock/client/ActionResult'

require 'timeclock/client/command-line/RDjob'
require 'timeclock/client/command-line/RDtiming'
require 'timeclock/client/command-line/RDrecord'
require 'timeclock/client/command-line/RDundo'

require 'timeclock/client/html/RDjob'
require 'timeclock/client/html/RDtiming'
require 'timeclock/client/html/RDrecord'
require 'timeclock/client/html/RDundo'

module Timeclock
  module Client
    class ActionOrchestrator
      # In normal use, ActionOrchestrator is a singleton. However, the
      # unit tests generate multiple instances. These methods are used
      # to make intent clearer.
      #
      # It's a singleton because of the way command-line commands can
      # be nested. Trace the implementation of at(time) do start_day end
      # and note how start_day's result is transmitted to the caller.
      #
      # It would be nice if only_instance threw a program error if 
      # multiple instances were created. But some of the unit tests
      # call the methods that call the methods that ... are normally
      # used to create the only instance.

      private_class_method :new

      def self.only_instance(session)
        new(session)
      end

      def self.test_instance(session)
        new(session)
      end



      ActionSymbols = [
        :active,
        :add_record,
        :at,
        :background,
        :forget,
        :forget_job,
        :forget_background,
        :job,
        :jobs,
        :last_month,
        :lengthen,
        :pause,
        :pause_day,
        :quick_start,
        :quick_stop,
        :recent,
        :records,
        :shorten,
        :start,
        :start_day,
        :stop,
        :stop_day,
        :this_month,
        :undo]

      ### Initializations

      def action_symbol_to_class(symbol, class_suffix, package = "")
        unless package == ""
          package = package + "::"
        end
        
        words = symbol.to_s.split('_')
        studlified = words.collect { | word | word.capitalize }.join
        action_class_name = package + studlified + class_suffix
        eval(action_class_name)
      end

      def action_symbol_to_action_class(symbol)
        action_symbol_to_class(symbol, "Action")
      end

      def action_symbol_to_describer_class(symbol, package)
        action_symbol_to_class(symbol, "ResultDescriber", package)
      end

      def initialize(session)
        @session = session
        @referrables = ReferrableItems.new

        @observable_success = Object.new
        @observable_success.extend(Observable)

        @actions = Hash.new
        ActionSymbols.each { | symbol |
          klass = action_symbol_to_action_class(symbol)
          @actions[symbol] = klass.new(symbol, @session,
                                       @referrables, @observable_success)
        }

        @result_describers = {}
        @result_describers[:command_line] = {}
        @result_describers[:html] = {}
        ActionSymbols.each { | symbol |
          klass = action_symbol_to_describer_class(symbol, "CommandLine")
          @result_describers[:command_line][symbol] = klass.new(@referrables)

          klass = action_symbol_to_describer_class(symbol, "Html")
          @result_describers[:html][symbol] = klass.new(@referrables)
        }
      end


      ## Work

      include FriendlyTimes
      include Whine

      # Actions can be nested ('at' command). Use this to distinguish
      # the top-level call to attempt from lower-level ones.
      Fluid.defvar(:nested_attempt, false)

      # The block is used when this command takes sub-commands
      # (e.g., at <time> do <stuff> end.)
      def attempt(action_symbol, args, &block)
        assert(@actions.has_key?(action_symbol),
               "No such action #{action_symbol}")
        action = @actions[action_symbol]

        # There can be more than one result because some actions
        # (e.g., at) are compounds. The handling of composite results
        # depends upon the fact that any given client has only one
        # ActionOrchestrator, so nested actions all post results to
        # the same array. This is all in the service of making the
        # command line arbitrary Ruby code.
        @results = [] unless Fluid.nested_attempt
        
        $trace.event("#{action}.#{args.inspect}")
        Fluid.let([:active_steps, []]) {
          begin
            Fluid.let([:nested_attempt, true]) {
              action.run(*args, &block)
            }
            result = NormalActionResult.new(action, @session)
            @observable_success.changed
            @observable_success.notify_observers(result)
            
          rescue TimeclockError => exception
            $trace.announce "Commmand failed. " + exception.inspect
            result = ErrorActionResult.new(action, args,
                                           Fluid.active_steps,
                                           exception)
          end
          @results << result
        }
        :void
      end

      def describe_result_for_command_line
        describe_result(@result_describers[:command_line])
      end

      def describe_result_for_html
        describe_result(@result_describers[:html])
      end

      def describe_result(result_describers)
        individual_results = @results.collect { | result |
          result.describe(result_describers)
        }
        # Prevent a silent command from contributing a blank line to
        # the output. 'at' is the only current example of a silent command. 
        individual_results.reject! { | elt | elt == "" } 
        lines(individual_results)
      end
    end
  end
end


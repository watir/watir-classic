# Note: every method is defined private here. Since this is included in
# an IRB script, we don't want these methods to be public, lest they pollute
# the namespace for all the Timeclock classes.
# 
# In particular, note that dRB works by trampoling method_missing. Any public
# method added to Object would be executed in preference to a method with
# that name on a dRB proxy.

require 'timeclock/client/ActionOrchestrator'

module Timeclock
  module Client
    module CommandLine
      module Interface

        private

        todo 'Make command definitions also define help strings.'
        # As it is, it's too easy to forget to add help line when
        # adding a new command
        
        def help
          puts "job 'name'              - create job named 'name'"
          puts "background 'name'       - make 'name' a background job"
          puts "forget_background       - make there be no background job"
          puts "jobs                    - a list of jobs"
          puts "forget_job 'name'       - forget a job"
          puts ""

          puts "start 'job'             - start named job"
          puts "pause                   - pause current job"
          puts "stop 'job'              - stop named job"
          puts "stop                    - stop the running job"
          puts "active                  - jobs that have been started and not stopped"
          puts "record 'job', 20.minutes, 'jan-23 1:00 pm'"
          puts ""

          puts "start_day               - start the day with the background job"
          puts "pause_day               - pause all jobs"
          puts "stop_day                - stop all active jobs"
          
          puts ""
          puts "records                 - see accumulated records"
          puts "this_month              - records so far this month"
          puts "last_month              - last month's records"
          puts "recent                  - yesterday and today's records"
          puts ""

          puts "The following commands refer to the numbers printed by"
          puts "'records', 'this_month', and similar commands."
          puts "forget 2, 3             - forget those records"
          puts "shorten 1, 20.minutes   - remove 20 minutes from record 1"
          puts "lengthen 1, 20.minutes  - add 20 minutes to record 1"
          puts ""

          puts "The 'at' command allows you to start, pause, start_day (etc.)"
          puts "at particular times in the past or future. Examples:"
          puts "   at '1:00 pm' do start 'job' end"
          puts "   at '2003/01/23 8:00 a.m.' do start_day end"
          puts "   at '9:33 PM yesterday' do stop_day end"
          puts ""
          

          puts "undo                    - undo last command."
          print "exit                    - leave the program"  # No trailing newline.

        end

        def self.attach_to_session(session)
          # This makes the session readily available for command-line
          # fiddling.
          $session = session 

          $command_line_actions = ActionOrchestrator.only_instance(session)
        end

        def self.disengage
          $command_line_actions = nil
        end

        # The following names commands available through the interface
        # and just trampolines the call over to the global object that
        # contains actions for each command. Might seem better to use
        # method_missing. But, since we're messing with Object, we'd
        # be defining it for everything, including program errors.
        
        def self.name_interface_command(name)
          class_eval("def #{name}(*args, &block)
                        $command_line_actions.attempt(:#{name}, args, &block)
                        $command_line_actions.describe_result_for_command_line
                      end
                      private :#{name}")
        end

        # A defaulting interface command attempts one of two actions.
        # The 'quick' action is called when no argument is given.
        # It's supposed to figure out what the argument would have been
        # by the context.
        def self.name_defaulting_interface_command(name)
          class_eval("def #{name}(*args, &block)
                        if args.empty?
                          $command_line_actions.attempt(:quick_#{name}, [], &block)
                        else
                          $command_line_actions.attempt(:#{name}, args, &block)
                        end
                        $command_line_actions.describe_result_for_command_line
                      end
                      private :#{name}")
        end


        name_interface_command(:job)
        name_interface_command(:forget_job)
        name_interface_command(:background)
        name_interface_command(:forget_background)
        name_interface_command(:jobs)
        name_interface_command(:active)
        name_interface_command(:at)
        name_defaulting_interface_command(:start)
        name_interface_command(:start_day)
        name_defaulting_interface_command(:stop)
        name_interface_command(:stop_day)
        name_interface_command(:pause)
        name_interface_command(:pause_day)
        name_interface_command(:add_record)
        name_interface_command(:records)
        name_interface_command(:this_month)
        name_interface_command(:last_month)
        name_interface_command(:recent)
        name_interface_command(:shorten)
        name_interface_command(:lengthen)
        name_interface_command(:forget)
        name_interface_command(:undo)

      end
    end
  end
end

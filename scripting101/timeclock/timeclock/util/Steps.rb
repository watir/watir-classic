require 'fluid'

module Timeclock
  module Steps


    ## An ActiveStep describes a processing step done on behalf of a user.
    ## It is used to print helpful error messages when the processing fails:
    ## "How did we get to this place of failure?"
    ActiveStep = Struct.new('ActiveStep', :name, :args)

    def step(name, *args)
      Fluid.active_steps.push ActiveStep.new(name, args)
      retval = yield
      Fluid.active_steps.pop
      retval
    end

    ## A ChangeLogEntry also describes a processing step done on behalf of a
    ## user. But these are steps relevant when the processing is successful.
    ## They're used to remind the user of exactly what processing happened.

    class ChangeLogEntry < Hash
      attr_reader :name

      def initialize(name, args_hash = {})
        @name = name
        replace args_hash
      end

      def inspect
        "  <ChangeLogEntry #{@name}: #{super}" + $/
      end
    end

    class ChangeLog < Array

      def find_change(name)
        find { | entry | entry.name == name }
      end

      def has?(name)
        find_change(name) != nil
      end

      def [](index_or_key)
        if index_or_key.is_a? Integer
          super
        else
          find_change(index_or_key)
        end
      end

      # Answer an array of ChangeLogEntries matching the action
      def matching(name)
        find_all { | entry | entry.name == name } 
      end

      def only(expected_change = nil)
        assert(length == 1, "Unexpected change log: #{inspect}")
        if expected_change
          assert(expected_change == self[0].name,
                 "Expected change #{expected_change} but was #{self[0].name}.")
        end
        self[0]
      end
    end


    todo 'using magic functions to hide the change log is kinda gross'

    Fluid.defvar(:change_log, ChangeLog.new)

    def clear_change_log
      Fluid.change_log = ChangeLog.new
    end
    
    def log_change(action, args_hash = {})
      Fluid.change_log.push ChangeLogEntry.new(action, args_hash)
    end

    def change_log
      Fluid.change_log
    end

    def with_fresh_change_log
      Fluid.let([:change_log, ChangeLog.new]) {
        yield
      }
    end
  end
end

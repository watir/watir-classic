require 'timeclock/util/misc'
require 'timeclock/util/Steps'

module Timeclock

  class RichlyCallingWrapper
    include Steps

    attr_reader :wrapped     
    attr_reader :last_complete_result # everything that happened at last call
    # And the constituent parts of "everything"...
    attr_reader :last_command,        # what was attempted
      :last_change_log,     # log of actions
      :last_value           # value returned.

    # RichlyCallingWrapper is given a RichlyCalledWrapper or a proxy to
    # it. It might seem that there should be a RichlyCallingWrapper.wrap
    # method that takes the endpoint and generates the RichlyCalledWrapper.
    # Bad idea, since the called wrapper is typically at the other end of
    # a network connection.
    def initialize(wrapped)
      @wrapped = wrapped
    end

    def method_missing(command, *args)
      @last_complete_result = @wrapped.invoke(Command.new(command, args))
      @last_command = @last_complete_result.command
      @last_change_log = @last_complete_result.change_log
      @last_value = @last_complete_result.value
    end

  end
end

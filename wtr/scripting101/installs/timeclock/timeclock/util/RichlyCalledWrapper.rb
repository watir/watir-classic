require 'timeclock/server/Session'
require 'timeclock/util/Steps'
require 'fluid'
require 'timeclock/marshalled/include-all'

module Timeclock
  class RichlyCalledWrapper
    include Steps

    attr_reader :wrapped

    def initialize(wrapped)
      @wrapped = wrapped
    end

    def invoke(command)
      with_fresh_change_log {
        $trace.announce(command.inspect)
        value_result = @wrapped.send(command.name, *command.args)

        prog1(NormalRichResult.new(command, change_log, value_result)) { 
          # This is a lame version of aspect-like 'after' methods. 
          if @wrapped.respond_to? :after
            @wrapped.after(command.name)
          end
        }
      }
    end

  end
end

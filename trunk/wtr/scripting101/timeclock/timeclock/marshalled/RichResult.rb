require 'timeclock/util/ruby-extensions'

module Timeclock
  module Marshalled

    NormalRichResult =
      Struct.new("NormalRichResult",
                 :command, :change_log, :value)

    class NormalRichResult
      def inspect
        lines("Rich result:",
              command.inspect,
              value.inspect,
              change_log.collect { | e | e.inspect },
              "End of change log")
      end
    end

    todo 'delete ExceptionalRichResult?'
    # Right now, there are no active steps on the PersistenceManager
    # side, so no need to package them up to send them across a wire.
    # If there ever is a need, this is the way to do it.

    ExceptionalRichResult =
      Struct.new("ExceptionalRichResult", :active_steps, :exception)

  end
end

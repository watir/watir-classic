# The undo action.

require 'timeclock/client/ResultDescriber'
require 'timeclock/client/command-line/ResultDescriberUtils'

module Timeclock
  module Client
    module CommandLine
      
      public

      class UndoResultDescriber < ResultDescriber

        def attempt_description
          "Timeclock tried to undo the last command."
        end

        def success_strings(undo_result, all_describers)
          undo_action = undo_result.action
          # 'xxx' refers to the action that was undone
          xxx_action = undo_action.undone_result.action
          xxx_symbol = xxx_action.name_symbol
          if undo_result.change_log.length > 0
            ["Undid the #{xxx_symbol} command. To be specific:",
              all_describers[xxx_symbol].undo_success_strings(undo_result, all_describers)
            ]
          else
            ["In this case, the #{xxx_symbol} command did nothing,",
              "so there is nothing to undo."
            ]
          end
        end
      end
    end
  end
end

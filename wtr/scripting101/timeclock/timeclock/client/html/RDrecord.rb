# Those actions that deal mainly with records.
# They're tested indirectly through tRequestHandler.rb

require 'timeclock/client/ResultDescriber'
require 'timeclock/client/ResultDescriberUtils'

module Timeclock
  module Client
    module Html
      
      public

      ## add_record

      class AddRecordResultDescriber < ResultDescriber
      end


      ## records and friends

      class RecordsResultDescriber < ResultDescriber
      end

      class ThisMonthResultDescriber < RecordsResultDescriber
      end

      class LastMonthResultDescriber < RecordsResultDescriber
      end

      class RecentResultDescriber < RecordsResultDescriber
      end


      ## Shorten and lengthen

      class ShortenResultDescriber < ResultDescriber
      end

      class LengthenResultDescriber < ShortenResultDescriber
      end


      ## forget

      class ForgetResultDescriber < ResultDescriber
      end
    end
  end
end

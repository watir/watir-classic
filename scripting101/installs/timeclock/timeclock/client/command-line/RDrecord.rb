# Those actions that deal mainly with records.

require 'timeclock/client/ResultDescriber'
require 'timeclock/client/command-line/ResultDescriberUtils'

module Timeclock
  module Client
    module CommandLine
      
      public

      ## add_record

      class AddRecordResultDescriber < ResultDescriber
        include ResultDescriberUtils
        
        def attempt_description(*ignored_args)
          "Timeclock tried to add a record."
        end


        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:added_finished_record)
          added_record_string(entry)
        end

        def undo_success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:forgot_record)
          forgot_record_string(entry)
        end
      end


      ## records and friends

      class RecordsResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def success_strings(action_result, all_describers)
          records = action_result.value
          @referrables.build_index(records)
          referrable_record_listing(records)
        end

      end

      class ThisMonthResultDescriber < RecordsResultDescriber
      end

      class LastMonthResultDescriber < RecordsResultDescriber
      end

      class RecentResultDescriber < RecordsResultDescriber
      end


      ## Shorten and lengthen

      class ShortenResultDescriber < ResultDescriber
        include ResultDescriberUtils
        def success_strings(action_result, all_describers)
          entry = action_result.change_log.only(:record_shortened)
          [ "The record's accumulated time has changed:",
            RecordStringifier.new(entry[:record]).summary
          ]
        end

        def undo_success_strings(action_result, all_describers)
          success_strings(action_result, all_describers)
        end
      end

      class LengthenResultDescriber < ShortenResultDescriber
      end


      ## forget

      class ForgetResultDescriber < ResultDescriber
        include ResultDescriberUtils

        def attempt_description(*record_numbers)
          if record_numbers.length == 1
            "Timeclock tried to forget record #{record_numbers[0]}."
          else
            "Timeclock tried to forget records #{record_numbers.join(', ')}."
          end
        end

        def success_strings(action_result, all_describers)
          
          action_result.change_log.collect { | entry |
            case entry.name
            when :forgot_record
              # If this forgetting was the result of first stopping a
              # job and then forgetting its record, talking about the
              # forgetting is redundant and potentially confusing. So don't.
              unless entry[:from_stop]
                forgot_record_string(entry)
              end
            when :stopped
              record = entry[:restorable]
              "Stopped the #{record.state} job '#{record.job.full_name}' and removed its record."
            when :unknown_record_to_forget
              record = entry[:record]
              ["Timeclock tried to forget a record for #{record.job.full_name}.",
                "But there is no such record. (Perhaps it's already been deleted.)"
              ]
            end
          }
        end

        def undo_success_strings(action_result, all_describers)
          change_log = action_result.change_log.dup
          stops = change_log.find_all { | entry |
            entry.name == :restored_stopped_record
          }
          stops.each { | stop |
            stop_index = change_log.index(stop)
            assert(:added_finished_record == change_log[stop_index-2].name,
                   "Stopping an active job should add a record")
            assert(:forgot_record == change_log[stop_index-1].name,
                   "Stopping an active job should forget a just-added record")
            assert(change_log[stop_index-2][:record].persistent_id ==
                   change_log[stop_index-1][:record].persistent_id,
                   "Stopping an active job should add and remove same record.")
            # Therefore, we can remove these records from the list. User
            # doesn't want to hear about redundancy.
            change_log.delete_at(stop_index-1)
            change_log.delete_at(stop_index-2)
          }
          
          change_log.collect { | entry |
            case entry.name
            when :added_finished_record
              describe_record_string(entry, "Put back this record: ")
            when :restored_stopped_record
              restored_stopped_record_strings(entry)
            else
              flunk_unexpected_undo_change(entry)
            end
          }
        end
      end
    end
  end
end

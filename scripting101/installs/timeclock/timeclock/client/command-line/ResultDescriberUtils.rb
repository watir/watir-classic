module Timeclock
  module Client
    module CommandLine
      module ResultDescriberUtils
        def forgot_background_string(log_entry)
          name = log_entry[:old_background].full_name
          common_line = "'#{name}' is no longer the background job."
          if log_entry[:currently_in_use]
            [common_line,
              "Since it is currently in use, the change will take effect after you stop it.",
              "Thereafter, the job will still exist and can be used in the ordinary way."
            ]
          else
            [common_line,
              "The job still exists and can be used in the ordinary way."
            ]
          end
        end

        def restored_stopped_record_strings(log_entry)
          record = log_entry[:restored_record]
          ["Undid the stopping of '#{record.job.full_name}' and reinstalled this record:",
            RecordStringifier.new(record).summary]
        end

        def restored_resumed_record_strings(log_entry)
          record = log_entry[:restored_record]
          ["'#{record.job.full_name}' is no longer resumed. It's back to this:",
            RecordStringifier.new(record).summary]
        end

        def restored_paused_record_strings(log_entry)
          record = log_entry[:restored_record]
          ["Restarted '#{record.job.full_name}' and resumed this record:",
            RecordStringifier.new(record).summary]
        end

        def describe_record_string(log_entry, prefix)
          "#{prefix}" + RecordStringifier.new(log_entry[:record]).summary
        end

        def forgot_record_string(log_entry)
          describe_record_string(log_entry, "Forgot this record: ")
        end

        def added_record_string(log_entry)
          describe_record_string(log_entry, "Added this record: ")
        end

        def swapped_background_strings(entry)
          new_name = entry[:new_background].full_name
          old_name = entry[:old_background].full_name
          ["'#{old_name}' is no longer the background job.",
            "It has been replaced by '#{new_name}'.",
            "This change will take effect the next time you use 'start_day'.",
            "Thereafter, '#{new_name}' will resume recording time when other jobs pause or stop."
          ]
        end

        ## Other miscellaneous string construction methods.
        
        def referrable_record_listing(records)
          individual_lines = detail_strings(records)
          summary_lines = summary_strings(records)
          
          lines(individual_lines, summary_lines)
        end


        def detail_strings(records)
          individual_lines = []
          records.each_with_index { | rec, index |
            pretty = RecordStringifier.new(rec)
            individual_lines << sprintf("%4s: %s", 
                                        index+1,
                                        RecordStringifier.new(rec).summary)
          }
          individual_lines
        end

        def summary_strings(records)
          # No point in summarizing one element. Note that we do
          # summarize zero to highlight the fact there were zero.
          return [] if records.length == 1

          total_time = records.sum_by(:time_accumulated)
          total_time_string = PrettyTimes.columnar.hours(total_time)
          ["", "Total: #{total_time_string}"]
        end

      end
    end
  end
end

require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/PageSketch'
require 'timeclock/client/PrettyTimes'
require 'timeclock/client/RecordStringifier'
require 'timeclock/marshalled/include-all'

module Timeclock
  module Client
    module Html

      class MainPageSketch < PageSketch

        attr_accessor :session_id   # Fills in a template method from PageSketch.

        def initialize(user, session, last_result = "",
                       last_result_is_error = false)
          @user = user
          @session_id = session.id
          @jobs = session.jobs
          @active_records = session.active_records
          @running = @active_records.values.find { | ar| ar.running? }
          @paused = @active_records.values.find_all { | ar | ar.paused? } 
          @last_result = last_result
          @last_result_is_error = last_result_is_error
          @recent_records = session.records(RecordFilter.recent(Time.now))
          super "#{@user.capitalize}'s Timeclock"
        end

        def body_guts
          column_attrs = {:width => "33%", :align => "center",
                          :style => "vertical-align: top;"} 
          [background_buttons_xhtml,
           table({:align => 'center'},
                 tr(td(column_attrs,
                       vertical(start_job_table_xhtml,
                                create_job_table_xhtml)),
                    td(column_attrs,
                       vertical(last_results_xhtml,
                                running_job_xhtml,
                                control_running_job_xhtml)),
                    td(column_attrs,
                       vertical(paused_job_table_xhtml)))),
            recent_records_table]
        end

        ## Top of the page: 'Start the day' and friends

        todo 'pause_or_stop_day is awkward'
        # I do this because I want the buttons to be aligned. I should
        # probably make them each a cell in a table and just put the
        # right number of cells in. But I'm not sure how to make the
        # spacing look as good.
        def background_buttons_xhtml
          return '' if @jobs.background_job.nil?

          if @active_records.empty?
            command_form('start_day',
                         p(center,
                           submit('start_day', "Start the Day"),
                           "<br />",
                           "This starts the background job."))
          else
            command_form('pause_or_stop_day',
                         p(center,
                           @running ? submit('pause_day', "Pause the Day") : '',
                           submit('stop_day', 'Stop the Day')))
          end
        end

        ## Left side of page: jobs to start and such.

        def job_buttons_xhtml
          names = @jobs.values.collect { | job | job.full_name }.sort
          names.collect { | name |
            body_row(submit('name', name))
          }
        end

        def start_job_table_xhtml
          command_form('start',
                       tight_table(head_row(b("All the jobs")),
                                   head_row("Click to start one"),
                                   *job_buttons_xhtml))
        end

        def create_job_table_xhtml
          command_form('job',
                       tight_table(head_row(b("Or create a new job")),
                                   tr(td(center(BodyBlueFill),
                                         input({:type => 'text',
                                                 :name => 'name',
                                                 :size => '16',
                                                 :maxlength => '100'}) , 
						 input({:type => 'submit',
                                                 :name => 'create_a_job',
                                                 :value => 'Create'})	 ))))
        end


        ## Middle of the page: last command's results and current running job

        def last_results_xhtml
          p(@last_result_is_error ? TextResultRed : TextResultGreen,
            @last_result)
        end

        def running_job_text
          if @running
            name = @running.job.full_name
            hours = PrettyTimes.tight.hours(@running.time_accumulated)
            "Job '#{name}' is running. #{hours} accumulated."
          else
            "No job is recording time."
          end
        end


        def running_job_xhtml
          if @running
            command_form('refresh',
                         p(center,
                           running_job_text,
                           submit('refresh', 'Refresh')))
          else
            p(center, running_job_text)
          end
        end

        def control_running_job_xhtml
          if @running
            name = @running.job.full_name
            command_form('pause_or_stop_job',
                         hidden('name', name),
                         submit('pause', "Pause #{name}"),
                         submit('quick_stop', "Stop #{name}"))
          else
            ''
          end
        end

        ## Right side of page: paused jobs

        def paused_job_buttons_xhtml
          if @paused.empty?
            [body_row("None")]
          else
            names = @paused.collect { | ar | ar.job.full_name }.sort
            names.collect { | name | 
              body_row(submit('name', name))
            }
          end
        end

        def paused_job_table_xhtml
          command_form('start',
                       tight_table(head_row(b("Paused jobs")),
                                   head_row("Click to restart one"),
                                   *paused_job_buttons_xhtml))
        end

        ## Bottom of the page: recent records

        def recent_records_table
          rows = @recent_records.reverse.collect { | rec |
            stringifier = RecordStringifier.new(rec)
            state = if rec.running?
                      b("running")
                    elsif rec.paused?
                      "paused"
                    else
                      ''
                    end
            tr({:bgcolor => BodyBlueFill},
               td(stringifier.full_job_name),
               td(stringifier.start_date_time),
               td(stringifier.cumulative_hours),
               td(state)) }
                                         
          table({:align => 'center', :width => '66%', :border => "1",
                  :cellspacing => "0", :cellpadding => "3"},
                tr({:bgcolor => HeaderBlueFill},
                   td({:align => "center", :colspan => "4" },
                      'Recent Records')),
                *rows)
        end

      end
    end
  end
end

require 'timeclock/client/html/MainPageSketch'
require 'timeclock/marshalled/include-all'
require 'timeclock/util/Time'
require 'timeclock/client/tutil'

module Timeclock
  module Client
    module Html

      class MainPageSketchTests < ClientTestCase

        class MockSession
          attr_accessor :jobs, :active_records

          def initialize
            @jobs = JobHash.new
            job('misc')
            @active_records = {}
            @records = RecordList.new
            end

          def start(jobname)
            job = @jobs[jobname]
            @active_records[job] = ActiveRecord.start(job, Time.now)
          end

          def pause(jobname)
            job = @jobs[jobname]
            @active_records[job].pause(Time.now)
          end

          def job(name)
            @jobs[name] = Job.named(name)
          end

          def records(*ignored)
            @records
          end

        end

        def setup
          Time.set(Time.now)
        end

        def teardown
          Time.use_system_time
        end

        ### support
        def assert_sorted_name_buttons(xhtml, *names)
          matches = names.collect { | name |
            val = /input name="name" type="submit" value="#{name}"/ =~ xhtml
            assert(val != nil, "#{name} not found in sorted name list, #{xhtml}")
            val
          }
          assert_equal(matches.sort, matches, "list is not sorted")
        end


        ### Tests

        ## Miscellaneous

        def test_page_name
          sketch = MainPageSketch.new('marick', MockSession.new)
          assert_equal("Marick's Timeclock", sketch.page_name)
        end


        ## Top of page: starting the day, etc.

        def test_when_there_are_start_day_and_similar_buttons
          session = MockSession.new
          sketch = MainPageSketch.new('irrelevant', session)

          start_day_re = /action="start_day"/
          # A single form contains both buttons
          other_day_re = /action="pause_or_stop_day"/
          specifically_pause_re = /name="pause_day"/
          specifically_stop_re = /name="stop_day"/

          # Nothing when there's no background job.
          assert_equal('', sketch.background_buttons_xhtml)

          # But there's a start_day is when there is a background job
          # and nothing is running.
          session.jobs['misc'].make_background
          sketch = MainPageSketch.new('irrelevant', session)
          assert_match(start_day_re, sketch.background_buttons_xhtml)
          assert_equal(nil, other_day_re =~ sketch.background_buttons_xhtml)

          # Pause_day and stop_day replace start_day when a job is running.
          session.start('new job')
          sketch = MainPageSketch.new('irrelevant', session)
          assert_equal(nil, start_day_re =~ sketch.background_buttons_xhtml)
          assert_match(other_day_re, sketch.background_buttons_xhtml)
          assert_match(specifically_pause_re, sketch.background_buttons_xhtml)
          assert_match(specifically_stop_re, sketch.background_buttons_xhtml)

          # Only pause_day appears when all jobs are paused. 
          session.pause('new job')
          sketch = MainPageSketch.new('irrelevant', session)
          assert_equal(nil, start_day_re =~ sketch.background_buttons_xhtml)
          assert_match(other_day_re, sketch.background_buttons_xhtml)
          assert_nil(specifically_pause_re =~ sketch.background_buttons_xhtml)
          assert_match(specifically_stop_re, sketch.background_buttons_xhtml)
        end
          

        ## Left of page: starting and creating jobs.

        def test_start_job_table_xhtml

          session = MockSession.new
          # make a lot of jobs to reduce chance list is accidentally sorted.
          session.job('match-me-two')
          session.job('match-me-three')
          session.job('bazoom')
          session.job('geep')
          xhtml = MainPageSketch.new('irrelevant', session).start_job_table_xhtml
          assert_match(/action="start"/, xhtml)
          assert_sorted_name_buttons(xhtml,
                                     "bazoom", "geep", "match-me-three",
                                     "match-me-two", "misc")
        end

        def test_create_job_table_xhtml
          sketch = MainPageSketch.new('irrelevant', MockSession.new)
          xhtml = sketch.create_job_table_xhtml
          assert_match(/action="job"/, xhtml)
        end


        ## middle of page: the last command and current running job

        def test_xhtml_includes_last_results
          result = 'this is a command result'
          sketch = MainPageSketch.new('irrelevant', MockSession.new, result)
                                      
          assert_match(Regexp.new(result), sketch.to_xhtml)
        end

        def test_running_job_text
          session = MockSession.new
          sketch = MainPageSketch.new('irrelevant', session)
          assert_match(/No job is recording time/, sketch.running_job_text)

          session.start('misc')
          Time.advance(30.minutes)
          sketch = MainPageSketch.new('irrelevant', session)
          assert_equal("Job 'misc' is running. 0.50 hours accumulated.",
                       sketch.running_job_text)
        end

        def test_running_job_has_pause_or_stop_button
          session = MockSession.new

          # Nothing when nothing's running
          sketch = MainPageSketch.new('irrelevant', session)
          assert_equal('', sketch.control_running_job_xhtml)

          session.start('misc')
          sketch = MainPageSketch.new('irrelevant', session)
          xhtml = sketch.control_running_job_xhtml
          assert_match(/pause_or_stop_job/, xhtml)
          assert_match(/name="pause"/, xhtml)
          assert_match(/name="quick_stop"/, xhtml)

          # Display is the same whether or not the running job is
          # a background job. When it's not, I thought of having an
          # annotation that says the background job will restart.
          # However, I decided that was too wordy. If I do add it later,
          # I should note that the background job only volunteers to
          # restart if it was started with 'start_day', NOT with start.
        end


        ## right of page: paused jobs

        def test_paused_job_table_when_there_are_no_paused_jobs_xhtml
          session = MockSession.new

          check = proc {
            sketch = MainPageSketch.new('irrelevant', session) 
            xhtml = sketch.paused_job_table_xhtml
            assert_match(/Paused jobs/, xhtml)
            assert_match(/None/, xhtml)
          }

          # No job is running
          check.call

          # Same message when there's only a running job.
          session.start('misc')
          check.call
        end

        def test_paused_job_table_with_paused_jobs
          session = MockSession.new
          session.start('misc'); 
          session.pause('misc')

          sketch = MainPageSketch.new('irrelevant', session)
          xhtml = sketch.paused_job_table_xhtml
          assert_match(/Paused jobs/, xhtml)
          assert_match(/action="start"/, xhtml)
          assert_sorted_name_buttons(xhtml, 'misc')

          ## start and pause three more. Ensure that they're sorted.
          session.job('second')
          session.start('second')
          session.pause('second')
          session.job('a_third')
          session.start('a_third')
          session.pause('a_third')
          session.job('4')
          session.start('4')
          session.pause('4')

          sketch = MainPageSketch.new('irrelevant', session)
          xhtml = sketch.paused_job_table_xhtml
          assert_sorted_name_buttons(xhtml, '4', 'a_third', 'misc', 'second')
        end

        ## bottom of page: records

        def test_recent_records_table
          session = MockSession.new
          finished = FinishedRecord.new(Time.local(2001),
                                        1.hour,
                                        session.job('finisheD'))

          pause_start = Time.local(2002)
          paused = ActiveRecord.start(session.job('pauseD'), Time.local(2002))
          paused.pause(pause_start + 2.hours)

          started = ActiveRecord.start(session.job('starteD'),
                                       Time.now)
          
          session.records.add(finished)
          session.records.add(paused)
          session.records.add(started)

          sketch = MainPageSketch.new('irrelevant', session)

          # The most recently started record comes first. This records
          # the order of regexp matches.
          match_order = []
          assert_ordered_match = proc { | regexp, xhtml |
            assert_match(regexp, xhtml)
            match_order << (regexp =~ xhtml)
          }

          xhtml = sketch.recent_records_table
          
          assert_ordered_match[/starteD/, xhtml]
          start_date_time = PrettyTimes.columnar.date_time(Time.now)
          assert_ordered_match[Regexp.new(start_date_time), xhtml]
          assert_ordered_match[/0.00 hours/, xhtml]
          assert_ordered_match[/running/, xhtml]

          assert_ordered_match[/pauseD/, xhtml]
          assert_ordered_match[Regexp.new("2002/01/01 12:00 AM"), xhtml]
          assert_ordered_match[/2.00 hours/, xhtml]
          assert_ordered_match[/paused/, xhtml]

          assert_ordered_match[/finisheD/, xhtml]
          assert_ordered_match[Regexp.new("2001/01/01 12:00 AM"), xhtml]
          assert_ordered_match[/1.00 hour/, xhtml]

          assert_equal(match_order.sort, match_order)
        end
      end
    end
  end
end

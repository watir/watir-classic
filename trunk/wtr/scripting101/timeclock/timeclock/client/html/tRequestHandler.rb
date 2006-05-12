require 'timeclock/server/UserManager'
require 'timeclock/client/html/RequestHandler'
require 'timeclock/client/html/HttpGetParser'
require 'timeclock/client/tutil.rb'
require 'timeclock/util/Time'
require 'timeclock/marshalled/include-all'
require 'timeclock/server/PersistentUser'
require 'timeclock/client/html/Formatting'
require 'timeclock/client/ResultDescriberUtils'

## A note on testing command results. For many commands, the text of the
## result is the same for both the command-line and HTML versions. The
## precise text is thoroughly tested in the command line cases. Where the
## text varies in a way that's awkward to test (for example, includes the
## date), we simply check that a unique subset of the string is present in
## the right part of the HTML. That is, we check that the common method was
## called, not that (once again) it yields the exact right results.

module Timeclock
  module Client
    module Html

      class RequestHandlerTests < Test::Unit::TestCase
        include Formatting
        # We can use superclass string-constructing methods to test
        # subclass string testing.
        include Client::ResultDescriberUtils

        def no_user(name)
          Server::PersistentUser.new(name).delete
        end

        def setup
          Time.set(Time.local(2002, 10, 23, 8))
          @user_manager = Server::UserManager.new
          @handler = RequestHandler.new(@user_manager)
          @default_job_name = 'default job'

          @uncreated_user = 'rht-quiescent'
          no_user(@uncreated_user)

          @quiescent_user = 'rht-other_uncreated'
          session = @handler.ensure_session_for_user(@quiescent_user)
          session.accept_job(Job.named(@default_job_name))
          @handler.deactivate_session(session.object_id)
          assert(! @handler.user_has_session?(@quiescent_user))

          @active_user = 'rht-default'
          @active_session = @handler.ensure_session_for_user(@active_user)
          @active_session.accept_job(Job.named(@default_job_name))
          # Not deactivated
          assert(@handler.user_has_session?(@active_user))
        end

        def teardown
          @handler.deactivate_session(@active_session.object_id)
          no_user(@uncreated_user)
          no_user(@quiescent_user)
          no_user(@active_user)

          Time.use_system_time
        end


        def handle(name, args = {})
          request = HttpRequest.new(name, args)
          sketch = @handler.handle(request)
        end

        def handle_active(name, args = {})
          args['session'] = @active_session.object_id
          handle(name, args)
        end
            

        ## Tests of utilities
        
        def test_session_for_user
          first_instance = @handler.ensure_session_for_user(@quiescent_user)
          assert(@handler.user_has_session?(@quiescent_user))

          # Second creation returns previous session.
          second_instance = @handler.ensure_session_for_user(@quiescent_user)
          assert_equal(first_instance.object_id, second_instance.object_id)

          # You can create more than one user. (Duh)
          another_user = @handler.ensure_session_for_user(@uncreated_user)
          assert(@handler.user_has_session?(@uncreated_user))
          assert(@handler.user_has_session?(@quiescent_user))
          assert(another_user != first_instance)
        end


        ## Tests of requests that do not involve existing sessions.
        def test_entering_site_request
          sketch = handle('')
          assert_equal(LoginPageSketch, sketch.class)
        end

        def test_login_request_very_first_time
          sketch = handle('login', {'name'=>@uncreated_user})
          assert(@handler.user_has_session?(@uncreated_user))
          assert_equal(FirstJobCreationPageSketch, sketch.class)
        end

        def test_login_request_later
          sketch = handle('login', {'name'=> @quiescent_user})
          assert(@handler.user_has_session?(@quiescent_user))
          assert_equal(MainPageSketch, sketch.class)
        end

        todo 'duplicate login requests - reissuing while session still exists.'



        ## Generic error tests.

        def test_unknown_request
          sketch = handle('foobar', {'name'=>'new-job'})
          assert_equal(BadRequestPageSketch, sketch.class)
          assert_match(/unknown request 'foobar'/, sketch.to_xhtml)
          
        end

        def test_unknown_session_id
          sketch = handle('job', {'name'=>'new-job', 'session' => 12})
          assert_equal(BadRequestPageSketch, sketch.class)
          assert_match(/Your session no longer exists./, sketch.to_xhtml)
        end

        def test_missing_argument
          # The argument is supposed to be 'name', not 'job'
          sketch = handle_active('start', {'job' => @default_job_name })
          assert_equal(BadRequestPageSketch, sketch.class)
          assert_match(/Missing argument 'name'/, sketch.to_xhtml)
        end

        def test_null_pointer_exception
          # We'd like the server to survive arbitrary null pointer
          # exceptions, so that one user's failure doesn't take everyone
          # down.

          sketch = handle('cause-null-pointer-exception')
          assert_equal(BadRequestPageSketch, sketch.class)
          assert_match(/An exception was raised/, sketch.to_xhtml)
          # Check that there's a stack trace in the output.
          assert_match(/RequestHandler.rb/, sketch.to_xhtml)
        end


        ## Tests of requests that do involve existing sessions.
        ## Includes error cases.

        def test_job_request
          sketch = handle_active('job', {'name'=> 'new-job'})
          assert(@active_session.jobs.has_key?('new-job'))
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(green_p("Job 'new-job' created."),
                       sketch.last_results_xhtml)
        end

        def test_job_request_when_job_is_made_to_be_background
          sketch = handle_active('job',
                                 {'name' => 'background',
                                   'background' => 'true' })
          assert(@active_session.jobs.has_key?('background'))
          assert(@active_session.jobs['background'].is_background?)
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(green_p("Job 'background' created.",
                               %Q{'background' will be started when you press the "Start the Day" button.}),
                       sketch.last_results_xhtml)
        end


        def test_job_request_with_empty_job_name
          sketch = handle_active('job', {'name' => ''})
          assert_equal(false, @active_session.jobs.has_key?(''))
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(red_p("Sorry, but you have to give a job name."),
                       sketch.last_results_xhtml)
        end

        def start_default
          handle_active('start', {'name' => @default_job_name})
        end

        def test_start
          sketch = start_default
          assert_equal(true, @active_session.running?(@default_job_name))
          assert_equal(MainPageSketch, sketch.class)
          assert_match(/Job '#{@default_job_name}' started at/,
                       sketch.last_results_xhtml)
          assert_match(/Job '#{@default_job_name}' is running./,
                       sketch.to_xhtml)
        end

        def test_start_day_pause_day_stop_day_cycle
          @active_session.background(@default_job_name)
          
          sketch = handle_active('start_day')
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.running?(@default_job_name))
          assert_match(/Job '#{@default_job_name}' started at/,
                       sketch.last_results_xhtml)
          assert_match(/Job '#{@default_job_name}' is running./,
                       sketch.to_xhtml)
          
          sketch = handle_active('pause_or_stop_day',
                                 {'pause_day' => 'irrelevant'})
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.paused?(@default_job_name))
          assert_match(/Paused '#{@default_job_name}' at/,
                       sketch.last_results_xhtml)
          assert_match(/No job is recording time./, sketch.to_xhtml)

          sketch = handle_active('pause_or_stop_day',
                                 {'stop_day' => 'irrelevant'})
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.stopped?(@default_job_name))
          stop_time_string = Time.now.strftime(tight_time_format)
          assert_equal(green_p("Stopped all jobs at #{stop_time_string}."),
                       sketch.last_results_xhtml)
          assert_match(/No job is recording time./, sketch.to_xhtml)
        end

        def test_pause_or_stop_day_missing_arg
          sketch = handle_active('pause_or_stop_day')
          assert_equal(BadRequestPageSketch, sketch.class)
          assert_match(/Missing argument/, sketch.to_xhtml)
        end

        def test_pause_and_stop
          @active_session.accept_job(Job.named('background'))
          @active_session.background('background')
          @active_session.start_background_job(Time.now)
          Time.advance(1.hour)
          @active_session.start(@default_job_name, Time.now)
          Time.advance(2.hours)
          
          # Pause the current job.
          sketch = handle_active('pause_or_stop_job', {'pause' => 'ignored'})
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.paused?(@default_job_name))
          # The generic result message is used, so no need to test it again. 

          # Start again - use web interface, for fun.
          sketch = handle_active('start', {'name' => @default_job_name })
          assert_equal(MainPageSketch, sketch.class)

          # Stop it
          sketch = handle_active('pause_or_stop_job', {'quick_stop' => 'ignored'})
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.stopped?(@default_job_name))
          assert_match(/Stopped 'default job'./, sketch.last_results_xhtml)
          assert_match(/It had accumulated 2.00 hours./,
                       sketch.last_results_xhtml)
          assert_match(/Resuming the background job 'background'./,
                       sketch.last_results_xhtml)

          # Now stop the background job.
          sketch = handle_active('pause_or_stop_job', {'quick_stop' => 'ignored'})
          assert_equal(MainPageSketch, sketch.class)
          assert_equal(true, @active_session.stopped?(@default_job_name))
          assert_match(/Stopped 'background'./, sketch.last_results_xhtml)
          assert_match(/Note that 'background' is the background job./,
                       sketch.last_results_xhtml)
          assert_match(/It won't resume the next time you stop or pause a running job/,
                       sketch.last_results_xhtml)
          assert_match(/It had accumulated 1.00 hour./,
                       sketch.last_results_xhtml)
        end
          

        def test_refresh
          start_default
          sketch = handle_active('refresh')
          assert_equal(MainPageSketch, sketch.class)
        end
      end
    end
  end
end

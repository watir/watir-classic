require 'timeclock/server/Session'
require 'timeclock/util/InterestingTimes'
require 'timeclock/util/test-util'
require 'timeclock/util/Steps'
require 'timeclock/util/Time'

module Timeclock
  module Server

    # Note that the start, stop, and pause methods don't have their
    # own tests. They're tested implicitly by other tests (except for
    # the error cases).

    # I don't care whether the server makes a copy of a job/subjob or
    # stores the actual job. To show that it works either way, we
    # sometimes make a copy before any modifications.

    # The methods under test produce a user log that's used to
    # display effects to the user and also to undo. That's not tested
    # here. It's tested via the command-line commands.

    class SessionTests < Test::Unit::TestCase
      include Steps

      TEST_USER = "session facade tests"

      def setup
        PersistentUser.new(TEST_USER).delete
        @session = Session.new(TEST_USER)
        clear_change_log
      end

      todo 'add a wrapper to test::unit in addition to setup/teardown'
      # That way, I could wrap each test in Steps::with_fresh_change_log.

      def teardown
        PersistentUser.new(TEST_USER).delete
        Time.use_system_time
        clear_change_log
      end

      # This is used only in tests where the details of accepting a
      # job are not the focus of the tests.

      def accept_job_named(job_name, make_background = false)
        job = Job.named(job_name)
        job.make_background if make_background
        @session.accept_job(job)
        job
      end

      def accept_subjob_named(subjob_name, job)
        subjob = Job.named_with_parent(subjob_name, job)
        @session.accept_job(job)
        subjob
      end
        
      def test_job_acceptance
        job = Job.named('new job')
        @session.accept_job(job)
        assert_equal(1, @session.jobs.length)
        assert_equal(job, @session.jobs['new job'])

        # replace it
        replacement = Job.named('new job')
        replacement.attributes['uniquify'] = 'this version has an attribute'
        @session.accept_job(replacement)
        assert_equal(1, @session.jobs.length)
        assert_equal(replacement, @session.jobs['new job'])
        # Just to make sure
        assert(@session.jobs['new job'].attributes['uniquify'])
      end

      def test_subjob_acceptance
        job = accept_job_named('j')
        job = job.dup

        subjob = Job.named_with_parent('subjob', job)
        subjob.attributes['version']='1'
        # The job has changed on the 'client' side.
        assert_not_equal(job, @session.jobs)
        # So update it.
        @session.accept_job(subjob)
        installed_job = @session.jobs['j']
        assert_equal(job, installed_job)  # checks both job and subjob.

        # replace subjob
        job = job.dup
        job.subjobs.clear
        another_subjob = Job.named_with_parent('subjob', job)
        another_subjob.attributes['version'] = '2'
        assert_not_equal(job, @session.jobs)
        @session.accept_job(another_subjob)
        installed_job = @session.jobs['j']
        assert_equal(job, installed_job)  # checks both job and subjob

        # add a second subjob
        yet_another_subjob = Job.named_with_parent('another', job)
        @session.accept_job(subjob)
        installed_job = @session.jobs['j']
        assert_equal(job, installed_job)
      end

      def test_acceptance_of_whole_tree
        # Note the session can accept a whole subtree.
        job=Job.named('yet another job')
        subjob = Job.named_with_parent('subjob!!!', job)
        @session.accept_job(job)
        assert_equal(job, @session.jobs['yet another job'])
        # just to make sure...
        assert_equal(job.subjobs['subjob!!!'],
                     @session.jobs['yet another job'].subjobs['subjob!!!'])
      end

      def test_attribute_addition_and_change
        # above tests check installing/reinstalling a job with an
        # attribute. This checks that you can later add an attribute to a
        # job or change the attribute without changing the job.

        job=Job.named('job')
        subjob = Job.named_with_parent('subjob', job)
        @session.accept_job(job)

        # add an attribute to a job
        job = job.dup
        job.attributes['five']='5'
        # no longer equal
        assert_not_equal(job, @session.jobs)
        # So we should update it.
        @session.accept_job(job)
        assert_equal(job, @session.jobs['job'])

        # add another one
        job = job.dup
        job.attributes['time'] = '8:16 am'
        assert_not_equal(job, @session.jobs)
        @session.accept_job(job)
        assert_equal(job, @session.jobs['job'])

        # add a subjob attribute
        subjob.attributes['time'] = 'now'
        assert_not_equal(job, @session.jobs)
        @session.accept_job(subjob)
        assert_equal(job, @session.jobs['job'])    
        assert_equal(subjob, @session.jobs['job'].subjobs['subjob'])

        # change it
        subjob.attributes['time'] = 'the present'
        @session.accept_job(subjob)
        assert_equal(job, @session.jobs['job'])    
        assert_equal(subjob, @session.jobs['job'].subjobs['subjob'])
      end

      def test_background
        
        @session.accept_job(Job.named('background'))

        with_fresh_change_log {
          new_background = @session.background('background')
          assert_equal('background', new_background.full_name)
          assert_equal(:first_background, change_log.first.name)
          assert_equal(true, @session.find_job_named('background').is_background?)
        }

        with_fresh_change_log {
          @session.accept_job(Job.named('replacement'))
          new_background = @session.background('replacement')
          assert_equal('replacement', new_background.full_name)
          assert(change_log.has?(:swapped_background))
          assert_equal('background',
                       change_log[:swapped_background][:old_background].full_name)
          assert_equal(true, @session.find_job_named('replacement').is_background?)
          assert_equal(false, @session.find_job_named('background').is_background?)
        }

        with_fresh_change_log { 
          assert_whine(:no_such_job, 'hoozbit') {
            @session.background('hoozbit')
          }
          assert_equal(false, @session.jobs.has_key?('hoozbit'))
          assert_equal(true, @session.find_job_named('replacement').is_background?)
          assert_equal(false, @session.find_job_named('background').is_background?)
        }
      end

      ## Records
      # Just check that command is passed along
      def test_records
        job = accept_job_named('job')
        job_start = Time.local(2001, "feb", 13)
        @session.start(job, job_start)
        @session.stop(job, job_start + 20.minutes)

        # All records.
        assert_equal("job", @session.records[0].job.name)

        # by job name
        assert_equal("job",
                     @session.records(RecordFilter.by_job_full_name('job'))[0].job.name)
        assert_equal([], @session.records(RecordFilter.by_job_full_name('nomatch')))

        # by month to a moment - note that end moment is inclusive.
        matches = @session.records(RecordFilter.by_month_to_time(job_start))
        assert_equal(1, matches.length)


        # Does chaining work?
        matches = @session.records(RecordFilter.by_job_full_name('job'),
                                   RecordFilter.by_month_to_time(job_start))
        assert_equal(1, matches.length)

        matches = @session.records(RecordFilter.by_job_full_name('job'),
                                   RecordFilter.by_month_to_time(job_start-1))
        assert_equal(0, matches.length)

        matches = @session.records(RecordFilter.by_month_to_time(job_start),
                                   RecordFilter.by_job_full_name('nomatch'))
                                   
        assert_equal(0, matches.length)
      end
                           

      ## User handling 

      # Note that the total number of records includes the number of
      # active records.
      def assert_counts(job_count, record_count, active_record_count)
        assert_equal(job_count, @session.jobs.length)
        assert_equal(record_count, @session.records.length)
        assert_equal(active_record_count,
                     @session.active_records.length)
      end
        

      def test_forget_everything
        # everything means jobs, records, and active_records
        assert_equal(false, @session.persistent_user.exists?)

        job = accept_job_named('forget me!')
        @session.start(job, Time.now)
        @session.stop(job, Time.now)
        @session.start(job, Time.now)

        assert_counts(1, 2, 1)

        @session.save
        assert_equal(true, @session.persistent_user.exists?)

        # Restore into a new session.
        @session = Session.new(TEST_USER)
        assert_counts(1, 2, 1)

        @session.forget_everything
        assert_counts(0, 0, 0)
        assert_equal(false, @session.persistent_user.exists?)
      end

      def test_forget_with_nothing_to_forget
        assert_equal(false, @session.persistent_user.exists?)

        @session.forget_everything
        assert_counts(0, 0, 0)
        assert_equal(false, @session.persistent_user.exists?)
      end

      # The start and stop commands can accept either full_names or jobs.
      def test_job_name_pluralism
        job = accept_job_named('main_job')
        accept_subjob_named('sub', job)

        @session.start('main_job', Time.now)
        assert(@session.running?('main_job'))

        @session.start('main_job/sub', Time.now)
        assert(@session.running?('main_job/sub'))
      end

      def test_job_state_predicates
        job = accept_job_named('job')
        assert_equal(true, @session.stopped?(job))
        
        @session.start(job, Time.now)
        assert_equal(true, @session.running?(job))
        assert_equal(false, @session.paused?(job))
        assert_equal(false, @session.stopped?(job))
        @session.pause(Time.now)
        assert_equal(false, @session.running?('job'))
        assert_equal(true, @session.paused?(job))
        assert_equal(false, @session.stopped?(job))
        @session.stop('job', Time.now)
        assert_equal(false, @session.running?(job))
        assert_equal(false, @session.paused?(job))
        assert_equal(true, @session.stopped?(job))
      end

      def test_stop_returns_a_record
        accept_job_named('job')
        time = Time.local(2001, 'oct', 23, 8, 23)
        @session.start('job', time)
        rec, see_next_test = @session.stop('job', time + 1.hour)
        assert_equal(time, rec.time_started)
        assert_equal('job', rec.job.name)
        assert_equal(1.hour, rec.time_accumulated)
      end

      def test_stop_can_also_log_a_resumed_job
        accept_job_named('job')
        background = accept_job_named('background', :make_background)

        @session.start_background_job(Time.now)
        @session.start('job', Time.now)
        rec = @session.stop('job', Time.now)
        assert_equal('job', rec.job.name)
        assert_equal(true, change_log.has?(:resumed))
        assert_equal(background, change_log[:resumed][:restorable].job)
      end

      def test_pause_can_also_log_a_resumed_job
        # Ordinary case - one return value because no background job.
        accept_job_named('job')
        @session.start('job', Time.now)

        with_fresh_change_log {
          paused = @session.pause(Time.now)
          assert_equal('job', paused.name)
          assert_equal(false, change_log.has?(:resumed))
        }

        # Can't start a background job when anything else is started.
        @session.stop('job', Time.now)   

        # Now have a background job.
        background = accept_job_named('background', :make_background)
        @session.start_background_job(Time.now)

        @session.start('job', Time.now)

        with_fresh_change_log {
          paused, resumed = @session.pause(Time.now)
          assert_equal('job', paused.name)
          assert_equal(true, change_log.has?(:resumed))
          assert_equal('background', change_log[:resumed][:restorable].job.name)
        }
      end

      def test_pause_without_resumption
        # Simple case: one job running that's paused.
        job = accept_job_named('j')

        @session.start(job, Time.now)
        with_fresh_change_log { 
          @session.pause_without_resumption(Time.now)
          assert_equal(true, @session.paused?(job))
          assert_equal(1, change_log.matching(:paused).length)
          assert_equal(job, change_log.matching(:paused).first[:restorable].job)
        }

        @session.stop(job, Time.now)

        # A background job that should not be resumed.

        background = accept_job_named('background', :make_background)
        @session.start_background_job(Time.now)
        @session.start(job, Time.now)

        with_fresh_change_log { 
          @session.pause_without_resumption(Time.now)
          assert_equal(true, @session.paused?(job))
          assert_equal(true, @session.paused?(background))
          
          assert_equal(1, change_log.matching(:paused).length)
          assert_equal(job, change_log.matching(:paused).first[:restorable].job)
        }

      end
      def test_pause_without_resumption_errors
        job = accept_job_named('pauser')
        accept_subjob_named('subjob', job)

        # just for luck, try it when no job has started.
        assert_whine(:no_job_to_pause) {
          @session.pause_without_resumption(Time.now)
        }

        # ... and when a job is paused.
        @session.start('pauser', Time.now)
        @session.pause(Time.now)
        
        assert_whine(:no_job_to_pause) {
          @session.pause_without_resumption(Time.now)
        }
      end

      def test_stop_all
        # Simple case: one job running that's paused.
        job = accept_job_named('j')

        job_start_time = Time.local(2002, 10, 31)
        @session.start(job, job_start_time)
        records = @session.stop_all(job_start_time+10.minutes)
        assert_equal([FinishedRecord.new(job_start_time, 10.minutes, job)], records)

        # More than one active job, including the background job.
        job_start_time = Time.local(2002, 11, 1)
        @session.start(job, job_start_time)

        background = accept_job_named('background', :make_background)
        background_start_time = job_start_time + 20.minutes
        @session.start(background, background_start_time)

        extra_job = accept_job_named('extra!')
        extra_start_time = background_start_time + 30.minutes
        @session.start(extra_job, extra_start_time)

        stop_time = extra_start_time + 40.minutes
        records = @session.stop_all(stop_time)

        assert_equal([FinishedRecord.new(job_start_time, 20.minutes, job),
                      FinishedRecord.new(background_start_time, 30.minutes, background),
                      FinishedRecord.new(extra_start_time, 40.minutes, extra_job)],
                     records)

        # And the final, simple case, where there is no job to stop.
        records = @session.stop_all(Time.now)
        assert_equal([], records)
      end

      def test_start
        job = accept_job_named('job')

        with_fresh_change_log {
          started = @session.start('job', Time.now)
          assert_equal(job, started)
          assert_equal(true, change_log.has?(:started))
          assert_equal(job, change_log[:started][:new].job)
          assert_equal(false, change_log.has?(:paused))
        }
        
        second = accept_job_named('second')

        with_fresh_change_log {
          started = @session.start('second', Time.now)
          assert_equal(second, started)
          assert_equal(true, change_log.has?(:started))
          assert_equal(second, change_log[:started][:new].job)
          assert_equal(true, change_log.has?(:paused))
          assert_equal(job, change_log[:paused][:restorable].job)
        }

        with_fresh_change_log {
          started = @session.start('job', Time.now)
          assert_equal(job, started)
          assert_equal(true, change_log.has?(:resumed))
          assert_equal(job, change_log[:resumed][:restorable].job)
          assert_equal(true, change_log.has?(:paused))
          assert_equal(second, change_log[:paused][:restorable].job)
        }

        with_fresh_change_log {
          @session.stop('job', Time.now)
          started = @session.start('second', Time.now)
          assert_equal(second, started)
          assert_equal(true, change_log.has?(:resumed))
          assert_equal(second, change_log[:resumed][:restorable].job)
          assert_equal(false, change_log.has?(:paused))
        }
      end

      def nonexistence_test_helper(ruby_message)
        job = accept_job_named('job')
        assert_whine(:no_such_job, 'bog') {
          @session.send(ruby_message, 'bog', Time.now)
        }

        assert_whine(:no_such_subjob, 'job', 'foo') {
          @session.send(ruby_message, 'job/foo', Time.now)
        }
      end


      def test_start_errors
        nonexistence_test_helper(:start)

        job = accept_job_named('starter')
        accept_subjob_named('subjob', job)

        @session.start('starter/subjob', Time.now)

        assert_whine(:job_already_started, 'starter/subjob') {
          @session.start('starter/subjob', Time.now)
        }
      end

      def test_stop_errors
        nonexistence_test_helper(:stop)

        job = accept_job_named('stopper')
        accept_subjob_named('subjob', job)

        assert_whine(:job_already_stopped, 'stopper/subjob') {
          @session.stop('stopper/subjob', Time.now)
        }
      end

      def test_pause_errors
        job = accept_job_named('pauser')
        accept_subjob_named('subjob', job)

        # just for luck, try it when no job has started.
        assert_whine(:no_job_to_pause) {
          @session.pause(Time.now)
        }

        # ... and when a job is paused.
        @session.start('pauser', Time.now)
        @session.pause(Time.now)
        
        assert_whine(:no_job_to_pause) {
          @session.pause(Time.now)
        }
      end
        
        

      # Records are ordered by when jobs *start*, not when they end.
      def test_record_ordering
        accept_job_named('job')
        accept_job_named('another')
        current_time = Time.now
        @session.start('job', current_time)
           current_time += 10.hours
           @session.start('another', current_time)
           current_time += 1.minute
           @session.stop('another', current_time)
        current_time += 1.minute
        @session.stop('job', current_time)

        records = @session.records
        assert_equal(2, records.length)
        assert_equal('job', records[0].job.name)
        assert_equal('another', records[1].job.name)
      end

      def test_add_record
        stqe = accept_job_named('stqe')
        kaner = accept_subjob_named('kaner - usage testing', stqe)

        record_0_start_time = Time.local(2002, 2, 19)
        @session.start('stqe', record_0_start_time)
        @session.stop('stqe', record_0_start_time + 10.minutes)

        @session.start('stqe/kaner - usage testing',
                       record_0_start_time + 2.days)
        @session.stop('stqe/kaner - usage testing',
                      record_0_start_time + 2.days + 30.minutes)

        # A new record will typically be added in the middle.
        @session.add_record(FinishedRecord.new(record_0_start_time + 1.day,
                                       20.minutes, stqe))

        # But it might also be added at the end.
        @session.add_record(FinishedRecord.new(record_0_start_time + 3.days,
                                       40.minutes, kaner))

        # Check that ordering is correct.
        records = @session.records
        assert_equal(4, records.length)
        assert_equal(record_0_start_time, records[0].time_started)
        assert_equal(record_0_start_time+1.day, records[1].time_started)
        assert_equal(record_0_start_time+2.days, records[2].time_started)
        assert_equal(record_0_start_time+3.days, records[3].time_started)

        # Check other fields of new records.
        assert_equal(20.minutes, records[1].time_accumulated)
        assert_equal(stqe, records[1].job)
        
        assert_equal(40.minutes, records[3].time_accumulated)
        assert_equal(kaner, records[3].job)
      end

      def test_starting_a_job_is_adding_a_record
        Time.set(Time.local(2001, 12, 19))
        stqe = accept_job_named('stqe')

        record_0_start_time = Time.local(2001, 12, 19)
        @session.start('stqe', record_0_start_time)
        assert_equal([ActiveRecord.new(record_0_start_time, 0.seconds, stqe)],
                     @session.records)

        @session.stop('stqe', record_0_start_time + 1.minute)
        assert_equal([FinishedRecord.new(record_0_start_time, 1.minute, stqe)],
                     @session.records)
      end

      def test_forget_records
        forgettable = accept_job_named 'forgettable'
        unforgettable = accept_job_named 'unforgettable'

        first_time = Time.local(2002, "jan", 31, 8, 0)
        second_time = Time.local(2002, "feb", 1, 8, 0)
        r1 = @session.add_record(FinishedRecord.new(first_time, 1.hour, unforgettable))
        r2 = @session.add_record(FinishedRecord.new(first_time, 2.hours, forgettable))
        r3 = @session.add_record(FinishedRecord.new(second_time, 3.hours, unforgettable))
        r4 = @session.add_record(FinishedRecord.new(second_time, 4.hours, forgettable))

        # Forget the final record

        with_fresh_change_log { 
          @session.forget_records(r4)
          f = change_log[:forgot_record][:record]
          assert_equal(r4, f)
          records = @session.records
          assert_equal(3, records.length)
          assert_equal(1.hour, records[0].time_accumulated)
          assert_equal(2.hours, records[1].time_accumulated)
          assert_equal(3.hours, records[2].time_accumulated)
        }

        with_fresh_change_log { 
          # Forget the second record
          @session.forget_records(r2)
          f = change_log[:forgot_record][:record]
          assert_equal(r2, f)
          records = @session.records
          assert_equal(2, records.length)
          assert_equal(1.hour, records[0].time_accumulated)
          assert_equal(3.hours, records[1].time_accumulated)
        }
      end

      def test_forget_multiple_records
        forgettable = accept_job_named 'forgettable'
        also = accept_job_named 'also'

        mark = Time.local(2002, "jan", 31, 8, 0)
        r1 = @session.add_record(FinishedRecord.new(mark, 1.hour, forgettable))
        r2 = @session.add_record(FinishedRecord.new(mark, 2.hours, also))
        r3 = @session.add_record(FinishedRecord.new(mark, 3.hours, forgettable))

        with_fresh_change_log { 
          @session.forget_records(r1, r3)
          forgotten = change_log.matching(:forgot_record).collect { | log |
            log[:record]
          }
          assert_equal([r1, r3], forgotten)

          # Check that things really were forgotten.
          records = @session.records
          assert_equal([r2], records)
        }

      end
    end
  end
end


require 'timeclock/client/command-line/tutil.rb'

module Timeclock
  module Client
    module CommandLine

      class InterfaceRecordActionTests < InterfaceTestCase

        ## records

        def test_records
          job 'job1'
          job 'job1/subjob'
          job 'no records'

          job1_mark = Time.local(1999, "jan", 2, 3, 4)
          Time.set(job1_mark)
          
          start 'job1'
          Time.advance(1.hour)
          stop 'job1'

          job1_subjob_mark = Time.local(2000, "dec", 13, 23, 14, 23)
          Time.set(job1_subjob_mark)
          start 'job1/subjob'
          Time.advance(6.minutes)
          stop 'job1/subjob'

          # Records without args
          assert_message(record_list(1.hour+6.minutes,
                                     [job1_mark, 1.hour, 'job1'],
                                     [job1_subjob_mark, 6.minutes, 'job1/subjob']),
                         records)

          # Naming a job includes its subjobs.
          assert_message(record_list(1.hour+6.minutes,
                                     [job1_mark, 1.hour, 'job1'],
                                     [job1_subjob_mark, 6.minutes, 'job1/subjob']),
                         records('job1'))


          # Just a subjob
          assert_message(record_list(6.minutes,
                                     [job1_subjob_mark, 6.minutes, 'job1/subjob']),
                         records('job1/subjob'))

          # Entirely missing job
          assert_message(record_list(0.minutes),
                         records('no records'))
        end

        ## this_month
        ## last_month

        def test_this_month_and_last_month
          job 'job'
          job 'another'

          job_mark = Time.set(Time.local(2001, "jan", 31))
          start 'job'
          another_mark = Time.advance(1.hour)   # 1 hour on job in january.
          start 'another'
          Time.advance(2.hours)  # 2 hours on another in january.
          stop 'another'
          stop 'job'

          another_mark_2 = Time.set(Time.local(2001, "feb", 1))
          start 'another'
          Time.advance(3.hours)  # 3 hours on another in February
          stop 'another'
          job_mark_2 = Time.now
          start 'job'
          Time.advance(4.hours)  # 4 hours on job in February.
          stop 'job'

          Time.set(Time.local(2001, "feb", 28, 23, 59, 59))

          february_both = record_list(7.hours,
                                      [another_mark_2, 3.hours, 'another'],
                                      [job_mark_2, 4.hours, 'job'])
          assert_message(february_both, this_month)

          # this_month also takes name of job as argument.
          february_job = record_list(4.hours,
                                     [job_mark_2, 4.hours, 'job'])
          assert_message(february_job, this_month('job'))

          Time.advance(1.second) # Now in March.
          assert_message(february_both, last_month)
          assert_message(february_job, last_month('job'))
        end

        todo 'The fact that active jobs are mixed in with records means...'
        # shorten, forget, and friends need to change.

        def test_this_month_with_active_jobs
          job 'misc'
          background 'misc'
          job 'stqe'

          Time.set(Time.local(2002, 'oct', 3, 9))

          # Make sure starting with nothing.
          assert_message(record_list(0.hours), this_month)

          start_day_mark = Time.now
          start_day

          Time.advance(2.hours)

          assert_message(record_list(2.hours,
                                     [start_day_mark, 2.hours, 'misc', 'running']),
                         this_month)

          stqe_1_mark = Time.now
          start 'stqe'
          Time.advance 6.minutes
          stop 'stqe'  # and start background.

          # Note that active jobs are sorted into the stopped records,
          # according to start time.
          Time.advance 1.hour
          assert_message(record_list(3.hours + 6.minutes,
                                     [start_day_mark, 3.hours, 'misc', 'running'],
                                     [stqe_1_mark, 6.minutes, 'stqe']),
                         this_month)
                                     
          stqe_2_mark = Time.now
          start 'stqe'
          Time.advance 30.minutes

          assert_message(record_list(3.hours + 36.minutes,
                                     [start_day_mark, 3.hours, 'misc', 'paused'],
                                     [stqe_1_mark, 6.minutes, 'stqe'],
                                     [stqe_2_mark, 30.minutes, 'stqe', 'running']),
                         this_month)

          assert_message(record_list(36.minutes,
                                     [stqe_1_mark, 6.minutes, 'stqe'],
                                     [stqe_2_mark, 30.minutes, 'stqe', 'running']),
                         this_month('stqe'))

          assert_message(record_list(3.hours,
                                     [start_day_mark, 3.hours, 'misc', 'paused']),
                         this_month('misc'))

          stop 'stqe'
          # Use "records" for a change.
          assert_message(record_list(3.hours + 36.minutes,
                                     [start_day_mark, 3.hours, 'misc', 'running'],
                                     [stqe_1_mark, 6.minutes, 'stqe'],
                                     [stqe_2_mark, 30.minutes, 'stqe']),
                         records)

          stop_day
          assert_message(record_list(3.hours + 36.minutes,
                                     [start_day_mark, 3.hours, 'misc'],
                                     [stqe_1_mark, 6.minutes, 'stqe'],
                                     [stqe_2_mark, 30.minutes, 'stqe']),
                         records)
        end

        ## recent

        def test_recent_means_today_and_yesterday
          job 'recent'
          job 'distant'

          # Note that overlapping into the recent past does not count.
          add_record('distant', 1.hour,   '2003/1/1 11:59 pm')

          add_record('recent', 1.minute,  '2003/1/2 12:00 am')
          add_record('recent', 2.minutes, '2003/1/2 11:59 pm')
          add_record('recent', 1.hour,    '2003/1/3 12:00 am')
          add_record('recent', 2.hours,   '2003/1/3 11:59 pm')

          add_record('distant', 3.hours,  '2003/1/4 12:00 am')

          Time.set(Time.local(2003, 1, 3, 23, 59))

          assert_message(record_list(3.hours + 3.minutes,
                         [Time.local(2003, 1, 2,  0,  0), 1.minute, 'recent'],
                         [Time.local(2003, 1, 2, 23, 59), 2.minutes, 'recent'],
                         [Time.local(2003, 1, 3,  0,  0), 1.hour, 'recent'],
                         [Time.local(2003, 1, 3, 23, 59), 2.hours, 'recent']),
                         recent)

          # Does not go to the end of the day.
          Time.set(Time.local(2003, 1, 3, 23, 58))

          assert_message(record_list(1.hour + 3.minutes,
                         [Time.local(2003, 1, 2,  0,  0), 1.minute, 'recent'],
                         [Time.local(2003, 1, 2, 23, 59), 2.minutes, 'recent'],
                         [Time.local(2003, 1, 3,  0,  0), 1.hour, 'recent']),
                         recent)
        end

        ## shorten

        def test_shorten_and_lengthen
          job 'chopped'
          job 'zeroed'

          rec1_mark = Time.local("2001", "jan", 12)
          Time.set(rec1_mark)
          start 'chopped'
          Time.advance(1.hour)
          stop 'chopped'

          rec2_mark = Time.now
          start 'zeroed'
          Time.advance(30.minutes)
          stop 'zeroed'

          # The shorten command refers to a record according to the number
          # in the previous records command.
          records

          assert_equal(changed_accumulated_time(rec1_mark, 30.minutes, 'chopped'),
                       shorten(1, 30.minutes))

          # You can shorten a job twice.
          assert_equal(changed_accumulated_time(rec1_mark, 24.minutes, 'chopped'),
                         shorten(1, 6.minutes))

          # And shorten more than one.
          assert_equal(changed_accumulated_time(rec2_mark, 15.minutes, 'zeroed'),
                         shorten(2, 15.minutes))

          # Check that records display correctly.
          assert_message(record_list(39.minutes,
                                     [rec1_mark, 24.minutes, 'chopped'],
                                     [rec2_mark, 15.minutes, 'zeroed']),
                         records)
          
          # Because the record command's numbering depends on the filtering
          # it does, the number of a record may change from command to command.
          records 'zeroed' 
          assert_equal(changed_accumulated_time(rec2_mark, 0.minutes, 'zeroed'),
                       shorten(1, 15.minutes))

          # Note that line numbering does not depend on deletion of earlier
          # records. Testing interaction of shorten and forget and add.
          add_record "23-jan-01 1:00 pm", 30.minutes, 'chopped'
          rec3_mark = Time.local(2001, 1, 23, 13)
          records
          forget 1
          assert_equal(changed_accumulated_time(rec2_mark, 1.hour, 'zeroed'),
                       shorten(2, -1.hour))
          assert_equal(changed_accumulated_time(rec3_mark, 1.minute, 'chopped'),
                       shorten(3, 29.minutes))

          # Lengthening is the opposite of shortening.
          assert_equal(changed_accumulated_time(rec3_mark, 2.minutes, 'chopped'),
                       lengthen(3, 1.minute))
        end

        def test_shorten_active_record
          job 'active'

          start_mark = Time.now
          Time.set(start_mark)
          start 'active'
          Time.advance(1.hour)

          records
          
          assert_equal(changed_accumulated_time(start_mark, 30.minutes, 'active', 'running'),
                       shorten(1, 30.minutes))

          # Shows up in records
          assert_message(record_list(30.minutes,
                                     [start_mark, 30.minutes, 'active', 'running']),
                         records)

          # And that has effect after time continues to pass.
          Time.advance(30.minutes)
          assert_message(record_list(1.hour,
                                     [start_mark, 1.hour, 'active', 'running']),
                         records)

          # And after a pause
          Time.advance(30.minutes)
          pause
          assert_message(record_list(1.hour,
                                     [start_mark, 1.hour+30.minutes, 'active', 'paused']),
                         records)

          assert_equal(changed_accumulated_time(start_mark, 0.minutes, 'active', 'paused'),
                       shorten(1, 1.hour+30.minutes))

          assert_message(record_list(0.hours,
                                     [start_mark, 0.hours, 'active', 'paused']),
                       records)

          # And works after restart (using lengthen)
          start
          Time.advance(30.minutes)

          assert_equal(changed_accumulated_time(start_mark, 60.minutes, 'active', 'running'),
                         lengthen(1, 30.minutes))

          assert_message(record_list(60.minutes,
                                     [start_mark, 60.minutes, 'active', 'running']),
                         records)
        end

        def test_interaction_between_shortening_and_explicit_stop_time
          # An explicit stop time includes the effects of shortening.
          # The reasoning goes like this: 
          # 1. Someone starts a job.
          # 2. She realizes that she should have paused it, so shortens
          #    it.
          # 3. Later, she decides to finish the day, but an hour ago.
          # 4. So the total time allocated should be the shortening plus
          #    the earlier stop.
          job 'fiddle'

          start_mark = Time.local(2002, 1, 19)
          Time.set(start_mark)
          start 'fiddle'

          Time.advance 1.hour
          records
          assert_equal(changed_accumulated_time(start_mark, 30.minutes, 'fiddle', 'running'),
                       shorten(1, 30.minutes))

          Time.advance 1.hour

          assert_message(stopped_day([start_mark, 30.minutes, 'fiddle']),
                         at("1:00 a.m.") do stop_day end)

          assert_message(record_list(30.minutes,
                                     [start_mark, 30.minutes, 'fiddle']),
                         records)
        end
          

        ## add_record
        
        def test_add_record
          job 'added'
          datelike = 'i2/4'; job datelike
          datelike2 = '5/13'; job datelike2
          datelike3 = '2002/12'; job datelike3
          datelike4 = 'jan 24'; job datelike4
          datelike5 = "12 pm"; job datelike5   # needs to be 12:00 pm

          # Note that arguments can be in any order.

          assert_equal(added_record(Time.local(2001,1,23,1,23), 30.minutes, datelike),
                       add_record(datelike, 30.minutes, "2001/01/23 1:23"))

          assert_equal(added_record(Time.local(2000,12,13,14,15), 11.hours+6.minutes, 'added'),
                       add_record("2000/12/13 14:15", 'added',
                                  11.hours+6.minutes ))

          assert_equal(added_record(Time.local(2000,3,4,12,15), 0, datelike2),
                       add_record(datelike2, "2000/03/4     12:15  PM", 0.minutes))

          # Implicit year
          year = Time.now.year
          # This will break on January 1 because of date/time
          # abbreviation. Oh well.
          assert_equal(added_record(Time.local(year,1,1,12), 1.hour, datelike3),
                       add_record(1.hour, datelike3, "jan 1   12:00"))

          assert_equal(added_record(Time.local(year,1,1,13), 2.hours, datelike4),
                       add_record(2.hours, datelike4, "1/1 1:00 pm"))

          now = Time.now
          assert_equal(added_record(Time.local(now.year, now.month, now.day, 11, 13),
                                    3.hours, datelike5),
                       add_record(datelike5, "11:13 am", 3.hours))

          # Check order
          assert_equal(0.seconds, @session.records[0].time_accumulated)
          assert_equal(11.hours+6.minutes, @session.records[1].time_accumulated)
          assert_equal(30.minutes, @session.records[2].time_accumulated)
          assert_equal(1.hour, @session.records[3].time_accumulated)
          assert_equal(2.hours, @session.records[4].time_accumulated)
          assert_equal(3.hours, @session.records[5].time_accumulated)
        end

        def test_add_record_errors
          job 'j'
          assert_message("Timeclock tried to add a record.
                          But no starting time was given.",
                         add_record('j', 10.seconds))
          assert_message("Timeclock tried to add a record.
                          But no accumulated time was given.",
                         add_record('j', '10:13 am'))
          assert_message("Timeclock tried to add a record.
                          But no job was given.",
                         add_record('10:13', 10.seconds))
          assert_message("Timeclock tried to add a record.
                          But there is no job named 'h'.",
                         add_record('h', '9:03', 10.seconds))
        end

        ## forget
        
        def test_forget
          job 'j/k'

          now = Time.now
          add_record 1.hour, 'j/k', "12:13"
          rec1_mark = Time.local(now.year, now.month, now.day, 12, 13)
          add_record 2.hours, 'j', "12:14"
          rec2_mark = rec1_mark + 60.seconds

          records
          shorten 1, 30.minutes  # show that accumulated time is irrelevant
          shorten 2, 30.minutes

          assert_equal(forgot_record(rec1_mark, 30.minutes, 'j/k'),
                       forget(1))
          assert_equal(forgot_record(rec2_mark, 90.minutes, 'j'),
                       forget(2))

          # It's OK to forget a record twice.
          # Note that the error message shows the old elapsed time.
          expected = 
            "Timeclock tried to forget a record for j/k.
             But there is no such record. (Perhaps it's already been deleted.)"
          assert_message(expected, forget(1))

          # You can forget more than one record at once. (Includes error case.)
          mark = Time.local(2002, 12, 13, 1, 1)
          add_record(2.hours, 'j', "2002/12/13 01:01")
          add_record(10.minutes, 'j/k', "2002/12/13 01:01")
          records
          assert_message(lines(forgot_record(mark, 10.minutes, 'j/k'),
                               "Timeclock tried to forget a record for j/k.
                                But there is no such record. (Perhaps it's already been deleted.)",
                               forgot_record(mark, 2.hours, 'j')),
                         forget(2, 2, 1))
          assert_message(record_list(0.hours), records)
        end

        def test_forget_duplicate_records
          # This test dedicated to Elisabeth Hendrickson, who found a related bug.
          job 'esh'

          add_record 1.hour, 'esh', "2001/12/11 2:13"
          add_record 1.hour, 'esh', "2001/12/11 2:13"
          records

          mark = Time.local(2001, 12, 11, 2, 13)
          assert_equal(forgot_record(mark, 1.hour, 'esh'),
                       forget(1))

          assert_message(record_list(1.hour,
                                     [mark, 1.hour, 'esh']),
                         records)
        end

        def test_forget_record_out_of_range
          job 'one'
          mark = Time.set(Time.now)
          start 'one'
          records
          assert_message("Timeclock tried to forget record 0.
                          But no record matches 0.",
                         forget(0))
          assert_message("Timeclock tried to forget record 2.
                          But no record matches 2.",
                         forget(2))

          # Valid and invalid don't mix.
          assert_message(".Timeclock tried to forget records 0, 1, 2.
                           But these numbers do not match any records: 0, 2.",
                         forget(0, 1, 2))

          # And the record was NOT forgotten.
          assert_message(record_list(0.minutes,
                                     [mark, 0.minutes, 'one', 'running']),
                         records)
        end

        def test_forget_active_record
          job 'running'
          job 'paused'

          paused_mark = Time.now
          Time.set(paused_mark)
          start 'paused'

          start_mark = paused_mark + 1.hour
          Time.set(start_mark)
          start 'running'

          records

          Time.advance 2.hours

          assert_message("Stopped the running job 'running' and removed its record.",
                         forget(2))
          assert_message(numbered_rec(1, paused_mark, 1.hour, 'paused', 'paused'),
                         records)
          assert_match(stop_error_re('running'),
                       stop('running'))

          assert_message("Stopped the paused job 'paused' and removed its record.",
                         forget(1))
          assert_message(record_list(0.hours), records)
          assert_match(stop_error_re('paused'),
                       stop('paused'))

        end
      end
    end
  end
end

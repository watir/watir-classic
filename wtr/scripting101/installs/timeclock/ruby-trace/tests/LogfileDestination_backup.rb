require "test/unit"
require "ruby-trace/all"
require "util"
require 'ftools'


class LogfileDestination_backup < TraceTestCase

  def setup
    remove('out-backup')
    assert(Dir['out-backup*'].length == 0)
  end

  def test_backup_default
    logfile_template = "../../ruby-trace/tests/out-backup%b.txt"
    logfile = "../../ruby-trace/tests/out-backup.txt"
    backup = "../../ruby-trace/tests/out-backup.000.txt"

    one_round = proc { | message | 
      conn = file_connector(logfile_template)
      conn.error(message)
      close conn
    }

    one_round.call(mess1 = "First message: This will be overwritten eventually.")
    assert(!File.exists?(backup))
    assert_messages_in_file(logfile, [mess1])

    one_round.call(mess2 = "Second message: Initially in the main file, later in the backup.")
    assert_messages_in_file(backup, [mess1])
    assert_messages_in_file(logfile, [mess2])

    one_round.call(mess3 = "Third message: Will appear in the main file.")
    assert_messages_in_file(backup, [mess2])
    assert_messages_in_file(logfile, [mess3])
  end


  def test_backup_multiple_files
    logfile_template = "out-backup-multiple%b.txt"

    # If every logfile has the same modification time (all were
    # created in the same second), there's no way to know which
    # file is the most recent. That can't happen in real life,
    # but it can happen in a test. So we delay once per cycle of
    # four file backup file creations. We don't delay every time
    # because I want to test the logic that disambiguates between
    # files with the same mod time (as unlikely as that is in real
    # life). Note that some checks later in this function delete files.
    # Changes to the test could easily break things such that we
    # end up with a sequence of files all with the same mod time.
    # If that happens, however, there's a nice assertion that
    # describes the problem.
    # 
    # I don't know if I can stand leaving this as is.
    calls = 0

    one_round = proc { | message | 
      conn = file_connector(logfile_template,
                            Trace::LogfileDestination.new('file',
                                                          logfile_template,
                                                          'w',
                                                          Trace::LogfileDestination::Infinity,
                                                          '003'))
      conn.error(message)
      close conn
      calls += 1
      sleep 1 if calls % 3 == 1
    }

    assert_file_with_N_backups = proc { | count | 
      matches = Dir['out-backup-multiple.txt']
      assert_equal(1, matches.length)
      matches = Dir['out-backup-multiple.???.txt']
      assert_equal(count, matches.length)
    }
    assert_file_with_four_backups = proc {
      assert_file_with_N_backups.call(4)
    }
      
    one_round.call(mess1 = 'first')
    assert_file_with_N_backups.call 0
    one_round.call(mess2 = 'second')
    assert_file_with_N_backups.call 1
    one_round.call(mess3 = 'third')
    assert_file_with_N_backups.call 2
    one_round.call(mess4 = 'fourth')  
    assert_file_with_N_backups.call 3
    one_round.call(mess5 = 'fifth')

    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess1])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess2])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess3])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess4])
    assert_messages_in_file('out-backup-multiple.txt', [mess5])

    one_round.call(mess6 = 'sixth') # this will cause 'first' to be erased.
    
    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess5])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess2])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess3])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess4])
    assert_messages_in_file('out-backup-multiple.txt', [mess6])

    one_round.call(mess7 = 'seventh')  # this will cause 'second' to be erased

    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess5])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess6])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess3])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess4])
    assert_messages_in_file('out-backup-multiple.txt', [mess7])


    # Backup files are replaced even if they don't exist - that is,
    # gaps are filled in.
    File.safe_unlink('out-backup-multiple.002.txt')
    one_round.call(mess8 = 'eighth')  # this will cause third to be erased.
    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess5])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess6])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess7])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess4])
    assert_messages_in_file('out-backup-multiple.txt', [mess8])

    # Wrap around, just for fun.
    one_round.call(mess9 = 'ninth')  # cause fourth to be erased.
    one_round.call(mess10 = 'tenth') # cause fifth to be erased
    one_round.call(mess11 = 'eleventh') # cause sixth to be erased

    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess9])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess10])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess7])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess8])
    assert_messages_in_file('out-backup-multiple.txt', [mess11])

    # delete first two - doesn't affect wrapping.
    remove('out-backup-multiple.000.txt')
    remove('out-backup-multiple.001.txt')
    assert_file_with_N_backups.call 2

    one_round.call(mess12 = 'twelfth') # cause wrapping
    assert_file_with_N_backups.call 3
    assert_messages_in_file('out-backup-multiple.000.txt', [mess11])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess7])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess8])
    assert_messages_in_file('out-backup-multiple.txt', [mess12])

    one_round.call(mess13 = 'thirteenth') # cause wrapping
    assert_file_with_four_backups.call
    assert_messages_in_file('out-backup-multiple.000.txt', [mess11])
    assert_messages_in_file('out-backup-multiple.001.txt', [mess12])
    assert_messages_in_file('out-backup-multiple.002.txt', [mess7])
    assert_messages_in_file('out-backup-multiple.003.txt', [mess8])
    assert_messages_in_file('out-backup-multiple.txt', [mess13])
  end

  def test_backup_overflow
    logfile_template = 'out-backup-overflow-%t%b'

    assert_file_with_N_backups = proc { | count |
      timestamp_glob = '[0-9]'*14
      matches = Dir["out-backup-overflow-#{timestamp_glob}"]
      assert_equal(1, matches.length)
      matches = Dir["out-backup-overflow-#{timestamp_glob}.???"]
      assert_equal(count, matches.length)
    }

    dest = Trace::LogfileDestination.new('file', logfile_template,
                                         'w', 210, '999')
    dest.formatter = Trace::Formatter.new  # eliminate timestamping of messages.
    conn = file_connector(logfile_template, dest)
    conn.error(mess1 = 'first one fits in first file')
    conn.error(mess2 = 'second one fits in first file')
    conn.error(mess3 = 'first in new file')
    conn.error(mess4 = 'second in new file')
    conn.error(mess5 = 'only in third file')
    close(conn)

    assert_file_with_N_backups.call 2
    # Use NO_TIME_FORMAT because we eliminated timestamping above.
    assert_messages_in_file(Dir['out-backup-overflow-[0-9]*.000'][0],
                            [mess1, mess2], TESTFILE_NO_TIME_FORMAT)
    assert_messages_in_file(Dir['out-backup-overflow-[0-9]*.001'][0],
                            [mess3, mess4], TESTFILE_NO_TIME_FORMAT)
    assert_messages_in_file(Dir['out-backup-overflow-[0-9]*'][0],
                            [mess5], TESTFILE_NO_TIME_FORMAT)
  end

  def test_backup_bad_args
    logfile_template = 'out-backup-bad%b'
    err_mess = "The greatest backup tag argument must be in ('000'..'999')."
    assert_trace_exception(err_mess) {
      Trace::LogfileDestination.new('file', logfile_template, 'w', 1,'1000')
    }
    assert_trace_exception(err_mess) {
      Trace::LogfileDestination.new('file', logfile_template, 'w', 1,'0')
    }
    assert_trace_exception(err_mess) {
      Trace::LogfileDestination.new('file', logfile_template, 'w', 1,'01')
    }
    assert_trace_exception(err_mess) {
      Trace::LogfileDestination.new('file', logfile_template, 'w', 1,'00t')
    }

    # But these are OK:
    close(file_connector(logfile_template, 
                         Trace::LogfileDestination.new('file',
                                                       logfile_template,
                                                       'w', 1,'999')))
    close(file_connector(logfile_template,
                         Trace::LogfileDestination.new('file',
                                                       logfile_template,
                                                       'w', 1,'000')))

    close(file_connector(logfile_template,
                         Trace::LogfileDestination.new('file',
                                                       logfile_template,
                                                       'w', 1,'012')))

    # If they make the size negative or zero, well that's just their problem.

  end


end



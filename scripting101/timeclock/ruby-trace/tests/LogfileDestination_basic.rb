require "test/unit"
require "ruby-trace/all"
require "util"
require 'ftools'


class LogfileDestination_basic < TraceTestCase

  def setup
    remove('out-basic')
  end



  def test_default_name  # the unspecified filename.
    logfile='Tracelog.txt'
    # puts Dir[logfile].inspect
    File.safe_unlink(logfile)
    # apparently on Windows, you sometimes need a little pause after safe_unlink.
    while Dir[logfile]!=[]
      # spin
    end
    assert_equal([], Dir[logfile])
    conn = Trace::Connector.debugging_buffer_and_file # unspecified
    close(conn)
    assert_equal([logfile], Dir[logfile])
    File.safe_unlink(logfile)
  end

  def test_basic  # unadorned simple filenames work.
    logfile = "out-basic-unadorned"
    conn = file_connector(logfile)

    conn.error(mess1 = 'first message')
    conn.error(mess2 = 'second message')

    close(conn)

    assert_messages_in_file(logfile, [mess1, mess2])
  end

  def test_basic_no_backups  # No backups for basic filenames
    logfile = "out-basic-no-backups"

    File.open(logfile, "w") { | ios |
      ios.puts("This is not from ruby-trace.")
    }

    conn = file_connector(logfile)
    close(conn)
    assert_messages_in_file(logfile, [])
    
    matches = Dir["*" + logfile + "*"]
    assert_equal(matches, [logfile])
  end

  def test_basic_accessors
    logfile = 'out-basic-accessors'

    conn = file_connector(logfile)
    dest = conn.destination_named('file')
    assert_equal(Trace::LogfileDestination::Infinity, dest.limit)
    assert_equal(logfile, dest.filename)
  end

  def test_basic_relative_pathnames
    logfile = 'out-basic-relative-pathnames'

    conn = file_connector("../tests/" + logfile)
    conn.error(mess = 'only message')
    close conn
    
    assert_messages_in_file(logfile, [mess])
  end

  def test_basic_absolute_pathnames
    logfile = 'out-basic-absolute-pathnames'

    conn = file_connector(Dir.getwd + '/' + logfile)
    conn.error(mess1 = 'error')
    conn.error(mess2 = 'error2')
    conn.verbose('not seen')
    close(conn)
    
    assert_messages_in_file(logfile, [mess1, mess2])
  end

  def test_basic_appending

    logfile = 'out-basic-appending'
    conn = file_connector(logfile)
    conn.error(mess1 = 'the first message')
    close(conn)

    conn = Trace::Connector.new {
      add_destination(Trace::LogfileDestination.new('file', logfile, 'a'),
                      :default)
      debugging_theme
      theme_and_destination_use_default('debugging', 'file', 'event')
    }
    conn.error(mess2 = 'the second message')
    close(conn)

    assert_messages_in_file(logfile, [mess1, mess2])
  end

  def test_more_than_one
    logfile = 'out-basic-one.txt'
    logfile2 = 'out-basic-two.txt'

    conn = Trace::Connector.new {
      debugging_theme
      add_destination(Trace::LogfileDestination.new('file', logfile),
                      :default)
      theme_and_destination_use_default('debugging', 'file', 'event')

      add_destination(Trace::LogfileDestination.new('file2', logfile2),
                      :default)
      theme_and_destination_use_default('debugging', 'file2', 'error')
    }

    conn.error(error = 'appears in both')
    conn.event(event = 'appears in first')
    conn.debug(debug = 'appears in neither')
    conn.destination_named('file').close
    conn.destination_named('file2').close

    assert_messages_in_file(logfile, [error, event])
    assert_messages_in_file(logfile2, [error])
  end



  def test_basic_bad_modestring
    expected = ["Invalid mode string: 'r'.",
                "   Try one of these:",
                "   a, w"].join($/)
    assert_trace_exception(expected) {
      Trace::LogfileDestination.new('file', "mumble", 'r')
    }
  end

end


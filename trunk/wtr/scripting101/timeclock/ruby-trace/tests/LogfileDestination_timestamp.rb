require "test/unit"
require "ruby-trace/all"
require "util"
require 'ftools'


class LogfileDestination_timestamp < TraceTestCase

  def setup
    remove('out-timestamp')
  end

  def test_timestamp
    logfile = "out-timestamp.%t.txt"
    logfile_glob = 'out-timestamp.*.txt'
    logfile_regex = /out-timestamp.(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d).txt/
    before = Time.now
    conn = file_connector(logfile)
    after = Time.now
    dest = conn.destination_named('file')
    close conn
    
    matching_files = Dir[logfile_glob]
    assert(matching_files.length==1)
    matching_file = matching_files[0]

    assert(logfile_regex =~ matching_file)
    year = $1.to_i
    mon = $2.to_i
    day = $3.to_i
    hour = $4.to_i
    min = $5.to_i
    sec = $6.to_i

    assert(before.year <= year && year <= after.year)
    assert(before.mon <= mon && mon <= after.mon)
    assert(before.day <= day && day <= after.day)
    assert(before.hour <= hour && hour <= after.hour)
    assert(before.min <= min && min <= after.min)
    assert(before.sec <= sec && sec <= after.sec)

    # Check accessors.
    assert_equal(matching_file, dest.filename)
    assert_equal(Trace::LogfileDestination::Infinity,
                  dest.limit)
    assert_equal("000", dest.greatest_backup_tag)
  end

end



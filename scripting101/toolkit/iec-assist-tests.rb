# Tests show_elements method in iec-assist.rb against Timeclock server on localhost.
# Assumes Timeclock server is already running.

require 'English'
require 'toolkit'
require 'test/unit'

class Test_show_elements  < Test::Unit::TestCase
  def setup()
    start_ie("http://localhost:8080")
    $iec.wait
    @read_end, @write_end = IO.pipe
    $stdout = @write_end
  end

  # Only one form on this page; all cases in this group should show same result
  @@regexReport = Regexp.new("^\s*name:\s*name\s+value:\s*$")
  def check_report()
    @write_end.close
    @write_end = nil
    report = @read_end.gets

    assert_not_nil(report)
    assert_match(@@regexReport, report)
    assert(@read_end.eof?, "Report more than one line long")
  end

  def test_show_elements_form()
    begin
      show_elements(forms[0])
    rescue
      flunk("show_elements(forms[0]) threw exception: " + $ERROR_INFO)
    else
      check_report()
    end
  end

  def xtest_show_elements_noarg()
    begin
      show_elements()
    rescue
      flunk("show_elements() threw exception: " + $ERROR_INFO)
    else
      check_report()
    end
  end

  def teardown
    $iec.close
    if @write_end then @write_end.close end
    @read_end.close
    $stdout = STDOUT
  end
end

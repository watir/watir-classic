require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"


class Formatter < GlobalTestCase

  def assert_with_varying_fields(message_string, topic, level)
    message = Trace::Message.new(message_string, topic, level)
    message.location="file.rb:33:in `test_how_default'"
    message.time=Time.local(2001,"jan", 02, 03, 04, 05)
    s = Trace::Formatter.new.accept(message)
    expect_line1="file.rb:33:in `test_how_default'"
    expect_line2="= #{topic} #{level}: #{message_string}"
    assert_equal(expect_line1 + $/ + expect_line2, s)
  end
  
  def test_default_formatting
    assert_with_varying_fields("my message", "topic", "level")

    # The default topic has no name.
    assert_with_varying_fields("my next message", $trace.name, "level")

    # Just for grins, what happens with no message.
    assert_with_varying_fields("", "topic", "level")
  end

  def test_custom_formatting
    message = Trace::Message.new("body", "topic", "level")
    message.location="file.rb:33:in `test_how_default'"
    message.time=Time.local(2001,"jan", 02, 03, 04, 05)
    formatter = Trace::Formatter.new(Trace::Formatter::TWO_LINE_WITH_DATE,
                                     Trace::Formatter::VERBOSE_SORTABLE_TIME)
                                     
    s = formatter.accept(message)
    expect_line1="file.rb:33:in `test_how_default' at 2001/01/02 03:04:05"
    expect_line2="= topic level: body"
    assert_equal(expect_line1 + $/ + expect_line2, s)
  end

  def test_format_errors
    missing_time='If you use #{time} in a format, you must also give a time format.'
    assert_trace_exception(missing_time) {
      Trace::Formatter.new('"The time is #{time}."')
    }

    assert_trace_exception(missing_time) {
      Trace::Formatter.new('"The time is #{ time.succ}."')
    }
  end

  # This is OK:
  Trace::Formatter.new('"#{body} has no time for #{topic}"')

end



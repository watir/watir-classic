require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"

## Note: these tests create topics that go to alternate destinations
## or use alternate themes. However, they don't check that sending
## trace messages really works. For that, look to
## Connector_adding_destinations_and_themes.rb.
##
## Tests that a topic name can be "funny" (embedded spaces, etc.) are
## with the other funny name tests in
## Connector_adding_destinations_and_themes.rb.

class Topic_creation < GlobalTestCase
  def setup
    super
    $trace=two_test_destinations
  end

  def test_topics_are_singletons
    tr1 = $trace.topic("singleton")
    tr2 = $trace.topic("singleton")
    assert(tr1.equal?(tr2))
  end

  def test_bad_creation_keyword
    assert_trace_exception("trace topic creation: 'them' is an unknown keyword.") {
      $trace.topic("second", 'them'=>"usage")
    }
  end

  def test_singleton_args_differ_without_error
    some_keyword_args =
      {'theme'=>"usage", 'destinations'=>["alternate"]}

    # It's OK to have the second invocation of a singleton not have any
    # keyword arguments.
    $trace.topic("singleton", some_keyword_args)
    $trace.topic("singleton")

    # It's OK to have keyword arguments on a later call, so
    # long as they match the first.
    $trace.topic("singleton", some_keyword_args)

    # If it only has one argument, the other will default to the 
    # previously given value (NOT to the defaults used by the first
    # invocation, else the previous call would fail.
    $trace.topic("singleton", 'destinations'=>["alternate"])
    $trace.topic("singleton", 'destination'=>"alternate")
    $trace.topic("singleton", 'theme'=>'usage')

    # It's even OK to specify the default args explicitly.
    $trace.topic("second")
    $trace.topic("second", 'destinations'=>["alternate", 'buffer'],
		 'theme'=>"debugging")

    # Note the the order of destination arguments doesn't matter, nor
    # (of course) does the order of keyword arguments.
    $trace.topic("second", 'theme'=>"debugging",
		 'destinations'=>['buffer', "alternate"])
  end

  def test_keyword_mismatch
    original_keyword_args =
      {'theme'=>"usage", 'destination'=>"alternate"}

    $trace.topic("original", original_keyword_args)

    expected="Topic 'original' already has a different theme: 'usage'."
    assert_trace_exception(expected) {
      $trace.topic("original", 'theme'=>'debugging')
    }
    assert_trace_exception(expected) {
      $trace.topic("original", 'theme'=>'debugging', 'destinations'=>["alternate"])
    }

    expected=%Q{Topic 'original' already routed to ["alternate"].}
    assert_trace_exception(expected) {
      $trace.topic("original", 'destinations'=>%w{alternate buffer})
    }
    assert_trace_exception(expected) {
      $trace.topic("original", 'theme'=>'usage',
		   'destinations'=>%w{alternate buffer})
    }
  end

  def test_bad_duplicate_creation_keyword
    assert_trace_exception("trace topic creation: 'them' is an unknown keyword.") {
      $trace.topic("second", 'theme'=>"usage")
      $trace.topic("second", 'them'=>"usage")
    }
  end

  def test_destination_and_destinations
    # The destination and destinations keywords are entirely equivalent.
    one = $trace.topic("one", 'destination'=>"alternate")
    one.destination_names = ["alternate"]

    two = $trace.topic("two", 'destination'=>["alternate", 'buffer'])
    two.destination_names = ["alternate", 'buffer']

    three = $trace.topic("three", 'destinations'=>"buffer")
    three.destination_names = ["buffer"]

    four = $trace.topic("four", 'destinations'=>['buffer'])
    four.destination_names = ['buffer']
  end

end


require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"


class Message < GlobalTestCase

  # All that's not trivial is getting the location information. We test
  # this via the normal tracing mechanism. Along the way, we might as well
  # test that the date is correct.
  def test_creation
    topic_name = "a topic"
    message_string = "a string to go in the message"
    $trace.topic(topic_name).error(message_string)
    now = Time.now

    message = $trace.destination_named("buffer").messages[0]
    assert_equal(message_string, message.body)
    assert_equal("error", message.level)
    assert_equal(topic_name, message.topic)
    
    regexp = Regexp.new("Message.rb:[0-9][0-9]:in `test_creation'")
    assert(regexp===message.location)

    # puts "TIME DIFF: #{(now - message.time).to_i}"
    assert((0..4)===(now - message.time).to_i)
  end

  # Message.new can take an 'additional_frames' argument that tells
  # it to look higher in the frame for the location to use. This enables
  # wrapper functions, as tested here.
  def test_location_adjustment
    wrapper "this message appears in the trace log."
    message = $trace.destination_named("buffer").messages[0]
    assert(message.location.include?('test_location_adjustment'))
    assert(!message.location.include?('wrapper'))
  end

  def wrapper(msg)
    $trace.error(msg, 1)
  end
end


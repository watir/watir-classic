require "test/unit"
require "ruby-trace/start/global-buffer"
require "util"

class Connector_adding_destinations_and_themes < GlobalTestCase

  def setup
    super
    $trace=Trace::Connector.new {
      add_destination(Trace::BufferDestination.new('dest1'), :default)
      add_theme('theme1', %w{theme1_level1 theme1_level2}, :default)
      theme_and_destination_use_default('theme1', 'dest1', 'theme1_level1')
    }
    $tr=$trace.topic('tr')
  end

  # Empty destination and send some basic messages to both topics.
  # Returns array of messages in destination. This is mainly used to
  # check that later additions don't affect $trace and $tr.
  def check_basic
    $trace.destination_named('dest1').clear

    $trace.theme1_level1('see this')
    $trace.theme1_level2('invisible')
    expected=['see this']
    assert_messages('dest1', expected)

    $tr.theme1_level1('also see this')
    $tr.theme1_level2('also invisible')
    expected += ['also see this']
    assert_messages('dest1', expected)

    expected
  end

  def test_adding_destinations
    $trace.add_destination(Trace::BufferDestination.new('new_default'), :default)
    $trace.add_destination(Trace::BufferDestination.new('non_default'))

    # note new_default uses a different threshold than all the rest.
    $trace.theme_and_destination_use_default('theme1',
                                             'new_default', 'theme1_level2')
    $trace.theme_and_destination_use_default('theme1',
                                             'non_default', 'theme1_level1')
    

    new_default_topic = $trace.topic('new-default-topic')
    non_default_topic = $trace.topic('non-default-topic',
                                     'destinations'=>%w{non_default})

    dest1_expected = check_basic # old topics send to old destinations.
    assert_messages('new_default', []) # and not to the new ones.
    assert_messages('non_default', [])

    # A new_default level1 message goes to both dest and new_default.
    new_default_topic.theme1_level1(new_msg_1 = 'new default message')
    # ... but a level 2 message doesn't go to dest (whose default level
    # is higher).
    new_default_topic.theme1_level2(new_msg_2 = 'another new message')

    # A non-default level1 message goes to non_default, nowhere else.
    non_default_topic.theme1_level1(non_msg_1 = 'non default message')
    non_default_topic.theme1_level2('non-will-not-be-seen')
    
    assert_messages('dest1', dest1_expected + [new_msg_1])
    assert_messages('new_default', [new_msg_1, new_msg_2])
    assert_messages('non_default', [non_msg_1])

  end

  def test_adding_themes
    $trace.add_theme('second_theme', %w{second_level1 second_level2})
    $trace.theme_and_destination_use_default('second_theme', 'dest1', 'second_level1')

    new_topic = $trace.topic("new_topic", "theme"=>"second_theme")
    expected = check_basic # old topics send to old destinations.

    new_topic.second_level1(msg="second level")
    new_topic.second_level2("not seen")

    expected += [msg]
    assert_messages("dest1", expected)
  end

  # add a completely disconnected theme and destination.
  def test_adding_both
    $trace.add_theme('private', %w{p1 p2 p3})
    $trace.add_destination(Trace::BufferDestination.new('private'))
    $trace.theme_and_destination_use_default('private', 'private', 'p3')

    # Note this uses the "destination" keyword.
    new_topic = $trace.topic("private",
                             "destination"=>"private",
                             "theme"=>"private")
    dest1_messages = check_basic # old topics send to old destinations.
    assert_messages("private", []) # not new.

    new_topic.p1('p1')
    new_topic.p2('p2')
    new_topic.p3('p3')

    assert_messages("dest1", dest1_messages)
    assert_messages("private", %w{p1 p2 p3})
  end

  def test_changing_default_theme
    $trace.add_theme('new-default', %w{nd1}, :default)
    $trace.theme_and_destination_use_default('new-default', "dest1", "nd1")
    
    new_topic = $trace.topic("new_topic")
    new_topic.nd1('') # just to see if empty strings work.
    assert_messages("dest1", [''])
  end

  def test_theme_with_none_as_default_threshold
    $trace.add_theme('initially_none', %w{none1}, :default)
    $trace.theme_and_destination_use_default('initially_none', "dest1", "none")
    
    new_topic = $trace.topic("initially_none")
    new_topic.none1('this should not be seen')
    assert_messages("dest1", [])
  end

  def test_no_default_theme
    conn = Trace::Connector.new
    conn.add_theme('not_default', %w{level})
    conn.add_destination(Trace::BufferDestination.new('dest'), :default)
    conn.theme_and_destination_use_default('not_default', 'dest', 'level')
    assert_trace_exception("Because there is no default theme, you must declare it explicitly for 'topic'.") {
      conn.topic('topic')
    }
    tr = conn.topic('topic', 'theme'=>'not_default')
    tr.level('hi')
    assert_messages('dest', ['hi'], conn)
  end

  def test_no_default_destination
    conn = Trace::Connector.new
    conn.add_theme('default', %w{level}, :default)
    conn.add_destination(Trace::BufferDestination.new('not_default'))
    conn.theme_and_destination_use_default('default', 'not_default', 'level')
    assert_trace_exception("Because there is no default destination, you must declare it explicitly for 'topic'.") {
      conn.topic('topic')
    }
    tr = conn.topic('topic', 'destination'=>'not_default')
    tr.level('hi')
    assert_messages('not_default', ['hi'], conn)
  end

  def test_replace_destination
    # When you replace a destination, the methods are updated to refer to
    # the new destination.

    # We need a destination that will not be replaced. It should be
    # unaffected.
    $trace.add_destination(Trace::BufferDestination.new('unaffected'))
    $trace.theme_and_destination_use_default('theme1', 'unaffected',
                                             'theme1_level2')
    tr = $trace.topic("unaffected", 'destination' => 'unaffected')
    tr.theme1_level2(unaffected_msg = 'this will remain unaffected')
    assert_messages('unaffected', [unaffected_msg])

    # Put some stuff in the buffer before it's replaced.
    expected = check_basic
    # double check that future checks find messages there.
    assert_messages('dest1', expected)

    $trace.replace_destination(Trace::BufferDestination.new("dest1"))
    assert_messages('dest1', [])
    $trace.theme1_level1('this appears')
    assert_messages('dest1', ['this appears'])

    # The unaffected destination is still unaffected.
    assert_messages('unaffected', [unaffected_msg])
    # And messages to it still work.
    tr.theme1_level1(unaffected_msg)
    assert_messages('unaffected', [unaffected_msg, unaffected_msg])
  end

  def test_replace_nonexistent_destination
    assert_trace_exception("You can't replace 'destXXX'. It was never created.") {
      $trace.replace_destination(Trace::BufferDestination.new("destXXX"))
    }
  end

  def test_omitted_theme_destination_linkage
    # It's probably a common mistake to add a destination without assigning a 
    # default threshold
    $trace.add_theme("new_theme", %w{t1 t2})
    assert_trace_exception("Theme 'new_theme' does not have a default threshold for destination 'dest1'.") {
      $trace.topic("whatever", 'theme'=>'new_theme')
    }

    $trace.add_destination(Trace::BufferDestination.new("new_dest"))
    assert_trace_exception("Theme 'theme1' does not have a default threshold for destination 'new_dest'.") {
      $trace.topic("whatever", 'destination'=>'new_dest')
    }
  end

  def test_adding_to_empty_connection
    $trace = Trace::Connector.new
    # Doesn't contain any of the default messages. 
    assert(!$trace.methods.include?('error'))

    $trace.add_destination(Trace::BufferDestination.new('buffer'), :default)
    $trace.add_theme("theme", %w{one_level}, :default)
    $trace.theme_and_destination_use_default("theme", "buffer", "one_level")

    tr = $trace.topic("topic")
    tr.one_level("hi")
    assert_messages('buffer', ['hi'])
  end

  def test_funny_names
    funny_dest = 'Buf! !f er='
    funny_theme = 'B<>hem er='
    funny_topic = 'B<< topic-'
    funny_level = 'azAZ09_' 
    $trace.add_destination(Trace::BufferDestination.new(funny_dest))
    $trace.add_theme(funny_theme, [funny_level])
    $trace.theme_and_destination_use_default(funny_theme, funny_dest, funny_level)

    tr=$trace.topic(funny_topic, 'theme'=>funny_theme,
                    'destination'=>funny_dest)
    tr.send(funny_level, 'hi')
    assert_messages(funny_dest, ['hi'])

    # Level names, however, must be identifiers.
    expected_msg = 'Level names must match /[a-z][a-zA-Z0-9_]*/'
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', ['Constant'])
    }
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', ['\$var'])
    }
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', [' space'])
    }
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', ['space '])
    }
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', ['internal space'])
    }
    assert_trace_exception(expected_msg) {
      $trace.add_theme('theme_name', ['a='])
    }
  end

  def test_duplication
    $trace.add_destination(Trace::BufferDestination.new("d"))
    assert_trace_exception("Destination 'd' already exists.") {
      $trace.add_destination(Trace::BufferDestination.new("d"))
    }
      
    $trace.add_theme('t', %w{l})
    assert_trace_exception("Theme 't' already exists.") {
      $trace.add_theme('t', %w{l})
    }
  end

  def test_level_name_clash
    # Level names should not already be methods on class Topic.
    assert_trace_exception("'clone' cannot be a level - it's already a method of class Topic.") {
      $trace.add_theme('bogus', %w[clone])
    }
  end

end


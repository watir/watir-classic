require "test/unit"
require "ruby-trace/all"
require "util"

class Environment < TraceTestCase


  def test_topic_not_found
    e = Trace::Environment.new
    e.set 't2-b-default=e:-b2-default=e'
    assert(!e.topic_default('t', 'b2'))
  end

  # Note that the following tests also check topic_threshold and
  # topic_default, plus effect of garbage in the environment var. 
  def test_unnamed_topic   # --threshold=level, -buffer-default=level
    e = Trace::Environment.new
    e.set "  :--threshold=error; -buffer-default=warning"
    assert_equal('error', e.topic_threshold('', 'buffer'))
    assert_equal('warning', e.topic_default('', 'buffer'))
  end

  def test_topic_buffer_defaulting
    e = Trace::Environment.new
    e.set 't--default=error'
    assert_equal('error', e.topic_default('t', 'buffer'))

    # Explicit takes precedence
    e = Trace::Environment.new
    e.set 't--threshold=error:t-buffer-threshold=warning'
    assert_equal('warning', e.topic_threshold('t', 'buffer'))

    # Not just any buffer or topic will do.
    e = Trace::Environment.new
    e.set 't2-b-default=e:t-b2-default=e t--default=1'
    assert_equal('1', e.topic_default('t', 'b'))
  end

  def test_partial_matches
    e = Trace::Environment.new
    e.set 't2-b-default=e:t-b2-default=e t--default=1 topic-b2-default=e'

    # Truncated matches in topic don't work
    assert_equal(nil, e.topic_default('', 'b'))
    assert_equal(nil, e.topic_default('2', 'b'))

    # Ditto in buffer
    assert_equal(nil, e.topic_default('topic', 'b'))

    # Excess chars in topic are unmatched
    assert_equal(nil, e.topic_default('t22', 'b'))

    # ditto for buffer
    assert_equal(nil, e.topic_default('topic', 'b22'))
  end

  ## Setting of global-theme-buffer-default=value in Environment_uses.rb
end


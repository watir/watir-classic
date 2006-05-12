require 'set'
require 'test/unit'

module Borges; end
require 'Borges/Utilities/WeakIdentityKeyHash'
require 'Borges/Utilities/StateRegistry'

class ValueHolder
  attr_accessor :contents

  def initialize(contents)
    @contents = contents
  end

end

class StateRegistryTest < Test::Unit::TestCase

  def setup
    @registry = Borges::StateRegistry.new
  end

  def snapshot_identical_to(x, y)
    return Set.new(x.values) == Set.new(y.values)
  end

  def test_consecutive_snapshots
    a = ValueHolder.new(1)

    @registry.register(a)

    snap1 = @registry.snapshot
    snap2 = @registry.snapshot

    assert(snapshot_identical_to(snap1, snap2))

    a.contents = 2

    snap3 = @registry.snapshot

    assert(!snapshot_identical_to(snap3, snap2))
  end

  def test_garbage_collection
    a = ValueHolder.new(1)

    @registry.register(a)

    snap1 = @registry.snapshot

    GC.start

    assert_equal(1, @registry.size)

    a = nil

    GC.start

    assert_equal(0, @registry.size)
  end

  def test_no_change_after_restore
    a = ValueHolder.new(1)

    @registry.register(a)

    snap1 = @registry.snapshot

    a.contents = 2

    snap2 = @registry.snapshot

    assert(!snapshot_identical_to(snap1, snap2))

    @registry.restore_snapshot(snap1)

    assert_equal(1, a.contents)

    snap3 = @registry.snapshot

    assert(snapshot_identical_to(snap1, snap3))
  end

  def test_revert
    a = ValueHolder.new(1)

    @registry.register(a)

    snap1 = @registry.snapshot

    a.contents = 2

    assert_equal(2, a.contents)

    @registry.restore_snapshot(snap1)

    assert_equal(1, a.contents)
  end

  def test_revert_twice
    a = ValueHolder.new(1)

    @registry.register(a)

    snap1 = @registry.snapshot

    a.contents = 2

    assert_equal(2, a.contents)

    @registry.restore_snapshot(snap1)

    assert_equal(1, a.contents)

    a.contents = 3

    @registry.restore_snapshot(snap1)

    assert_equal(1, a.contents)
  end

end


##
# The StateRegistry is used to track, save, and restore the
# states of objects registered into it.
#
# Session uses this to restore registered objects to the state
# they were at when the user first viewed the page they are
# attached to.
#
# For example, in Borges/Component/Counter.rb, the Counter object
# is registered with the session when it is initialized.
# Every time a new page is rendered, a snapshot of the Counter's
# state is created, so that if the user goes back in their
# history, any requested actions on the Counter will operate with
# the Counter's state from the first rendering of that page.
#
# Here's a timeline to help explain things better:
#
# load /borges/counter
# - Counter initializes @count to 0 and registers self
# - Counter state snapshot taken
# - /borges/counter/session/a rendered and sent to user
#
# load /borges/counter/session/a
# - /borges/counter/session/b rendered and sent to user
# - user clicks "++"
#
# load /borges/counter/session/b
# - restore Counter snapshot from "a"
# - "++" was clicked, increment @count to 1
# - Counter state snapshot taken
# - /borges/counter/session/c rendered and sent to user
# - user realizes they made a mistake and uses the back button
# - user clicks "--"
#
# load /borges/counter/session/b
# - restore Counter snapshot from "a"
# - "--" was clicked, decrement @count to -1
# - Counter state snapshot taken
# - /borges/counter/session/d rendered and sent to user
#
# The snapshots allow an object's state to be backtracked easily.
# The snapshots created by the registry will drop unreferenced
# objects when the Session drops an old page from its cache of
# recent pages.
# 
# If the Session's history cache contains 10 pages, and the user
# performs five operations in the Counter, then moves on to
# another task and spends 10 operations there, the Counter will
# no longer be accessible in their Session history, and no longer
# restorable.

class Borges::StateRegistry

  def initialize
    #@objects = SeasidePlatformSupport.weakDictionaryOfSize(10)
    @objects = Weak::IdentityKeyHash.new
  end

  ##
  # Register an object in order to keep track of its state.

  def register(obj)
    @objects[obj] = obj.dup
  end

  ##
  # Restore the state of all objects in the registry from a
  # previously recorded snapshot.

  def restore_snapshot(snap)
    snap.each do |obj, copy|
      restore_object_from_snapshot(obj, copy)
    end
  end

  ##
  # Number of items in the registry.

  def size
    return @objects.size
  end

  ##
  # Returns a snapshot of the current state of all registered
  # objects.

  def snapshot
    #snapshot = SeasidePlatformSupport.weakDictionaryOfSize(@objects.size)
    snapshot = Weak::IdentityKeyHash.new
    
    @objects.each do |obj, copy|
      if snapshot_identical_to(copy, obj) then
        snapshot[obj] = copy
      else
        snapshot[obj] = obj.dup
      end
    end

    return snapshot
  end

  private

  ##
  # Restore an individual object's state from a copy.

  def restore_object_from_snapshot(object, copy)
    object.instance_variables.each do |var|
      object.instance_variable_set(var, copy.instance_variable_get(var))
    end

    @objects[object] = copy
  end

  ##
  # Compare two objects to see if they are identical.

  def snapshot_identical_to(copy, object)
    object.instance_variables.each do |var|
      unless copy.instance_variable_get(var).equal? object.instance_variable_get(var) then
        return false
      end
    end

    return true
  end

end


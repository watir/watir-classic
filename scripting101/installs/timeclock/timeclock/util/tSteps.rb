require 'timeclock/util/Steps'

module Timeclock
  module Steps
    def test_log_entry_equality
      assert_not_equal(ChangeLogEntry.new(:action), 'hi')

      assert_equal(ChangeLogEntry.new(:action),
                   ChangeLogEntry.new(:action))

      assert_not_equal(ChangeLogEntry.new(:action),
                       ChangeLogEntry.new(:action, :arg => 6))

      assert_not_equal(ChangeLogEntry.new(:action, :arg => 5),
                       ChangeLogEntry.new(:action, :arg => 6))

      assert_equal(ChangeLogEntry.new(:action, :arg => 5),
                   ChangeLogEntry.new(:action, :arg => 5))

      assert_not_equal(ChangeLogEntry.new(:action, :arg2 => 6),
                       ChangeLogEntry.new(:action, :arg => 6))

    end
  end
end


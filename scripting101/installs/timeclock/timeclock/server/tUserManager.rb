require 'timeclock/server/UserManager'
require 'timeclock/util/RichlyCalledWrapper'

module Timeclock
  module Server

    class UserManagerTests < Test::Unit::TestCase

      TEST_USER = "server tests"
      TEST_SECOND = "server tests second user"

      def delete_users
        UserManager.new.delete_user(TEST_USER)
        UserManager.new.delete_user(TEST_SECOND)
      end

      def setup
        delete_users
      end

      def teardown
        delete_users
      end

      def test_creation_and_destruction
        manager = UserManager.new
        first_session = manager.session_for(TEST_USER)
        assert_equal(1, manager.sessions.length)
        assert(manager.sessions.include?(first_session))

        # You get the same session if you open the user twice.
        same_session = manager.session_for(TEST_USER)
        assert_equal(first_session, same_session)
        assert_equal(1, manager.sessions.length)

        second_session = manager.session_for(TEST_SECOND)
        assert_not_equal(first_session, second_session)
        assert_equal(2, manager.sessions.length)
        assert(manager.sessions.include?(first_session))
        assert(manager.sessions.include?(second_session))

        manager.deactivate_user_session(TEST_USER)
        assert_equal(1, manager.sessions.length)
        assert(manager.sessions.include?(second_session))

        manager.deactivate_user_session(TEST_SECOND)
        assert_equal(0, manager.sessions.length)
      end

    end
  end
end

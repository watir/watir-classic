require 'timeclock/server/PersistentUser'
require 'timeclock/util/Configuration'

module Timeclock
  module Server

    class PersistentUserTests < Test::Unit::TestCase

      USERNAME="persistent user test"
      USERPATH = Configuration.user_file(USERNAME)

      def clean_files
        File.delete(USERPATH) if FileTest.exists?(USERPATH)
      end

      def setup
        clean_files
      end

      def teardown
        clean_files
      end
        

      def touch
        File.open(PersistentUser.new(USERNAME).pathname, "w") { | stream |
          stream.puts "hi"
        }
      end
      
      def test_pathname
        assert_equal(USERPATH, PersistentUser.new(USERNAME).pathname)
      end

      def test_deletion
        pu = PersistentUser.new(USERNAME)

        assert_equal(false, FileTest.exists?(pu.pathname))
        touch
        assert_equal(true, FileTest.exists?(pu.pathname))

        pu.delete
        assert_equal(false, FileTest.exists?(pu.pathname))

        # deleting a nonexistent file is a no-op
        pu.delete
        assert_equal(false, FileTest.exists?(pu.pathname))
      end

       def test_save_and_load
        pu = PersistentUser.new(USERNAME)
        assert_equal(false, pu.exists?)

        pu.save("hello", 1, [1, 2, 3])
        assert_equal(true, pu.exists?)

        string, int, array, nothing_more = pu.load
        assert_equal("hello", string)
        assert_equal(1, int)
        assert_equal([1, 2, 3], array)
        assert_equal(nil, nothing_more)
      end
    end
  end
end

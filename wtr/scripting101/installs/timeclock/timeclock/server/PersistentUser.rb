require 'timeclock/util/Configuration'

module Timeclock
  module Server

    class PersistentUser

      def initialize(user)
        @user = user
      end

      def pathname
        Configuration.ensure_data_dir
        Configuration.user_file(@user)
      end

      def delete
        File.delete(pathname) if FileTest.exists?(pathname)
      end

      def exists?
        FileTest.exists?(pathname)
      end

      def save(*args)
        File.open(pathname, "w") { | f |
          Marshal.dump(args, f)
        }
      end

      def load
        File.open(pathname, "r") { | f |
          Marshal.load(f)
        }
      end
    end
  end
end


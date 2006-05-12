require 'timeclock/util/RichlyCalledWrapper'
require 'timeclock/util/misc'

### UserManagers pass out sessions to their clients. They are the "root"
### of the object graph concerned with persistence.

module Timeclock
  module Server

    class UserManager

      ## Sessions are passed by reference within a
      ## RichlyCalledWrapper. As far as I can tell, nothing in DRB
      ## protects those from the garbage collector. For that reason,
      ## we hang onto the RichlyCalledWrapper that holds the Session,
      ## rather than the session itself.
      ## (This is really relevant only to an IndependentUserManager.)

      def initialize
        @session_hash = {}
        $trace.announce "#{self.class} created."
      end

      todo 'Would it be clearer to return the wrapped sessions?'
      def sessions
        @session_hash.values
      end

      def users
        @session_hash.keys
      end

      def session_for(user)
        @session_hash[user] ||= RichlyCalledWrapper.new(Session.new(user))
      end

      def deactivate_user_session(user)
        session_wrapper = @session_hash.delete(user)
        session_wrapper.wrapped.save
      end

      def deactivate_all_sessions
        @session_hash.each_key { | user | deactivate_user_session(user) }
      end

      def delete_user(user)
        $trace.announce "Ensuring that #{user} does not exist."
        PersistentUser.new(user).delete
      end

    end


    class NetworkableUserManager < UserManager
      def advertise(host, port)
        serve_at = "druby://#{host}:#{port}"
        $trace.announce "Serving at #{serve_at}"
        DRb.start_service(serve_at, self)
      end

      # Connect to the networked user manager supposedly at (host,port)
      def self.connect_to(host, port)
        DRb.start_service
        listen_at = "druby://#{host}:#{port}"
        $trace.announce "Finding user manager at #{listen_at}"
        DRbObject.new(nil, listen_at)
      end
        
    end

    # Runs in its own process, so must be networkable.
    class IndependentUserManager < NetworkableUserManager

      def exit
        $trace.announce "Server exiting."
        deactivate_all_sessions
        Kernel.exit(0)
      end

      def ping
        Process.pid
      end
    end

  end
end

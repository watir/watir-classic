require 'timeclock/util/misc'
require 'timeclock/util/RichlyCallingWrapper'

# Start up and shutdown a separate UserManager server. Used so that we
# can crash the server and check that checkpointing works right.

class ServerManager
  @@server = nil

  def self.connect
    unless @@server
      launch_server
      connect_without_launching(ENV['VW_TIMECLOCK_HOST'],
                                ENV['VW_TIMECLOCK_PORT'])
      await_server
    end
    nil
  end

  def self.launch_server
    Thread.new {
      $trace.announce "Starting server."
      `cd ../launchers; ruby -I../ server.rb > /dev/null 2>&1`
    }
  end

  def self.connect_without_launching(host, port)
    DRb.start_service
    listen_at = "druby://#{host}:#{port}"
    $trace.announce "Listening at #{listen_at}"
    @@server = DRbObject.new(nil, listen_at)
  end

  def self.await_server
    sleep_time = 0.1
    loop {
      begin
        @@server_pid = @@server.ping
        $trace.announce 'Server is started.'
        break
      rescue
        $trace.announce 'Server not started yet...'
        sleep sleep_time   # must not be started yet.
        sleep_time *= 2
      end
    }
  end

  def self.delete_user(user)
    @@server.delete_user(user)
  end

  def self.session_for(user)
    Timeclock::RichlyCallingWrapper.new(@@server.session_for(user))
  end

  def self.deactivate_user_session(user)
    @@server.deactivate_user_session(user)
  end

  def self.stop_server
    $trace.announce 'Stopping server.'
    begin
      @@server.exit
    rescue
      # It's not unexpected to get exceptions back because the
      # server exits before composing and sending a reply. It is possible
      # to get it to compose and send the reply back before exiting, with
      # some hackery, but that just results in a different exception.
    end
    @@server = nil
  end

  def self.kill(sig)
    Process.kill(sig, @@server_pid)
    @@server = nil
    @@server_pid = nil
  end

end


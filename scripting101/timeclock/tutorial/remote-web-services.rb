$:[0,0]='..'
require 'timeclock/util/misc'
require 'timeclock/marshalled/include-all'
require 'timeclock/server/UserManager'
require 'timeclock/util/Configuration'
require 'timeclock/util/RichlyCallingWrapper'

# On Windows, you'll need something like this:
# ENV["VW_TIMECLOCK_DATA_DIR"] = "C:/My Documents/Timeclock"
# The following line will fail if it's not set.
Timeclock::Configuration.ensure_data_dir
Timeclock::Configuration.start_log("command-line.txt")

$web_services_host = "192.168.0.172"

def pick_host(host)
  $web_services_host = host
end

def start_session_for(user)
  port = 21961
  user_manager = Timeclock::Server::NetworkableUserManager.connect_to($web_services_host, port)
  user_manager.delete_user(user) # New user each time.
  Timeclock::RichlyCallingWrapper.new(user_manager.session_for(user))
end


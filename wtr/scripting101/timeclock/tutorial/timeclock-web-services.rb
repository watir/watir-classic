
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


def start_session
  user = "web-services-default-user"
  user_manager = Timeclock::Server::UserManager.new
  user_manager.delete_user(user)  # New user each time.
  Timeclock::RichlyCallingWrapper.new(user_manager.session_for(user))
end




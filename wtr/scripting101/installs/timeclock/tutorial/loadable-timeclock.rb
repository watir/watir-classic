
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

# For laughs, we make this network-accessible (that is, a timeclock server). 
ENV["VW_TIMECLOCK_HOST"] ||= "localhost"; host = ENV["VW_TIMECLOCK_HOST"]
ENV["VW_TIMECLOCK_PORT"] ||= "21961"; port = ENV["VW_TIMECLOCK_PORT"]

user_manager = Timeclock::Server::UserManager.new

require 'timeclock/client/command-line/Interface'
include Timeclock::Client::CommandLine::Interface


if ARGV[0]
  user = ARGV[0]
  ARGV[0,1]=[]
else
  user = "loadable-timeclock-default-user"
end

user_manager.delete_user(user)  # New user each time.

session = Timeclock::RichlyCallingWrapper.new(user_manager.session_for(user))
Timeclock::Client::CommandLine::Interface.attach_to_session(session)




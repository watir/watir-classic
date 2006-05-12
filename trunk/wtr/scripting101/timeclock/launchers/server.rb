$:.unshift '..', '../fluid', '../ruby-trace'
require 'timeclock/server/UserManager'
require 'timeclock/util/Configuration'
require 'drb'


# On Windows, you'll need something like this:
# ENV["VW_TIMECLOCK_DATA_DIR"] = "/temp/timeclockdatadir"
# The following line will fail if it's not set.
Timeclock::Configuration.ensure_data_dir
Timeclock::Configuration.start_log('server.txt')


host = ENV["VW_TIMECLOCK_HOST"]
port = ENV["VW_TIMECLOCK_PORT"]

manager = Timeclock::Server::IndependentUserManager.new
manager.advertise(host, port)
DRb.thread.join
Kernel.exit 0

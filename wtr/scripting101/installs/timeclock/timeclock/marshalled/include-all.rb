# Require and include all marshalled classes

require 'timeclock/marshalled/Job'
require 'timeclock/marshalled/JobHash'
require 'timeclock/marshalled/FinishedRecord'
require 'timeclock/marshalled/ActiveRecord'
require 'timeclock/marshalled/RecordList'
require 'timeclock/marshalled/TimeclockError'
require 'timeclock/marshalled/RichResult'
require 'timeclock/marshalled/Command'
require 'timeclock/marshalled/RecordFilter'

include Timeclock::Marshalled

# This file contains utilities used by all source, be they tests or
# product code.

require 'timeclock/util/patches'

# Put "todo" notes in code or tests.
require 'ruby-trace/util/todo'
include Todo

require 'ruby-trace/all'
require 'drb'

require 'timeclock/util/ruby-extensions'
require 'timeclock/util/program-error'

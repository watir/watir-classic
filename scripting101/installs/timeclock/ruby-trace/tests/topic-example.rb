# This shows the creation and use of a topic.
#
# Usage: 'ruby topic-example.rb'
#
# This will set the environment as described in the Server Programs part
# of the user's guide. If you want to do it yourself, do the following,
# which assumes the bash shell.
# 
# (export TRACEENV="accounting-file-threshold=verbose global-debugging-file-default=warning"; ruby topic-example.rb)
#

require 'ruby-trace/all'

$trace = Trace::Connector.debugging_buffer_and_file
accounting_trace = $trace.topic('accounting')

# Set the thresholds appropriately if the TRACEENV wasn't set.
unless ENV['TRACEENV']
  accounting_trace.set_threshold('file', 'verbose')
  $trace.theme_and_destination_use_default('debugging', 'file', 'warning')
end

event = 'explode'
state = 'crashed'

# Error messages are seen by default.
accounting_trace.error "Impossible event #{event} in state #{state}."
accounting_trace.error "(Error-level messages are normally seen.)"


# Verbose messages are not. This one will be, though, because we
# changed the level. 
accounting_trace.verbose_value { "state" }
accounting_trace.verbose "(Verbose-level messages normally are not.)"

$trace.announce 'This will not be seen because the global level has been raised.'
$trace.warning 'Hide! The auditors are coming.'
$trace.warning '(The global threshold still allows warning messages.)'

puts "The log file is in Tracelog.txt."


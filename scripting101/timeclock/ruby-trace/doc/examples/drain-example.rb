# Ruby-trace can maintain both an in-memory buffer and an on-disk log. 
# Here's an example of setting these up and arranging for the buffer
# to be drained to the log on error.
#
# To see normal operation, do this: 'ruby drain-example.rb hi'
# To see error handling, do this: 'ruby drain-example.rb'

require 'ruby-trace/all'

$trace = Trace::Connector.debugging_buffer_and_file

begin
  $trace.announce 'Messages at the "announce" level appear in both destinations.'
  $trace.event 'Messages at the "event" level appear in only the buffer.'
  $trace.debug 'Messages at the "debug" level appear (by default) in neither destination.'
  puts "argument is #{ARGV[0].upcase}"  # This will raise an exception.
rescue Exception 
  $trace.drain('buffer', 'file')
  puts "Trace log is in Tracelog.txt."
  raise  # let the exception propagate. 
end


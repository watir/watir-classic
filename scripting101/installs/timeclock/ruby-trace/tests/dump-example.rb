# Ruby-trace can maintain a buffer of trace messages. Here's an example
# of setting it up and dumping it when an error happens. It goes directly
# an IO object. It doesn't use ruby-trace logfiles. In this case, we're
# using standard output.
#
# Usage:
#       ruby dump-example.rb
# If you want more detail in the dump, you can use this:
#       ruby-trace -t verbose dump-example.rb


require 'ruby-trace/start/global-buffer'


begin
  $trace.event "This normally appears in the ring buffer."
  $trace.verbose "This normally does not."
  nil.upcase # This will fail.
rescue Exception 
  puts "Exception caught: #{$!.message}"
  puts "=====Trace dump begins========="
  $trace.destination_named("buffer").to_IO($>)
  puts "=====Trace dump ends==========="
end


# This is an example of using tracing with a normal script. If the script
# works fine, you want no debugging output. That's what happens by default.
# But then suppose there's a mysterious failure. Then you can use ruby-trace
# to get trace messages. Try this:
#
#       ruby print-example.rb -r hi
#               prints its arguments.
#       ruby-trace print-example.rb -r hi
#               Announces each instance created.
#       ruby-trace -t verbose print-example.rb -r hi
#               Provides more detail
#       ruby-trace -i announce print-example.rb -r hi
#               Provides a trace of ruby-trace internals.

require 'ruby-trace/start/global'

class Example

  def initialize (tag)
    @tag = tag
    $trace.announce "New instance of #{self.class}: '#{self.inspect}'"
  end

  def do_something_detailed
    $trace.verbose 'something detailed has happened'
  end

  def inspect
    "#{self.class} #{@tag}"
  end

end

if __FILE__ == $0
  one = Example.new 'one'
  two = Example.new 'two'
  one.do_something_detailed
  puts "called with '#{ARGV.join(' ')}'"
end


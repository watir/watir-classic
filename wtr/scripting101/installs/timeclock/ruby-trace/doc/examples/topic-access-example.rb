# This shows several ways of making a topic readily accessible to
# code that uses it.
#
# Usage: 'ruby topic-access-example.rb'
# Results in Tracelog.txt

require 'ruby-trace/all'

$trace = Trace::Connector.debugging_buffer_and_file

# When a subsystem has its own module, module constants are convenient.
module ModuleSubsystem
  Trace=$trace.topic('using module constant')

  def ModuleSubsystem.example
    Trace.announce "here's an example of using a module constant."
  end
end

# Class variables also work because all calls to Connector#topic with
# the same argument return the same object. Typing the "@@" all the time
# is kind of annoying, though.
class OneClassInSubsystem
  @@trace = $trace.topic('using class variables')

  def initialize
    @@trace.announce "here's an example of using class variables."
  end
end

class AnotherClassInSubsystem
  @@trace = $trace.topic('using class variables')

  def initialize
    @@trace.announce "topics are singletons."
  end
end


# My favorite method is to add a method to the Connector that
# returns the topic. Note that, unlike the above, the topic name
# can't contain blanks.
def installing_on_connector_example
  topic = $trace.topic('installing_on_connector')
  $trace.add_method_for_topic(topic.name)
  $trace.installing_on_connector.announce('Topics can be installed on the connector.')
end


ModuleSubsystem.example
OneClassInSubsystem.new
AnotherClassInSubsystem.new
installing_on_connector_example
puts 'Output is in Tracelog.txt'


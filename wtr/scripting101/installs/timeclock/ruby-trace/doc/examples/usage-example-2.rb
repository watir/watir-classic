# Create a 'usage' theme and route usage messages to a usage log file.
#
# Usage: 'ruby usage-example-1.rb'
# The normal log remains Tracelog.txt. The usage log is Usagelog.txt.

require 'ruby-trace/all'


class ComplicatedUserInterfaceThing
  def initialize
    $trace.announce "User interface starts."
  end

  def task_completes
    $trace.usage.task 'User has turned off all helpful suggestions.'
  end
end

$trace = Trace::Connector.debugging_buffer_and_file {
  add_theme('usage', %w{task feature gesture})
  add_destination(Trace::LogfileDestination.new('usage_file', 'Usagelog.txt'))
  theme_and_destination_use_default('usage', 'usage_file', 'task')
}

topic = $trace.topic('usage', 'theme'=>'usage', 'destination'=>'usage_file')
$trace.add_method_for_topic(topic.name)
  
ComplicatedUserInterfaceThing.new.task_completes
puts 'The regular log is in Tracelog.txt.'
puts 'The usage log is in Usagelog.txt.'


# Create a 'usage' theme and route usage messages to both the
# debugging buffer and log file.
#
# Usage: 'ruby usage-example-1.rb'

require 'ruby-trace/all'


class ComplicatedUserInterfaceThing
  def initialize
    # This is a debugging message to the default (anonymous) topic.
    $trace.announce "User interface starts."
  end

  def task_completes
    # This is a usage-tracking message, which we pretend is issued
    # when the code detects some task has been completed.
    $trace.usage.task 'User has turned off all helpful suggestions.'
  end
end

# Create a standard buffer-and-file connector, but add a Usage theme.
$trace = Trace::Connector.debugging_buffer_and_file {
  add_theme('usage', %w{task feature gesture})
  theme_and_destination_use_default('usage', 'buffer', 'gesture')
  theme_and_destination_use_default('usage', 'file', 'task')
}

topic = $trace.topic('usage', 'theme'=>'usage')
$trace.add_method_for_topic(topic.name)
  
ComplicatedUserInterfaceThing.new.task_completes

puts 'Log in Tracelog.txt.'

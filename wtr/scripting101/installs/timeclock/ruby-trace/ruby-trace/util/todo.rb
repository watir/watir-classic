# Typical use:
#    require 'ruby-trace/util/todo'
#    include Todo  # do this at the top level
#    ...
#    todo 'Remember to do such-and-so'
#
# If you don't want to include Todo, you can make a note like this:
#
#    Todo.todo 'Remember to do such-and-so'
#
# The todo messages are normally ignored. However, if you invoke
#    Todo.enable_printing
# further messages will be printed to standard output. An easy way to 
# do that is using the script 'todo' instead of 'ruby':
#    % todo myprog.rb
# 
# See the examples "todo-example*.rb" in the doc/examples directory.
#
# Typically, you wouldn't put the notes inside of methods. By putting them
# outside methods, they're emitted once, at load time. (You include Todo at
# the top level to make the 'todo' method available everywhere.)

require 'ruby-trace/all'

module Todo
  Connector = Trace::Connector.new {
    dest = Trace::PrintingDestination.new('todo-dest')
    dest.formatter=Trace::Formatter.new('"TODO: #{body} (#{location})"')
    add_destination(dest, :default)
    
    add_theme('todo-theme', %w{todo}, :default)
    theme_and_destination_use_default('todo-theme', 'todo-dest', 'none')
  }

  def todo(msg='finish this')
    # The '1' tells the message creation code to look one level higher up
    # the stack for the location of the caller.
    Connector.todo(msg, 1)
  end

  module_function :todo

  # Deprecated - from version 1.2.
  def Todo.note(msg)
    Connector.todo(msg, 1)
  end

  def Todo.enable_printing
    Connector.theme_and_destination_use_default('todo-theme',
                                                'todo-dest',
                                                'todo')
  end

end

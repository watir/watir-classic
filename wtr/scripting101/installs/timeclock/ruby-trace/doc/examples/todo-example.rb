# It's not unusual to make notes to yourself as comments in a program. 
# Those notes are easy to overlook later. Here's a way of making them more
# visible:
#     require 'ruby-trace/util/todo'
#     include Todo             # Do this at the top level
#     todo "Fix this someday"  # Put this anywhere.
# 
# Normally, the notes have no effect. To see them have no effect, 
# run this program like this:
#       ruby todo-example.rb
# To see the notes, run it like this:
#       todo todo-example.rb
# In addition to the normal output, you'll get notes, together with
# filename and line number. 
#
# Typically, you wouldn't put the notes inside of methods. By putting them
# outside methods, they're made once, at load time. 
#
# See also todo-example-2.rb

require 'ruby-trace/util/todo'
include Todo

class Misnamed
  todo "Rename class Misnamed."

  include Math

  todo "Change square_root to handle negative args."
  def square_root(arg)
    todo 'This todo call happens every time the method is called.'
    sqrt(arg)
  end
end
    
    
if __FILE__ == $0
  puts "The square root of 2 is #{Misnamed.new.square_root(2)}."
end

# This example shows how you use Todo if you don't want to include Todo at
# the top level. 
# 
# Run as before to see the notes:
#       todo todo-example.rb

require 'ruby-trace/util/todo'

class Misnamed
  Todo.todo "Rename class Misnamed."

  include Math

  Todo.todo "Change square_root to handle negative args."
  def square_root(arg)
    Todo.todo 'This todo call happens every time the method is called.'
    sqrt(arg)
  end
end
    
    
if __FILE__ == $0
  puts "The square root of 2 is #{Misnamed.new.square_root(2)}."
end

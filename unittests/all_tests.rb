$:.unshift '..'
Dir["*_test.rb"].each {|x| require x}

# don't require a server
require 'iostring-tests.rb' # tests iostring.rb
require 'test-tables.rb'    # tests table-array.rb

# does require a server to be running
require 'test-show_elements.rb' # tests iec-assist.rb

# does not require server, but can be slow
# ... is currently broken!
#require 't-interface.rb' # also tests iec-assist.rb
# don't require a server
require 'iostring-tests.rb' 
require 'table-array-tests.rb'   

# does require a server to be running
require 'iec-assist-tests.rb' # tests show_elements()

# does not require server, but can be slow
# ... is currently broken!
#require 't-interface.rb' # tests form() in iec-assist.rb
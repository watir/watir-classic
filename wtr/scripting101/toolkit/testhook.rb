require 'drb'
require 'toolkit/config'

# Delete any user data for the specified user. Does not presume that this 
# user already exists. This method accesses the Timeclock server using a 
# special backdoor that was created for this test method. The backdoor runs
# on ports 9001 and 9002.
# * user - the name of the user who's records will be deleted (if they exist)
def ensure_no_user_data(user)
  DRb.start_service()
  request_handler = DRbObject.new(nil, "druby://#{$default_host}:9002")
  user_manager =    DRbObject.new(nil, "druby://#{$default_host}:9001")
  
  request_handler.ensure_no_session_for(user)
  user_manager.delete_user(user)
end

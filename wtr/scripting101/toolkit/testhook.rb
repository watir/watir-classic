require 'drb'
require 'toolkit/config'

def ensure_no_user_data(user)
  DRb.start_service()
  request_handler = DRbObject.new(nil, "druby://#{$default_host}:9000")
  user_manager =    DRbObject.new(nil, "druby://#{$default_host}:9001")
  
  request_handler.ensure_no_session_for(user)
  user_manager.delete_user(user)
end

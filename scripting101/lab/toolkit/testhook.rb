require 'drb'
def ensure_no_user_data(user)
  DRb.start_service()
  request_handler = DRbObject.new(nil, 'druby://localhost:9000')
  user_manager =    DRbObject.new(nil, 'druby://localhost:9001')
  
  request_handler.ensure_no_session_for(user)
  user_manager.delete_user(user)
end

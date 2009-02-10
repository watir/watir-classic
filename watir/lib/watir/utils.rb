# watir/utils.rb

module Watir
  module Utils
      
    # Eval the provided block. If a WIN32OLERuntimeError is raised by the block,
    # return false.
    def suppress_ole_error
      begin
        yield
        true
      rescue WIN32OLERuntimeError
        false
      end
    end
    
  end
end
  
  
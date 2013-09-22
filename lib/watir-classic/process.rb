module Watir
  # @private
  module Process
    
    # Returns the number of windows processes running with the specified name.
    def self.count(name)
      mgmt = WIN32OLE.connect('winmgmts:\\\\.')
      processes = mgmt.InstancesOf('win32_process')
      processes.extend Enumerable
      processes.select{|x| x.name == name}.length
    end
    
  end
  
  class Browser
    # Returns the number of IEXPLORE processes currently running.
    # @return [Fixnum] number of ie processes.
    def self.process_count
      Watir::Process.count 'iexplore.exe'
    end    
  end
end

module Watir
  module Process
    
    # Returns the number of windows processes running with the specified name.
    def self.count name
      mgmt = WIN32OLE.connect('winmgmts:\\\\.')
      processes = mgmt.InstancesOf('win32_process')
      processes.extend Enumerable
      processes.select{|x| x.name == name}.length
    end
    
  end
  
  class IE
    # Returns the number of IEXPLORE processes currently running.
    def self.process_count
      Watir::Process.count 'iexplore.exe'
    end    
  end
end
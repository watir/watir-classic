module Watir
  module Process

  # Returns the number of windows processes running with the specified name.
  def count_processes name
    mgmt = WIN32OLE.connect('winmgmts:\\\\.')
    processes = mgmt.InstancesOf('win32_process')
    processes.extend Enumerable
    processes.select{|x| x.name == name}.length
  end
  
end; end
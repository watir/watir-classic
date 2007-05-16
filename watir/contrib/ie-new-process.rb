# based on http://svn.instiki.org/instiki/trunk/test/watir/e2e.rb
# and http://rubyforge.org/pipermail/wtr-general/2005-November/004108.html

require 'watir'

class IEProcess
  def self.start
    startup_info = [68].pack('lx64')
    process_info = [0, 0, 0, 0].pack('llll')
    
    # TODO: make this portable
    startup_command = 'C:\Program Files\Internet Explorer\IEXPLORE.EXE'
    
    result = Win32API.new('kernel32.dll', 'CreateProcess', 'pplllllppp', 'l').
      call(
           nil, 
           startup_command, 
           0, 0, 1, 0, 0, '.', startup_info, process_info)
    
    # TODO print the error code, or better yet a text message
    raise "Failed to start IEXPLORE." if result == 0
    
    process_id = process_info.unpack('llll')[2]
    self.new process_id
  end
  
  def initialize process_id
    @process_id = process_id
  end
  attr_reader :process_id
    
  def stop
    right_to_terminate_process = 1
    handle = Win32API.new('kernel32.dll', 'OpenProcess', 'lil', 'l').
      call(right_to_terminate_process, 0, @process_id)
    Win32API.new('kernel32.dll', 'TerminateProcess', 'll', 'l').call(handle, 0)
  end
  
  def window
    shell = WIN32OLE.new 'Shell.Application'
    while true do
      shell.windows.each do |window|
        methods = window.ole_get_methods.extend Enumerable
        next if methods.select{|m| m.name == 'HWND'}.empty?
        process_id = Watir.process_id_from_hwnd window.hwnd        

        # puts "Window Name: #{window.name}, Process ID: #{process_id}"
        return window if process_id == @process_id
        
      end
    end
  end
  
end

module Watir
  def self.process_id_from_hwnd hwnd
        pid_info = ' ' * 32
        Win32API.new("user32", "GetWindowThreadProcessId", 'ip', 'i').
          call(hwnd, pid_info)
        process_id =  pid_info.unpack("L")[0]
  end

  def IE.new_process
    iep = IEProcess.start
    ie = IE.bind iep.window
    ie.process_id = iep.process_id
    ie
  end
  
  class IE
    def process_id
      @process_id ||= Watir.process_id_from_hwnd @ie.hwnd
    end
    attr_writer :process_id
    def kill
      iep = IEProcess.new process_id
      iep.stop
    end
  end
end

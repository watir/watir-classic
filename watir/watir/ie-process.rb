require 'win32/process'

module Watir
  class IE
    class Process
      def self.start
        # TODO: make this portable
        startup_command = 'C:\Program Files\Internet Explorer\IEXPLORE.EXE'
        process_info = ::Process.create('app_name' => startup_command)
        process_id = process_info.process_id
        new process_id
      end
      
      def initialize process_id
        @process_id = process_id
      end
      attr_reader :process_id
      
      def window
        shell = WIN32OLE.new 'Shell.Application'
        while true do # repeat search until our window appears
          shell.windows.each do |window|
            methods = window.ole_get_methods.extend Enumerable
            next if methods.select{|m| m.name == 'HWND'}.empty?
            process_id = IEProcess.process_id_from_hwnd window.hwnd        
            
            return window if process_id == @process_id
            
          end
        end
      end
      
      # Returns the process id for the specifed hWnd.
      def self.process_id_from_hwnd hwnd
        pid_info = ' ' * 32
        Win32API.new('user32', 'GetWindowThreadProcessId', 'ip', 'i').
        call(hwnd, pid_info)
        process_id =  pid_info.unpack("L")[0]
      end
      
    end
  end
end
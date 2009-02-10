require 'win32/process'

module Watir
  class IE
    class Process
      def self.start
        program_files = ENV['ProgramFiles'] || "c:\\Program Files"
        startup_command = "#{program_files}\\Internet Explorer\\iexplore.exe"
        process_info = ::Process.create('app_name' => "#{startup_command} about:blank")
        process_id = process_info.process_id
        new process_id
      end
      
      def initialize process_id
        @process_id = process_id
      end
      attr_reader :process_id
      
      def window
        Waiter.wait_until do
          IE.each do | ie |
            window = ie.ie
            hwnd = ie.hwnd
            process_id = Process.process_id_from_hwnd hwnd        
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
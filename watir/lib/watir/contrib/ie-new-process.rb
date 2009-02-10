# based on http://svn.instiki.org/instiki/trunk/test/watir/e2e.rb
# and http://rubyforge.org/pipermail/wtr-general/2005-November/004108.html

require 'watir/ie-process'

class IEProcess < Watir::IE::Process 
  def stop
    right_to_terminate_process = 1
    handle = Win32API.new('kernel32.dll', 'OpenProcess', 'lil', 'l').
    call(right_to_terminate_process, 0, @process_id)
    Win32API.new('kernel32.dll', 'TerminateProcess', 'll', 'l').call(handle, 0)
  end
  
end

module Watir
  class IE
    def process_id
      @process_id ||= IEProcess.process_id_from_hwnd @ie.hwnd
    end
    attr_writer :process_id
    def kill
      iep = IEProcess.new process_id
      iep.stop
    end
  end
end

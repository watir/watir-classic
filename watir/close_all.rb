require 'watir'

module Watir
  class IE
    def self.close_all
      shell = WIN32OLE.new 'Shell.Application'
      shell.windows.each do |window|
        next unless window.path =~ /Internet Explorer/ 
        IE.bind(window).close    
      end
      sleep 1.0 # replace with polling for window count to be zero?
    end
  end
end
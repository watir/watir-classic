module Watir
  class IE
    # Yields successively to each IE window on the current desktop. Takes a block.
    def self.each
      shell = WIN32OLE.new('Shell.Application')
      shell.Windows.each do |window|
        next unless (window.path =~ /Internet Explorer/ rescue false)
        yield window
      end
    end
  end
end  


    class Dir
        def Dir.visit(dir = '.', files_first = false, &block)
            if files_first
                paths = []
                Find.find(dir) { |path| paths << path }
                paths.reverse_each {|path| yield path}
            else
                Find.find(dir, &block)
            end
        end
        # simulates unix rm -rf command
        def Dir.rm_rf(dir)
            Dir.visit(dir, true) do |path|
                if FileTest.directory?(path)
                    begin
                        Dir.unlink(path)
                    rescue # Security Exception for Content.IE
                    end
                else
                    begin
                        File.unlink(path)
                    rescue #Security exception index.dat etc.
                    end
                end
            end
        end
    end

module Watir
  module CookieManager 
    
    class WatirHelper
        #taken from shlObj.h  used in win32 SHGetSpecialFolderLocation
        #define CSIDL_INTERNET_CACHE            0x0020
        #define CSIDL_COOKIES                   0x0021
        #define CSIDL_HISTORY                   0x0022
        COOKIES = 0x0021
        INTERNET_CACHE = 0x0020
        
        def  WatirHelper.getSpecialFolderLocation(specFolderName)
            shell = WIN32OLE.new("Shell.Application")
            folder = shell.Namespace(specFolderName)
            folderItem = folder.Self
            folderPath = folderItem.Path
        end
        def  WatirHelper.deleteSpecialFolderContents(specFolderName)
            Dir.rm_rf(self.getSpecialFolderLocation(specFolderName))
        end
        
    end
  end  
end
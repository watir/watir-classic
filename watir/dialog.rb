require 'watir'
# TODO: move this file to watir/contrib

module Watir

    class Dialog
        def button(name)
            DialogButton.new(name)
        end
        def close
            # TODO: register autoit before use
            autoit = WIN32OLE.new('AutoItX3.Control')
            autoit.WinClose "Microsoft Internet Explorer", ""
        end
        def exists?
            # TODO: register autoit before use
            autoit = WIN32OLE.new('AutoItX3.Control')
            found = autoit.WinWait("Microsoft Internet Explorer", "", 1)
            return found == 1
        end 
    end
    
    def dialog
        Dialog.new
    end

    class DialogButton
        def initialize(name)
            @name = name
        end
        def click
            # TODO: register autoit before use
            autoit = WIN32OLE.new('AutoItX3.Control')
            autoit.WinWait "Microsoft Internet Explorer", "", 1
            name_pattern = Regexp.new "^#{@name}$"
            unless name_pattern =~ autoit.WinGetText("Microsoft Internet Explorer", "")
                raise Watir::Exception::UnknownObjectException
            end
            autoit.Send "{ENTER}"
        end
    end
    
end



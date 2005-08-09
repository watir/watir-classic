require 'watir'

module Watir

    class Dialog
        def button(name)
            DialogButton.new(name)
        end
        def close
            autoit = WIN32OLE.new('AutoItX3.Control')
            autoit.WinClose "Microsoft Internet Explorer", ""
        end
        def exists?
            autoit = WIN32OLE.new('AutoItX3.Control')
            found = autoit.WinWait("Microsoft Internet Explorer", "", 1)
            return found == 1
        end 
    end
    
    def dialog
        Dialog.new()
    end

    class DialogButton
        def initialize(name)
            @name = name
        end
        def click
            autoit = WIN32OLE.new('AutoItX3.Control')
            autoit.WinWait "Microsoft Internet Explorer", "", 1
            name_pattern = Regexp.new "^#{@name}$"
            unless name_pattern =~ autoit.WinGetText("Microsoft Internet Explorer", "")
                raise Watir::Exception::UnknownObjectException
            end
            autoit.Send "{ENTER}"
        end
    end
    
    class IE # modification
        def remote_eval(command)
            command.strip!
            load_path_code = _code_that_copies_readonly_array($LOAD_PATH, '$LOAD_PATH')
            ruby_code = "require 'watir'; ie = Watir::IE.attach(:title, '#{title}'); ie.instance_eval(#{command.inspect})"
            exec_string = "rubyw -e #{(load_path_code + ';' + ruby_code).inspect}"
            Thread.new { system(exec_string) }
        end
    end

end

    # why won't this work when placed in the module (where it properly belongs)
    def _code_that_copies_readonly_array(array, name)
        "temp = Array.new(#{array.inspect}); #{name}.clear; temp.each {|element| #{name} << element}"
    end        


require 'win32ole'


class IEController

    # version


    # constants

    # checboxes
    CHECKBOX_CHECKED = 1
    CHECKBOX_UNCHECKED = 2
    CHECKBOX_TOGGLE = 3

 

    # radio buttons


    # constants for IE
    READYSTATE_COMPLETE = 4

    # constants for messages
    OBJECTNOTFOUND = "Object Not Found"
    VALUENOTFOUND = "Value Not Found"
    NOTFOUND = "Not Found"


    DISABLED = "Object Disabled"

    # variables
        
    def log(logMe)
        # right now it just does a puts

        puts logMe

    end


    def getFunctionName()

        return /in `([^']*)'/.match(caller[0].to_s)[1]
    end

    def initialize()

        @ie =  WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = TRUE
    end

    def quit ()
        @ie.quit
    end

    def goto(url)
        @ie.navigate (url)
        waitForIE()
    end

    def waitForIE()
        while @ie.busy
            end
    
        until @ie.readyState == READYSTATE_COMPLETE
        end

    end


    def setRadioButton( name, value , formName="")
        fname = getFunctionName()
        log fname + ' Starting'
        radioToUse = nil
        begin
            if formName == ""
                radio = @ie.document.all[name.to_s]
            else
                radio = @ie.document.forms[formName.to_s][name.to_s]
            end
 
            
            radio.each do |o|
                #log fname + ' Checking radio: ' + name + ' ' + o.value.to_s + ' ' + o.disabled.to_s

                if o.value.to_s == value
                    radioToUse = o   # we have to do this, otherwise ruby locks up at the end of execution
                end
             
            end
            if radioToUse != nil

                    if radioToUse.disabled == true
                        return false, [ DISABLED ]
                    end

                    log fname + " clicking button #{name} Value #{value} "
                    radioToUse.click()
                    radioToUse.fireEvent("onMouseOver")
                    radioToUse.fireEvent("onClick")
                    waitForIE()
                    return true, [""]
            end
            return false, [VALUENOTFOUND]
        rescue => e
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $DEBUG
            return false, [OBJECTNOTFOUND]
        end
        
        
    end

    def clickButton (name , formName="")
        fname = getFunctionName()
        log fname + ' Starting. Trying to click button with name: ' + name
        buttonToUse = nil
        #begin
            if formName == ""
                button = @ie.document.all[ name.to_s ]
            else
                button = @ie.document.forms[formName.to_s][name.to_s]
            end
           
           log fname + " clicking button #{name} "

           button.fireEvent("onMouseOver")

           button.click()
                      
           waitForIE()
           return true, [""]
           
           
        #rescue
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $DEBUG
            return false, [OBJECTNOTFOUND]
        #end
        
        
    end

    def doKeyPress ( o , value )
        # o is an object, we assume the calling method has verified its ok....

        # we need to check the length of the box here, as script overrides the length attribute of the text box
        # http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/maxlength.asp


        for i in 0 .. value.length-1   # get rid of the nil at the end
            sleep 0.05   # typing speed
            c = value[i]
            o.value = o.value + c.chr
            o.fireEvent("onKeyPress")

        end

    end


    def setField (name , value )
        fname = getFunctionName()
        log fname + ' Starting. Trying to set field with name: ' + name + ' to ' + value.to_s

        begin
            o = @ie.document.all[ name ]  # if there are 2 eleemens with the same name, we get an exception - so we need a different version of this method
            o.focus()
            doKeyPress ( o , value ) 
            
            return true, [""]
        rescue
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $DEBUG
            return false, [OBJECTNOTFOUND]
        end

    end





end #class
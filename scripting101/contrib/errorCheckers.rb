#
#
# this file contains the plug in error checkers 


# This class isnt really a class - its more like an interface.
# It describes the methods and attributes that checkers should use
class ExampleChecker

    # the name of this error checker
    attr_accessor :myName

    # a description of this error checker
    attr_accessor :myDescription

    # is this checker enabled
    attr_accessor :enabled

    # the ID of this checker
    attr_accessor :id


    # you can do what you like in the initialize method, but it must have this signature
    def initialize(ie , enabled = true )

    end


    # this is the method that is called to do error checks.
    # it can do what it likes, including call other methods.
    # it should return:
    #   * false, []                          when no errors are found
    #   * true , [ descriptionOfErrors ]     when errors are found
    def errorCheck()

    end
end



# This class is the checker for http errors ( 404, 500 etc)
# we rely on IE displaying the message "The page cannot be displayed"
# we are then able to extract the error using the id tag on the text
class HTTPErrorChecker 

    # the class version
    VERSION = "$Revision$"

    # description of this checker
    MYDESCRIPTION = "Checks the page returned by IE for http errors, such as 404, 500 etc"

    # the name of this error checker
    attr_accessor :myName

    # a description of this error checker
    attr_accessor :myDescription

    # is this checker enabled
    attr_accessor :enabled

    # the ID of this checker
    attr_accessor :id

    def initialize(ie , enabled = true )
        @ie = ie
        @myName = self.class.to_s
        @myDescription = MYDESCRIPTION
        @enabled = enabled

        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil

    end

    def errorCheck()

       httpErrors =  HTMLHelpers.extractTextUsingTagAnAttribute(@ie, "H2", "id", "IEText", frameName = "" )
       if httpErrors == nil    
           return false, []
       else
           return true, httpErrors
           log self.class.to_s + " Errors Found: " + httpErrors.to_S
       end
    end

end


# this class checks each of the frames for the following error messages:
#    * An application error was encountered that prevented processing of your request
#    * Exception Description
class WRXApplicationErrorChecker

    # the class version
    VERSION = "$Revision$"

    # description of this checker
    MYDESCRIPTION = "Checks the page returned by IE for WRX specific errors"

    # the name of this error checker
    attr_accessor :myName

    # a description of this error checker
    attr_accessor :myDescription

    # is this checker enabled
    attr_accessor :enabled

    # the ID of this checker
    attr_accessor :id

    def initialize(ie , enabled = true )
        @ie = ie
        @myName = self.class.to_s
        @myDescription = MYDESCRIPTION
        @enabled = enabled

        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil

    end


    # returns true, messages if there is an error
    #  false, [] otherwsie
    def errorCheck()
       
        errorExists = false
        errorMessages = []
       
        f = @ie.getIE.document.frames

        log self.class.to_s + ": Frames to Check: " + f.length.to_s if $debuglevel >=8

        if f.length.to_s.to_i > 0
            for i in 0 .. f.length-1
                log 'Checking frame: ' + f[i.to_s].name.to_s + ' for exceptions' if $debuglevel >=6
                errorExists, errorMessages = checkForErrorMessage(f[i.to_s].name.to_s , i )
                break if errorExists
            end
        else
            errorExists, errorMessages = checkForErrorMessage( "" , 0 )
        end

        return errorExists, errorMessages 
    end


    def checkForErrorMessage(frameName , i)
        errorExists = false
        error = ""

        if @ie.pageContainsText("Exception Description" , frameName , false) or @ie.pageContainsText("Exception has Occurred" , frameName, false)
            if @ie.pageContainsText("triangle" , frameName , false) 
                # click the triangle
            end
            #   An Exception has Occurred</b> (click triangle to view)</a>
            #  we should probably try to click the link to expand the stack trace..........
            

            # an exception has occurred.
            # grab the stack trace 
            # is it in a frame
            if frameName == ""
                error = @ie.getIE.document.body.innerText
            else
                error = @ie.getIE.document.frames[i.to_s].document.body.innerText
            end
            errorExists  = true
        end

        # some times we also get the "An application error was encountered that prevented processing of your request."

        if @ie.pageContainsText("An application error was encountered that prevented processing of your request." , frameName, false)
            if frameName == ""
                error = error + "\n" +  @ie.getIE.document.body.innerText
            else
                error = error + "\n" +  @ie.getIE.document.frames[i.to_s].document.body.innerText
            end
            errorExists  = true
        end

        # we also get a 'You backtracked too far'
        if @ie.pageContainsText("You backtracked too far" , frameName, false)
            if frameName == ""
                error = error + "\n" +  @ie.getIE.document.body.innerText
            else
                error = error + "\n" +  @ie.getIE.document.frames[i.to_s].document.body.innerText
            end
            errorExists  = true
        end


        if errorExists  
            r =     "\n\n---------------------------------- Exception ------------------------------\n\n"
            r =r +   error 
            r =r +  "\n\n---------------------------------------------------------------------------\n\n"

            log r
            logException()
        end
        return errorExists, error

    end

end
#
#  IEController
#


require 'win32ole'
require 'htmlHelpers'
  require 'errorCheckers'


# this class is the main IEcontroller
# it uses the IE Dom[http://msdn.microsoft.com/workshop/author/dhtml/reference/dhtml_reference_entry.asp?frame=true]

class IEController 

    

    # an array of the URLs that we have been too
    attr_reader  :urlList  

    # an array that contains a list of strings with details of images that may be missing
    attr_reader :missingImages

    # the download time of the last page
    attr_reader  :pageLoadTime


    #this is a sleep method to make everything go slow
    attr_accessor :sleepTime


    #this is a sleep method to make typing go slow
    attr_accessor :typingspeed 

    # This tells us if a page has reloaded
    attr_reader :pageHasReloaded

    # Set this to true (default is true ) to enable highlighting of the current elemnt
    attr_accessor :useHighLightOnCurrentElement

    #-- 
    # these accessors are used for the error checker
    #++    

    # this attribute allows access to the array of checkers
    attr_accessor :availableCheckers

    # this attribute contains the errors that were detected, or nil if none were
    # it contains a hash, where key=errocCheckerName value = array of error messages
    attr_reader :foundErrors 



    # the version of the file
    VERSION = "$Revision$"         

    # Used when setting checkbox values
    CHECKBOX_CHECKED = 1             

    # Used when setting checkbox values
    CHECKBOX_UNCHECKED = 2           

    # Used when setting checkbox values
    CHECKBOX_TOGGLE = 3              
 
    # Used internaly to determine when IE has fiished loading a page
    READYSTATE_COMPLETE = 4          

    # ---
    # constants for messages
    # ++

    # constant for the message array when an object is not found
    OBJECTNOTFOUND = "Object Not Found"   

    # constant for the message array when avalue is not found
    VALUENOTFOUND = "Value Not Found"     

    # constant for the message array when an object is not found
    NOTFOUND = "Not Found"                

    # constant for the message array when an object is disabled
    DISABLED = "Object Disabled"          

    # constant for the message array when an object is disabled
    OBJECTDISABLED  = DISABLED            


    # how long we sleep between element accesses
    DEFAULTSLEEPTIME = 0.25               

    # default typing speed 
    DEFAULTTYPINGSPEED = 0.1

    # used internally to switch sleeping off
    NOWAITFORIE = true                    


    def initialize(  useThreads=false, threadNumber=-1 )

        #if environment == "" or environment == nil
        #    raise "Environemtn must be supplied to the IEController!"
        #end
 
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil

        @ie =  WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = TRUE

        @sleepTime = DEFAULTSLEEPTIME
        @urlList = []
        

        @pageLoadTime =0.0
        @typingspeed = DEFAULTTYPINGSPEED

 
 
        @useThreads = useThreads
        @myNumber   = threadNumber

        @useHighLightOnCurrentElement = true
        @currentObjectBackGroundColor = nil

        @availableCheckers = []

        httpChecker = HTTPErrorChecker.new(self)
        wrxErrorChecker = WRXApplicationErrorChecker.new(self)

        registerErrorChecker(httpChecker)
        registerErrorChecker(wrxErrorChecker)

    end

    def log(s)

        puts s

    end


    #--
    # ----------------------------  dom saver ------------------------
    #++
    

    #this method dumps the dom to the specified IO stream
    def dump_dom(io=$stdout)
        dv = ClIEDomViewer.new(self)
        dv.outputDom(io)
      end


     # should be a private method. Used by dump_dom
     def htmlNode
        @ie.document.childNodes.length.times do |i|
          if @ie.document.childNodes(i).nodeName == 'HTML'
            return @ie.document.childNodes(i)
            break
          end
        end
      end




    # --
    # Methods to change and clear the background color of the active element
    # ++
 
    # this method sets the background of the specified object to red, so we can see what we are working on
    def setBackGround(o)
        if useHighLightOnCurrentElement
            begin 
                @currentObjectBackGroundColor = o.style.backgroundColor
                #puts "Current Back ground color is: #{@currentObjectBackGroundColor}"
                @backGroundObject = o
                @backGroundObject.style.backgroundColor = "red"
            rescue

            end
        end
    end

    def clearBackground()

        begin 
            if @backGroundObject
                @backGroundObject.style.backgroundColor =@currentObjectBackGroundColor
                @backGroundObject = nil
            end
        rescue

        end

    end

    #--
    # ----------------------------  Error Checking methods ------------------------
    #++


    # this method returns the current error messages as an an array
    # it probably isnt needed as the array is also available as @foundErrors
    def getErrors()
        return @foundErrors
    end


    # this method starts the enabled checkers.
    # it returns true if there were  errors, false if no errors were detected
    # when errors are detected, the foundErrors attribute contains the errors that were detected
    def doesPageContainErrors()
        #log "doesPageContainErrors.."
        errorsFound = false
        @foundErrors  = nil
        @availableCheckers.each do |c|
            if c.enabled
                a, errorText = c.errorCheck() 
                if a == true  # errors were detected

                    log "-----------------------------------------------------------------------------------------"
                    log  "#{c.myName} has an error: #{errorText}"
                    log "-----------------------------------------------------------------------------------------"

                    @foundErrors = { c.myName => errorText }
                    errorsFound = true
                end
            end
        end
        return errorsFound

    end


    # this method allows an error checker to register 
    # it returns an integer that is an ID used to identify the checker
    #   * checker   - a class that follows the ExampleChecker interface
    def registerErrorChecker( checker )
        id = checker.id
        @availableCheckers << checker
        return id
    end

    # this method allows a checker to be deregistered
    # returns true if it was successfully deregistered, false otherwise
    #   *  id  - integer , the ID that identifies the checker to deregister
    def unRegisterChecker( id )
        @availableCheckers.delete_if{ |x| x.id == id}
    end

    # this method enables the specified checker.
    #   *  id  - integer , the ID that identifies the checker to enable
    def enableChecker( id )
        @availableCheckers.collect {|x| x.enabled = true if x.id == id} 
    end

    # this method disables the specified checker.
    #   *  id  - integer , the ID that identifies the checker to disable
    def disableChecker(id)
        @availableCheckers.collect {|x| x.enabled = false if x.id == id} 
    end





    # ---------------------------   IE methods ----------------------------------------


    # set the position of the browser position is a IEWindowPosition object
    def setWindowPosition ( position  )

        @ie.top=position.myTop
        @ie.left = position.myLeft
        @ie.height = position.myHeight
        @ie.width = position.myWidth
    end


    # use this method to hide the unnecessary toolbars
    def hideToolBars()
        @ie.AddressBar = true
        @ie.StatusBar = true
        @ie.ToolBar= false
        @ie.MenuBar = false
        
    end

    # this method returns the index of the form that has the specified action
    # todo - Make this work with frames 
    def getFormIndexFromAction(formAction  )

         index = nil
         i = 0
         @ie.document.forms.each do |f|
             next unless index == nil
             index = i   if f.action.to_s == formAction
             i+=1
         end

         return index
    end

    # closes IE
    def quit ()
        @ie.quit
    end

    # this method returns the IE object
    def getIE()
        # allows the calling program direct acces to ie 
        return @ie
    end

    # navigate to a url
    # returns true if it navigated ok, false if some sort of error was detected
    #   * url    - string , the url to navigate to
    def goto(url)
         fname = getFunctionName()
         log fname + " Starting. Going to url: #{url}" if $debuglevel >=0
        @ie.navigate(url)
        sleep 2
        return waitForIE()
        
    end


    # returns true if IE is available, false if it is busy
    def ieIsAvailable()

        return false if @ie.busy 
        return false if @ie.readyState != READYSTATE_COMPLETE
 
        return true

    end


    # wait for IE to complete it its current action. Should be a private method
    # returns false if an error was detected when the page has loaded
    def waitForIE( noSleep  = false )

        s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
        i=0
 
        pageLoadStart = Time.now
        @pageHasReloaded= false

        #puts "waitForIE: busy" + @ie.busy.to_s

        while @ie.busy
            @pageHasReloaded = true
            sleep 0.02
            if i > s.length-1
                i=0
            end
            print  s[i]
            i=i+1
        end
        s.reverse

        #puts "waitForIE: readystate=" + @ie.readyState.to_s 
        until @ie.readyState == READYSTATE_COMPLETE
            @pageHasReloaded = true
            sleep 0.02
            if i > s.length-1
                i=0
            end
            print s[i]
            i=i+1
        end

        # make sure all the frames have loaded
        ff = @ie.document.frames
        s.reverse
        for f in 0 .. ff.length-1

            #puts "FrameCheck - frame[#{f}] readystate = #{@ie.document.frames[ f.to_s].document.readyState}"
            until @ie.document.frames[ f.to_s].document.readyState.to_s.downcase == "complete"

              sleep 0.02
              i=0 unless i < s.length-1
              print s[i]
              i=i+1

            end
        end               


        print "\b"

        pageLoadEnd = Time.now
        if @pageHasReloaded == true
            @pageLoadTime = pageLoadEnd - pageLoadStart
        end

        # always sleep a bit 
        sleep 0.25 unless noSleep == true

        # sleep longer if the user has set it
        sleep @sleepTime unless noSleep == true

        # check for errors here
        if @pageHasReloaded == true
            if doesPageContainErrors() == true # an error has occurred
                return false
            end
        end


        # add the current url to the list 
        #@urlList << @ie.locationURL
        # this only gets us the url of the frame, we want all the pages to do proper security checking
        
        ff = @ie.document.frames

        #log "there are " + ff.length.to_s + " frames"

        for f in 0 .. ff.length-1
            @urlList << @ie.document.frames[ f.to_s].document.URL
           checkImages( @ie.document.frames[ f.to_s].document )

        end               

        return true
    end

    def checkImages( doc )

        doc.images.each do |image|
            #puts "Checking image: #{image.src}"
            if image.fileCreatedDate.to_s == "" and image.fileSize.to_i == -1
                i= "image: url:#{image.src} id:#{image.id} name:#{image.name} on #{doc.title} may be missing"
                log i
                logMissingImage( i )                
            end
        end

    end


    #--
    #-----------------------------   Frame Building methods ---------------------------
    #++

    # returns the object with the correct path. Should be a private method
    def getObjectFrameReference( name , frameName )

           if frameName == "" then
               frame = @ie.document
           else
               ff = @ie.document.frames

               #log "there are " + ff.length.to_s + " frames"
               #for f in 0 .. ff.length-1
               #    log "Frame: " + ff[f.to_s].name.to_s  
               #end               

               frame = @ie.document.frames[ frameName.to_s ].document
           end 
          return frame
    end




    # this method displayes the names of the frames
    def showFrames()
=begin
    
               ff = @ie.document.frames

               log "there are " + ff.length.to_s + " frames" if $debuglevel >=0

               for f in 0 .. ff.length-1
                   log "Frame: " + ff[f.to_s].name.to_s if $debuglevel >=0 
                   log "My parent is: " + ff[f.to_s].parentWindow.name.to_s if $debuglevel >=0
               end               

               #frame = @ie.document.frames[ frameName ].document
    
=end
    end


    # this returns the objects container - is it a frame, form etc... Should be private
    def getObjectContainer( name , formName , frameName )

           
           fname = getFunctionName()
           log fname + " Starting. building container for #{name}  - Form: #{formName}  - frameName: #{frameName} " if $debuglevel >= 2
           frame = getObjectFrameReference( name , frameName )

           if formName == "" then
               o = frame.body
           else
               if formName.kind_of?  Fixnum
                   o = frame.forms[ formName.to_s ]
               end
           end

           return o
    end





    #--
    #--------------------------  Radio Buttons ------------------------------------
    #++


    # this method sets the radio button
    #  * name        the name of the radio button group
    #  * value       the value of the button to set
    #  * formName    the form the button is in
    #  * frameName   the frame to use
    def setRadioButton( name, value , formName="" , frameName = "" )
        fname = getFunctionName()
        log fname + ' Starting' if $debuglevel >=0
        radioToUse = nil
        #begin
            log fname + ' Setting radio: ' + name if $debuglevel >=0

            container = getObjectContainer( name , formName , frameName )
            allRadios = container.all
            allRadios.each do |o|
                next unless radioToUse  == nil
                begin 
                    log fname + ' Checking radio: ' + name + ' ' + o.value.to_s + ' ' + o.disabled.to_s if $debuglevel >=4
                    if o.value.to_s == value  and radioToUse == nil
                        radioToUse = o   # we have to do this, otherwise ruby locks up at the end of execution
                    end
                rescue
                    # this object probably doesnt have a value 
                end 
            end
            if radioToUse != nil
                    setBackGround(radioToUse)
                    if radioToUse.disabled == true
                        clearBackground()
                        return false, [ DISABLED ]
                    end

                    log fname + " clicking radio button #{name} Value #{value} " if $debuglevel >=1
                    radioToUse.click()
                    radioToUse.fireEvent("onMouseOver")
                    radioToUse.fireEvent("onClick")
                    if waitForIE()
                        clearBackground
                        return true, [""]
                    else
                        clearBackground
                        return false, [fname + " problem loading the page"]
                    end
            end
            clearBackground 
            return false, [VALUENOTFOUND]
        #rescue => e
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $debuglevel >=1
            clearBackground
            return false, [OBJECTNOTFOUND]
        #end
        
    end   #setRadioButton



    #--
    # -----------------------  Buttons -------------------------
    #++

    # this method clicks a button with the specified name attribute
    #  * name        the html name of the button 
    #  * formName    the form the button is in
    #  * frameName   the frame to use
    def clickButtonWithName (name, formName="" , frameName = "" )
        fname = getFunctionName()
        log fname + ' Starting. Trying to click button with name : ' + name #if $debuglevel >=0
        buttonToUse = nil
        begin

           container = getObjectContainer( name , formName , frameName )   
       
           container.all.each do |c|
               next unless buttonToUse == nil
               begin
                   if c.name == name
                       puts fname + " checking element #{c.name} " 
                       buttonToUse = c
                   end
               rescue 
                   # this element probably doesnt have a value
               end
           end

           if buttonToUse == nil
               # the button wasnt found
               return false , [OBJECTNOTFOUND]
           end
           setBackGround(buttonToUse)
           buttonToUse.fireEvent("onMouseOver")
           buttonToUse .click()
           log "\nClicked button with name: #{name} "
           if waitForIE()
               clearBackground
               return true, [""]
           else
               clearBackground
               return false, [fname + " problem loading the page"]
           end

           
        rescue => e
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s #if $debuglevel >= 1

            puts e
            puts e.backtrace.join("\n")

            puts"\n\n\nDidnt Click it!!!\n\n\n\n\n"
            clearBackground 
            return false, [OBJECTNOTFOUND]
        end
        
    end


    # this method returns true if the button with the specified caption is on the page, false if it isnt
    def isButtonOnPage_Caption (caption , frameName = "" )

        fname = getFunctionName()
        log fname + ' Starting. Trying to find button with caption: ' + caption if $debuglevel >=0
        buttonToUse = nil
        #begin
        
           # we have to find the button
           container = getObjectContainer( caption , "" , frameName )
    
           container.all.each do |c|
               next unless buttonToUse == nil
               begin
                   if c.value == caption
                       buttonToUse = c
                   end
               rescue 
                   # this element probably doesnt have a value
               end
           end

           if buttonToUse == nil
               # the button wasnt found
               return false 
           else
               # We found the button 
               return true
           end

        #rescue
            return false
        #end
    end

    # this method clicks a button with the specified caption
    #  * caption     the caption of the button 
    #  * formName    the form the button is in
    #  * frameName   the frame to use
    def clickButtonWithCaption (caption , formName="" , frameName = "" )
        fname = getFunctionName()
        log fname + ' Starting. Trying to click button with caption: ' + caption.to_s if $debuglevel >=0
        buttonToUse = nil
        begin
        
           # we have to find the button
           container = getObjectContainer( caption , formName , frameName )
    
           container.all.each do |c|
               next unless buttonToUse == nil
               begin 
                   log  fname + " Checking object name: " + c.value + " comparing its value of: " + c.value + " to supplied of: " + caption if $debuglevel >=6

                   if c.value == caption and buttonToUse == nil and ( c.invoke("type").to_s.downcase == "button"  or c.invoke("type").to_s.downcase == "submit")

                       buttonToUse = c
                       log fname + " Using this Button: " + c.value if $debuglevel >= 2
                   end
               rescue 
                   # this element probably doesnt have a value
               end
           end
 
           if buttonToUse != nil
               setBackGround(buttonToUse)
               log fname + " clicking button #{caption} (object name is #{buttonToUse.name} )" if $debuglevel >=0

               buttonToUse.fireEvent("onMouseOver")
               buttonToUse.click()
                          
               if waitForIE()
                   clearBackground
                   return true, [""]
               else
                   clearBackground
                   return false, [fname + " problem loading the page"]
               end


           else
               log fname + " object Not Found " if $debuglevel >= 0
               clearBackground
               return false, [OBJECTNOTFOUND]
           end              
            
        rescue => e
            #log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: #{e.to_s}"  if $debuglevel >= 0
            showException(e) if $debuglevel >= 0
            clearBackground
            return false, [OBJECTNOTFOUND]
        end
    end


    #--
    # -------------------  Fields ----------------------------
    #++



    # this method fills in text fields. It should be private
    def doKeyPress ( o , suppliedValue )
        # o is an object, we assume the calling method has verified its ok....

        # we need to check the length of the box here, as script overrides the length attribute of the text box
        # http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/maxlength.asp

        fname = getFunctionName()
        #log fname + ' doing keypress on field: ' + o.name.to_s
        value = suppliedValue.to_s
        begin
            maxLength = o.maxLength
            if value.length > maxLength
                value = suppliedValue[0 .. maxLength ]
                log fname + " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"if $debuglevel >=0
            end
        rescue
            # its probably a text area - so it doesnt have a max Length
            maxLength = -1
        end

        for i in 0 .. value.length-1   
            sleep @typingspeed   # typing speed
            c = value[i]
            #log  " adding c.chr " + c.chr.to_s
            o.value = o.value.to_s + c.chr
            o.fireEvent("onKeyPress")
            if waitForIE( NOWAITFORIE )      
                # we dont do anything if its good....
            else
                return false, [fname + " problem loading the page"]
            end
        end
    end

    # this method checks to see if the specified field exists in the specified frame
    #  returns true or false
    #  * name        string  -   html name of the field
    #  * formName    string  -   the frame to look in
    #  * frameName   string  -   the frame to use
    def doesFieldExist(name,formName="", frameName="")

        fname = getFunctionName()
        log fname + ' Starting. Trying to see if field with name: ' + name + ' exists '
        messages = []

        container = getObjectContainer( name , formName, frameName )

        o = nil

        container.all.each do |c|
            next unless o == nil
            begin
                if c.invoke("type").to_s.downcase =="text"
                    log fname + " found text field #{c.name}" 
                    if c.name.to_s == name and o == nil 
                        o = c
                        log fname + " found the correct text field #{c.name}" 
                    end
                end
            rescue
                  # probably no name
            end
        end

        return false   if o == nil
        return true
             
    end


    # this method appends text to a field
    #  * name        string  -   html name of the field
    #  * value       string  -   text to append
    #  * formName    string  -   the form the field is in
    #  * frameName   string  -   the frame to use
    def appendField (name, value, formName="", frameName="")
 
        setField(name, value, formName, frameName, true)
    end

    # this method sets a text field to a certain value
    #  * name        string  -   html name of the field
    #  * value       string  -   text to append
    #  * formName    string  -   the form the field is in
    #  * frameName   string  -   the frame to use ( if its an integer, we use the form Index) Todo find a better way of doing this
    #  * append      boolean -   do we append the text
    def setField (name , value , formName = "" , frameName = "" , append=false)
        fname = getFunctionName()
        log fname + ' Starting. Trying to set field with name: ' + name + ' to ' + value.to_s if $debuglevel >=0
        messages = []

        begin  # if there are 2 elements with the same name, we get an exception - so we need a different version of this method

             container = getObjectContainer( name , formName , frameName )

             o = nil

             container.all.each do |c|
                 next unless o == nil
                 begin
                     if c.name.to_s == name and o == nil and ( c.invoke("type").to_s.downcase == "text" or c.invoke("type").to_s.downcase == "textarea" )

                        #log 'Hack:: found the object. '
                        o = c
                     end
                  rescue
                      # probably no name
                  end
             end
             #o = container.all[ name.to_s ] 
             # the line above is the preffered way to do this 
             # but the frames whack it - maybe we can try getElementByName.....
             # o = container.getElementByName( name.to_s )
             # this didnt seem to work either!!

             if o == nil
                 return false, [ OBJECTNOTFOUND ]
             end

             if o.disabled
                 return false, [ OBJECTDISABLED ]
             end


            setBackGround(o) 
            o.focus() 
            if append ==false
                # clear out the field first
                if o.value.length > 0
                    o.select()
                    o.fireEvent("onSelect")
                    if waitForIE()
                       # we dont want to wait here
                    else
                        clearBackground()
                        return false, [fname + " problem loading the page"]
                    end


                    o.value = ""
                    o.fireEvent("onKeyPress")
                    o.fireEvent("onChange")
                end

            end

            doKeyPress( o , value ) 
            o.fireEvent("onKeyPress")
            o.fireEvent("onChange")

            if waitForIE()
                
            else
               clearBackground()
               return false, [fname + " problem loading the page"]
            end


        rescue => e
            log fname + " threw an exception: #{e} \n #{e.backtrace.join("\n")} " if $debuglevel >=0
            #showException(e)
            clearBackground()
            return false, [OBJECTNOTFOUND]
        end
        clearBackground()
        return true, messages
    end


    # this method returns the text in a field
    #  * name        html name of the field
    #  * formName    the form the field is in
    #  * frameName   the frame to use
    def getFieldValue(  name , formName = "" , frameName = "" )
        # returns the current value of the field
   
        fname = getFunctionName()
        log fname + ' Starting. getting value for field with name: ' + name if $debuglevel >=0

        begin  # if there are 2 elements with the same name, we get an exception - so we need a different version of this method

             container = getObjectContainer( name , formName , frameName )

             o = nil
             v = ""
             container.all.each do |c|
                 next unless o == nil
                 begin
                     if c.name.to_s == name 
                        #log 'Hack:: found the object. '
                        o = c
                     end
                  rescue
                      # probably no name
                  end
             end
             if o != nil
                 v = o.value.to_s
             else
                 v = nil
             end

         rescue  => e
             showException(e)
             v = nil     
         end 
         return v
        
    end

    #--
    #------------------------  Select Boxes -------------------------------------
    #++

    # this method checks to see if the specified select box exists on the page
    # returns true|false 
    #    * name       - the name of the select box to look for
    #    * formName   - the name of the form to look in 
    #    * frameName  - the frame to look in
    def doesSelectBoxExist(name ,  formName = "" , frameName= "")

        fname = getFunctionName()
        log fname + ' Starting. Trying to find selectbox with name: ' + name.to_s 
        o = nil
        container = getObjectContainer( name , formName  , frameName )
        container.all.each do |f| 
           next unless o == nil
           begin
               if f.name.to_s == name and o == nil 
                   #log 'Hack:: found the object. Its length is: ' + f.length.to_s
                   o = f
               end
           rescue
               # probably has no name if we are here
           end
        end
        if o == nil
            log fname + ' Failed to find the select box with name: ' + name.to_s
            return false
        end
        return true

    end






    # this method returns all the items in the specified select box as an array
    # returns true|false, messages, selectBoxArray
    #  * name        html name of the select box
    #  * frameName   the frame to use
    def getAllSelectBoxContents(name , formName= "" , frameName= "")
        # returns true|false, messages, selectedItemsArray
        # selectedItemsArray is an array because we could have a muli-select box

        fname = getFunctionName()
        log fname + ' Starting. Trying to find selectbox with name: ' + name.to_s 
        o = nil
        container = getObjectContainer( name , formName  , frameName )
        container.all.each do |f| 
           next unless o == nil
           begin
               if f.name.to_s == name and o == nil 
                   #log 'Hack:: found the object. Its length is: ' + f.length.to_s
                   o = f
               end
           rescue
               # probably has no name if we are here
           end
        end
        if o == nil
            log fname + ' Failed to find the select box with name: ' + name.to_s
            return false, [ OBJECTNOTFOUND ] , nil
        end


        returnArray = []

        o.each do |thisItem|
            returnArray << thisItem.text
        end

        return true, [] , returnArray 

    end




    # this method returns the selected item in a select box
    #  * name        html name of the select box
    #  * frameName   the frame to use
    def getSelectBoxSelectedItems(name ,  frameName= "")
        # returns true|false, messages, selectedItemsArray
        # selectedItemsArray is an array because we could have a muli-select box

        fname = getFunctionName()
        log "#{ fname } Starting. Trying to find selectbox with name: #{ name.to_s  } in frame #{frameName }"
        o = nil
        container = getObjectContainer( name , ""  , frameName )
        container.all.each do |f| 
           next unless o == nil

           begin
               #log fname + " got an object: #{f.name.to_s} Type is #{f.invoke("type")} "  if $debuglevel >= 6
               if f.name.to_s == name and o == nil and f.invoke("type").downcase.index("select") != nil
                   log fname + " found the object #{f.name.to_s} Its length is: " + f.length.to_s    if $debuglevel >= 6
                   o = f
               end
           rescue => e 
               #log fname + ' ' + e.to_s
               # probably has no name if we are here
           end
        end
        if o == nil
            log fname + ' Failed to find the select box with name: ' + name.to_s
            return false, [ OBJECTNOTFOUND ] , nil
        end

        index =0
        foundIt = false
        selectedItemsArray = []

        o.each do |thisItem|
            if thisItem.selected == true
                log fname + " Found a selected item. (" + thisItem.text + ")" if $debuglevel >= 2
                selectedItemsArray << thisItem.text
            end
            index=index+1
        end

        return true, [] , selectedItemsArray

    end


    # this method determines if a select box contains an item
    # returns true|false, messages
    #  * name        html name of the select box
    #  * value       the text to look for
    #  * frameName   the frame to use

    def doesSelectListContain ( name , value , frameName = "" )

        fname = getFunctionName()
        log fname + ' Starting. Trying to find selectbox with name: ' + name.to_s + ' and value ' + value.to_s if $debuglevel >=0

        o = nil
        #begin 
             container = getObjectContainer( name , ""  , frameName )
             container.all.each do |f| 
                next unless o == nil
                begin
                    #log " name: " + f.name.to_s + " value: " + f.value.to_s if $debuglevel >=0

                    if f.name.to_s == name and o == nil 
                        #log 'Hack:: found the object. Its length is: ' + f.length.to_s
                        o = f
                    end
                rescue
 
                end

             end

             if o == nil
                 log fname + ' Failed to find select box with name: ' + name.to_s if $debuglevel >=0
                 return false, [ OBJECTNOTFOUND ]
             end

             #log fname + " type is: " + o.type.to_s
             log fname + " name is: " + o.name.to_s if $debuglevel >=4

             if o.disabled
                 log fname +  "Object is Disabled" 
                 return false, [ OBJECTDISABLED ]
             else
                 log fname +  "Select box is enabled" if $debuglevel >= 4
             end
             index =0
             foundIt = false
 
             if value.class.to_s == "String"
                 log fname + " converting supplied string (#{value}) to a reg exp" if $debuglevel >= 2
                 revalue = Regexp.new( Regexp.escape(value) )
             else
                 revalue = value
                 log fname + " supplied value (#{value}) is a reg exp" if $debuglevel >= 2
              end


             o.each do |thisItem|
                 log fname + " value for select box is: " + thisItem.text.to_s + " comparing to supplied value of: " + value.to_s  if $debuglevel >=4
                 if thisItem.text =~ revalue
                     log fname + " Found a match! Select Box value: " + thisItem.text + " Compared to: " + value.to_s if $debuglevel >=0
                     foundIt = true
                 end
                 index=index+1
             end

             return foundIt, []
        #rescue
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $debuglevel >= 0
            return false, [ OBJECTNOTFOUND ]
        #end
    end

    # this method sets a select box 
    #  * name        html name of the field
    #  * value       text select
    #  * formName    the form the field is in
    #  * frameName   the frame to use
    def setSelectBoxItem( name , value , formName = "" , frameName = "" )

        fname = getFunctionName()
        log fname +  " Starting. Trying to set selectbox with name: " + name.to_s + " to: " + value.to_s  if $debuglevel >=0

        o = nil
        #begin 
             container = getObjectContainer( name , formName , frameName )
             container.all.each do |f| 
                next unless o == nil
                begin
                    log fname + " name: " + f.name.to_s + " value: " + f.value.to_s if $debuglevel >= 4

                    if f.name.to_s == name and o == nil 
                        log fname + ' found the object. It contains : ' + f.length.to_s + " items " if $debuglevel >= 4
                        o = f
                    end
                rescue
 
                end
             end
             
             if o == nil
                 log fname + " Failed to find an select box with name: " + name.to_s if $debuglevel >= 0
                 return false, [ OBJECTNOTFOUND ]
             end
             #o = container.all[ name.to_s]

             #log o.type.to_s
             #log "name is: " + o.name
             setBackGround(o)
             if o.disabled
                 log fname + " " + name.to_s + " is disabled"  if $debuglevel >= 4
                 clearBackground
                 return false, [ OBJECTDISABLED ]
             else
                 log fname + " " + name.to_s + " is enabled"  if $debuglevel >= 4
             end

             o.focus()

             # we can do stuff here with constants
             # eg SELECT_FIRST_ITEM
             itemToSelect = nil
             index = 0 
             foundIt = false

             #log "o.length=" + o.length.to_s
             if value.class.to_s == "String"
                 log fname + " converting supplied string (#{value}) to a reg exp" if $debuglevel >= 1
                 revalue = Regexp.new( Regexp.escape(value) )
             else
                 revalue = value
                 log fname + " supplied value (#{value}) is a reg exp" if $debuglevel >= 1
              end

             o.each do |thisItem|
                 log fname + " value for select box is: "+ thisItem.text + " comparing to supplied value of: " + revalue.to_s if $debuglevel >= 4
                  if (thisItem.text =~ revalue ) != nil
                     if foundIt == false
                         o[index.to_s].selected = true
                         o.fireEvent("onChange")
                         if waitForIE()
                             # we dont want to return here
                         else
                             clearBackground
                              return false, [fname + " problem loading the page"]
                         end


                         foundIt = true
                     end
                 end
                 index=index+1
             end
             if foundIt == true
                 clearBackground
                 return true , [ "" ]
             else
                 log fname + " Found select box with name: #{name} but didn't find value: #{value}" if $debuglevel >=0
                 clearBackground
                 return false , [ VALUENOTFOUND ]
             end

        #rescue
            log fname + " (line #{__LINE__} , file #{__FILE__} threw an exception: " + e.to_s if $debuglevel >= 0
            clearBackground
            return false, [ OBJECTNOTFOUND ]
        #end
    end

    #--------------------------- Links ----------------------------------


    # this method clicks a link with the specified text
    #  * text        text of the link
    #  * frameName   the frame to use
    #  * index       the position on the page, ie 1 = 1st link with this text, 2 = second etc...
    def clickLinkWithText (text , frameName = "" , index = 1 )

        fname = getFunctionName()
        log fname + " Starting. Trying to click link with text: " + text.to_s if $debuglevel >=0

        # the links collection applies to a document, not document.all
        # so we cant use getObjectReference

        container = getObjectFrameReference( text, frameName )
        l = container.links
        thisLink = nil
        thisIndex = 1

        for i in 0 .. l.length-1
            log "Found Link: " + l[i.to_s].href if $debuglevel >=4
            
            #if l[i.to_s].innerText == text # without reg exp
            if (l[i.to_s].innerText =~ /#{text}/) !=nil
                #if thisLink == nil  # this is the line that was changed to the one below to accomodate the index number. Left just in case...
                if thisIndex == index
                    thisLink = l[i.to_s]
                end
                thisIndex = thisIndex + 1
            end
        end
        if thisLink == nil 
            # didnt find the link
            log "Link with text: " + text.to_s + " not found" if $debuglevel >= 2
            return false, [ NOTFOUND ]
        end
        setBackGround(thisLink)
        thisLink.fireEvent("onMouseOver")
        thisLink.click()
        if waitForIE()
            clearBackground
            return true, [""]
        else
            clearBackground
            return false, [fname + " problem loading the page"]
        end
    end




    # this method clicks a link with the specified url
    #  * text        text of the link
    #  * frameName   the frame to use
    #  * index       the position on the page, ie 1 = 1st link with this text, 2 = second etc...
    def clickLinkWithURL(url, frameName = "" , index = 1 )

        fname = getFunctionName()
        log fname + " Starting. Trying to click link with url: " + url.to_s if $debuglevel >=0

        # the links collection applies to a document, not document.all
        # so we cant use getObjectReference

        container = getObjectFrameReference( url, frameName )
        l = container.links
        thisLink = nil
        thisIndex = 1

        for i in 0 .. l.length-1
            log "Found Link: " + l[i.to_s].href if $debuglevel >=4
            
            if (l[i.to_s].href.to_s =~ /#{url}/) !=nil
                log "Found a matching link. Now checking the index" if $debuglevel >=4
                if thisIndex == index
                    log "Found a matching index ( #{index}) " if $debuglevel >=4
                    thisLink = l[i.to_s]
                end
                thisIndex = thisIndex + 1
            end
        end
        if thisLink == nil 
            # didnt find the link
            log "Link with url: " + url.to_s + " not found" if $debuglevel >= 2
            return false, [ NOTFOUND ]
        end
        setBackGround(thisLink)
        thisLink.fireEvent("onMouseOver")
        thisLink.click()
        if waitForIE()
            clearBackground
            return true, [""]
        else
            clearBackground
            return false, [fname + " problem loading the page"]
        end
    end





    # this returns a WRXLink object, populated with things like the text, the url, the target.....
    #  * text        text of the link to find
    #  * frameName   the frame to use
    def getLinkWithText(text,  frameName = "" )

        # this returns a wrxLink object, populated with things like the text, the url, the target.....

        fname = getFunctionName()
        log fname + " Starting. getting link with text: " + text.to_s if $debuglevel >=0

        # the links collection applies to a document, not document.all
        # so we cant use getObjectReference

        container = getObjectFrameReference( text, frameName )
        l = container.links
        thisLink = nil
        for i in 0 .. l.length-1
            log "Found Link: " + l[i.to_s].href if $debuglevel >=4
            
            #if l[i.to_s].innerText == text # without reg exp
            if (l[i.to_s].innerText =~ /#{text}/) !=nil
                if thisLink == nil
                    thisLink = l[i.to_s]
                end
            end
        end
        if thisLink == nil 
            # didnt find the link
            log fname + " link with text: " + text.to_s + " not found " if $debuglevel >= 2
            return nil
        end

        #debug code
        #puts thisLink.methods.join("\n")

        wrxLink  = WRXLink.new
        wrxLink.href      = thisLink.href
        wrxLink.innerText = thisLink.innerText
        wrxLink.innerHTML = thisLink.innerHTML
        wrxLink.target    = thisLink.target
        wrxLink.name      = thisLink.name
        wrxLink.id        = thisLink.id

        return wrxLink

    end

    # ---------------- Check boxes ---------------

    # this sets a checkbox to the specified state. Should be a private
    def setCheckBoxState ( o , state )

        # dont call this directly - use setCheckBox

        o.fireEvent("onMouseOver")
        if !waitForIE(NOWAITFORIE)
            return false, [fname + " problem loading the page"]
        end

        o.focus()

        if !waitForIE(NOWAITFORIE)
            return false, [fname + " problem loading the page"]
        end

        o.checked = state

        if !waitForIE(NOWAITFORIE)
            return false, [fname + " problem loading the page"]
        end

        o.fireEvent("onClick")
        if !waitForIE(NOWAITFORIE)
            return false, [fname + " problem loading the page"]
        end


        # if the page has reloaded we dont want to fire more events on this object
        if !@pageHasReloaded

            o.fireEvent("onChange")
            if !waitForIE(NOWAITFORIE)
                return false, [fname + " problem loading the page"]
            end
        end

        if !@pageHasReloaded

            o.fireEvent("onMouseOut")
            if !waitForIE(NOWAITFORIE)
                return false, [fname + " problem loading the page"]
            end
        end

        return true, []
    end


    # this returns a a text description of the state of a checkbox. 
    def getDescriptionOfState ( state )
        case state 
            when CHECKBOX_CHECKED
                 s = " Checked "
            when CHECKBOX_UNCHECKED
                 s = " Unchecked "
            when CHECKBOX_TOGGLE
                 s = " Toggle "
            else
                 s = " Unknown Checkbox State!! "
            end
        return s  
    end


    # this function checks to see if the specified check box exists on the page
    # returns the value (CHECKBOX_CHECKED or CHECKBOX_UNCHECKED), or nil if it wasnt found
    #    * name      - string  - the name of the check box
    #    * value     - string  - the value of the check box
    #    * formName  - string  - the name of the form to look in 
    #    * frameName - string  - the name of the frame to look in 
    def getCheckBoxState( name , value , formName = "" , frameName = "" )

        fname = getFunctionName()
        log fname + " Starting. Trying to find checkbox: name: #{name.to_s} value:(#{value.to_s}) " if $debuglevel >=0
        container = getObjectContainer( name , formName , frameName )

        thisCheckBox = nil

        # does it exist
        #o = container.all[ name.to_s ]
        # another one of those hacky frame things...
        container.all.each do |box|
            next unless thisCheckBox == nil
            begin
                if box.name == name.to_s and thisCheckBox== nil
                    # do we have a value as well?
                    if value != ""
                        if box.value == value
                            thisCheckBox = box
                        end
                    else
                        thisCheckBox = box
                    end
                end
            rescue
                # probably doesnt have a name
            end
        end

        return false if thisCheckBox== nil

        return CHECKBOX_CHECKED if thisCheckBox.checked == true
        return CHECKBOX_UNCHECKED if thisCheckBox.checked == false

        return nil

    end




    # this function checks to see if the specified check box exists on the page
    # returns true or false if it found it
    #    * name      - string  - the name of the check box
    #    * value     - string  - the value of the check box
    #    * formName  - string  - the name of the form to look in 
    #    * frameName - string  - the name of the frame to look in 
    def doesCheckBoxExist( name , value , formName = "" , frameName = "" )

        fname = getFunctionName()
        log fname + " Starting. Trying to find checkbox: name: #{name.to_s} value:(#{value.to_s}) " if $debuglevel >=0
        container = getObjectContainer( name , formName , frameName )

        thisCheckBox = nil

        # does it exist
        #o = container.all[ name.to_s ]
        # another one of those hacky frame things...
        container.all.each do |box|
            next unless thisCheckBox == nil
            begin
                if box.name == name.to_s and thisCheckBox== nil
                    # do we have a value as well?
                    if value != ""
                        if box.value == value
                            thisCheckBox = box
                        end
                    else
                        thisCheckBox = box
                    end
                end
            rescue
                # probably doesnt have a name
            end
        end

        return false if thisCheckBox== nil
        return true

    end



    # this sets a checkbox to the specified state
    #  * name        name of the checkbox group
    #  * value       value of the checkbox to set
    #  * newstate    the state to set it to
    #  * formName    name of the for to use
    #  * frameName   the frame to use
    def setCheckBox ( name , value , newState ,  formName = "" , frameName = "" )

        fname = getFunctionName()
        log fname + " Starting. Trying to set checkbox: #{name.to_s} (#{value.to_s}) to " + getDescriptionOfState(newState )if $debuglevel >=0
        container = getObjectContainer( name , formName , frameName )

        thisCheckBox = nil

        # does it exist
        #o = container.all[ name.to_s ]
        # another one of those hacky frame things...
        container.all.each do |box|
            next unless thisCheckBox == nil
            begin
                if box.name == name.to_s and thisCheckBox== nil
                    # do we have a value as well?
                    if value != ""
                        if box.value == value
                            thisCheckBox = box
                        end
                    else
                        thisCheckBox = box
                    end
                end
            rescue
                # probably doesnt have a name
            end

        end

        if thisCheckBox== nil
            return false, [ OBJECTNOTFOUND ]
        end
        setBackGround(thisCheckBox)

        # we now have a reference to the checkbox we want!

        if thisCheckBox.disabled
            clearBackground
            return false, [ OBJECTDISABLED ] 
        end 

        if thisCheckBox.checked == true
            currentState = CHECKBOX_CHECKED
            toggleState = false
        else
            currentState = CHECKBOX_UNCHECKED
            toggleState = true
        end
        state = getDescriptionOfState(currentState)
        log fname + " Found Checkbox #{name.to_s} (#{value.to_s}). Its Current value is: " + state + " Setting to: " + getDescriptionOfState(newState )if $debuglevel >=0

        # now set the new state
        
        case newState 
            when CHECKBOX_CHECKED
                if currentState == CHECKBOX_CHECKED
                    # we dont need to do anything!
                else
                   a, messages = setCheckBoxState( thisCheckBox , true )
                   if !a
                       clearBackground
                       return false, [ fname + " Problem setting checkbox (1)"]
                   end
                end 
             when CHECKBOX_UNCHECKED
                if currentState == CHECKBOX_CHECKED
                   a, messages = setCheckBoxState( thisCheckBox , false )
                   if !a 
                       clearBackground
                       return false, [ fname + " Problem setting checkbox (2)"]
                   end
                else
                    # we dont need to do anything
                end 
             when CHECKBOX_TOGGLE
                  a, messages = setCheckBoxState( thisCheckBox , toggleState  )
                  if !a
                      clearBackground
                      return false, [ fname + " Problem setting checkbox (3)" ]
                  end
        end
        clearBackground
        return true, [ "" ]

    end
    alias setCheckbox setCheckBox 


    # ---------------  Text Functions -------------


    # this returns a string containing the text of the specified frame
    #  * frameName   the frame to use
    def getFrameText( frameName = "" )

        container = getObjectFrameReference( "" , frameName )
        t = container.body.innerText
        return t
    end

    # this returns a string containing the text of the specified frame
    #  * frameName   the frame to use
    def getFrameHTML( frameName = "" )

        container = getObjectFrameReference( "" , frameName )
        t = container.body.innerHTML
        return t
    end

    # This returns the title of the page, or nill if it isnt available
    def getPageTitle(frameName = "" )
        container = getObjectFrameReference( "" , frameName )
        begin
            t = container.title
        rescue
            t = nil
        end
        return t
       
    end

    # this returns true if the specifed frame contains the specified text
    #  * text        the text to look for on the page
    #  * frameName   the frame to use
    #  * showResult  do we put the result into the log
    def pageContainsText( text , frameName = "" , showResult = true)

        container = getObjectFrameReference( text , frameName )
        retryCount = 0
        begin 
             t = container.body.innerText 
             #puts t
        rescue => e
            # we sometimes get exceptions here... My guess is its something to do with load times.
            retryCount = retryCount +1
            if retryCount < 2
                log showException(e)
                sleep 0.5
                retry
            end
        end
        #log "\n------------------ #{frameName} ------------------\n"
        #log t
        #log "\n-----------------------------------------------\n"

        if ( t =~ /#{text}/ ) != nil
            log "pageContainsText: Looking for: #{text} - found it ok" unless showResult == false if $debuglevel >=0
            return true
        else
            log "pageContainsText: Looking for: #{text} - Didnt Find it" unless showResult == false
            return false
        end
    end


end #class


# this class is used to hold the size and position of the IE window
# it is used by the setWindowPosition of the IEController
class IEWindowPosition

    # The height of the window
    attr_accessor :myHeight 

    # The width of the window
    attr_accessor :myWidth 

    # The top of the window
    attr_accessor :myTop

    # The left edge of the window
    attr_accessor :myLeft 


    # create an instance of this object
    #  * myHeight   - int - the height of the window in pixels
    #  * myWidth    - int - the width of the window in pixels
    #  * myTop      - int - the top position of the window in pixels
    #  * myleft     - int - the left position of the window in pixels
    def initialize(  myHeight, myWidth, myTop,myLeft)
        @myHeight = myHeight
        @myWidth = myWidth
        @myTop = myTop
        @myLeft = myLeft
        #puts " left = #{@myLeft} top =#{@myTop}"

    end
end

#  This is WATIR the web application testing framework for ruby
#  Home page is http://rubyforge.com/projects/wtr
#
#  Version "$Revision$"
#
#  Typical usage:
#  # include the controller
#  require 'watir'
#  # create an instance of the controller
#  ie = IE.new()
#  # goto the page you want to test
#  ie.goto("http://myserver/mypage")
#  # to enter text into a text field - assuming the field is name "username"
#  ie.textField(:name, "username").set("Paul")
#  # if there was a text field that had an id of "company_ID", you could set it to Ruby Co by:
#  ie.textField(:id ,"company_ID").set("Ruby Co")
#  # to click a button that has a caption of 'Cancel'
#  ie.button(:caption, "Cancel").click()
#
#  The ways that are available to identify an html object depend upoon the object type.
#  :id         used for an object that has an ID attribute 
#  :name       used for an object that has a name attribute
#  :caption    used for finding buttons
#  :index      finds the object of a certain type at the index - eg button(:index , 2) finds the second button. This is 1 based

require 'win32ole'
require 'logger'


# this class is the simple WATIR logger. Any other logger can be used, however it must provide these methods
class WatirLogger < Logger


    def initialize(  filName , logsToKeep, maxLogSize )

        super( filName , logsToKeep, maxLogSize )
        #@log = Logger.new( fileName ,5, 1024 * 1024)
        self.level = Logger::DEBUG
        self.datetime_format = "%d-%b-%Y %H:%M:%S"
        self.debug("Watir starting")
    end

      
    alias log info
      
end


# This class is used to display the spinner that appears when a page is being loaded
class Spinner

    def initialize
       @s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
       @i=0
    end

    # reverse the direction of spinning
    def reverse
        @s.reverse
    end
    # get the nextr character to display
    def next
        @i=@i+1
        @i=0 if @i>@s.length-1
        return @s[@i]
    end
end

# Root class for all Watir Exceptions
class WatirException < RuntimeError  
    def initialize()
    end
end

# This exception is thrown if an attempt is made to access an object that doesnt exist
class UnknownObjectException < WatirException
    def initialize(message="")
    end
end

# this exception is thrown if an attempt is made to access a property that either does not exist or has not been found
class UnknownPropertyException < WatirException
    def initialize()
    end
end

# this exception is thrown if an attempt is made to access an object that is in a disabled state
class ObjectDisabledException   < WatirException
    def initialize(message="")
    end
end

# This exception is thrown if an attempt is made to access a frame that cannot be found 
class UnknownFrameException< WatirException
    def initialize()
    end
end

# This exception is thrown if an attempt is made to access a form that cannot be found 
class UnknownFormException< WatirException
    def initialize()
    end
end

# this exception is thrown if an attempt is made to access an object that is in a read only state
class ObjectReadOnlyException  < WatirException
    def initialize()
    end
end

# this exception is thrown if an attempt is made to access an object when the specified value cannot be found
class NoValueFoundException < WatirException
    def initialize()
    end
end

# this exception gets raised if part of finding an object is missing
class MissingWayOfFindingObjectException < WatirException
    def initialize()
    end
end
# this exception is raised if an attempt is made to access a table that doesnt exist
class UnknownTableException < WatirException
    def initialize()
    end
end

# This class is the base class for most actions ( click etc ) that happen on an object
# this is not a class that uses would normally access. 
class ObjectActions

    # creates an instance of this class.
    # The initialize method creates several default properties for the object.
    # these properties are accessed using the setProperty and getProperty methods
    #   o  - the object - normally found using
    def initialize( o )
        @o = o
            @defaultProperties = { 
                "type"   =>  "type" ,
                "id"     =>  "id" ,
                "name"   => "name",
                "value"  => "value"  ,
                "disabled" => "disabled"
            }
        @ieProperties = Hash.new
        setProperties(@defaultProperties)
        @originalColor = nil
    end

    # this method sets the  properties for the object
    def setProperties(propertyHash )
        if @o 
            propertyHash.each_pair do |a,b|
                begin
                    setProperty(a , @o.invoke("#{b}" ) )
                rescue
                   # object probably doesnt support this item
                end 
            end
        end  #if @o
    end

    # this method is used to set a property
    #   * name  - string - the name of the property to set
    #   * val   - string - the value to set
    def setProperty(name , val)
        @ieProperties[name] = val
    end

    # this method retreives the value of the specified property
    #   * name  - string - the name of the property to get
    def getProperty(name)
        raise UnknownPropertyException("Unable to locate property, #{name}") if !@ieProperties.has_key?(name)
        return @ieProperties[name]
    end

    def getOLEObject()
        return @o
    end

    # this method displays basic details about the object. Sample output for a button is shown
    # raises UnknownObjectException  if the object is not found
    #      name        b4
    #      type        button
    #      id          b5
    #      value       Disabled Button
    #      disabled    true
    def to_s
        raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
        n = []
        @ieProperties.each_pair do |k,v|        
             n << "#{k}".ljust(18) + "#{v}"
        end
        return n
    end

    # this method is responsible for setting and clearing the highlight on the currently active element
    # use :set    to set the highlight
    #     :clear  to clear the highlight
    def highLight( setOrClear )
        if setOrClear == :set
            begin
                @originalColor = @o.style.backgroundColor
                @o.style.backgroundColor = @ieController.activeObjectHighLightColor
            rescue
                @originalColor = nil
            end
        else
            begin 
                @o.style.backgroundColor  = @originalColor unless @originalColor == nil
                @originalColor = nil
            rescue
                # we could be here for a number of reasons...
            ensure
                @originalColor = nil
            end
        end
    end

    # this method clicks the active element
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def click()
        raise UnknownObjectException ,"Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
        raise ObjectDisabledException ,"object #{@how.to_s} and #{@what.to_s} is disabled"   if !self.enabled?

        highLight(:set)
        @o.click()
        @ieController.waitForIE()
        highLight(:clear)
    end



    def flash
        raise UnknownObjectException , "Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
        10.times do
            highLight(:set)
            sleep 0.05
            highLight(:clear)
            sleep 0.05
        end
    end

    # this methods gives focus to the active element
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def focus()
        raise UnknownObjectException("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
        raise ObjectDisabledException("Object #{@how.to_s} #{@what.to_s} is disabled ")   if !self.enabled?
        @o.focus()
    end

    # this methods checks to see if the current element actually exists 
    def exists?
        return false if @o == nil
        return true
    end

    # this method returns true if the current element is enable, false if it isnt
    #   raises: UnknownObjectException  if the object is not found
    def enabled?
        raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
        return false if @o.invoke("disabled")
        return true
    end

end

# ARGV need to be deleted to enable the Test::Unit functionatily that grabs
# the remaining ARGV as a filter on what tests to run
$HIDE_IE = ARGV.include?('-b'); ARGV.delete('-b')

# This class is the main Internet Explorer Controller
# An instance of this should be created to access IE
class IE

    # Used internaly to determine when IE has finished loading a page
    READYSTATE_COMPLETE = 4          

    # the default delay when typing 
    DEFAULT_TYPING_SPEED = 0.08

    # the default time we wait after a page has loaded
    DEFAULT_SLEEP_TIME = 0.1

    # the default color for highlighting objects
    DEFAULT_HIGHLIGHT_COLOR = "yellow"

    # this is used to change the speed that typing goes at
    attr_accessor :typingspeed

    # this is used to change how long after a page has finished loading that we wait for.
    attr_accessor :defaultSleepTime

    # the color we want to use for the active object. This can be any valid html color
    attr_accessor :activeObjectHighLightColor

    # this method creates an instance of the IE controller
    def initialize( logger=nil )
        @logger = logger
        @ie =   WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = ! $HIDE_IE
        @frame = ""
        @presetFrame = ""
        @form = nil
        @typingspeed = DEFAULT_TYPING_SPEED
        @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
        @defaultSleepTime = DEFAULT_SLEEP_TIME
    end

    def log ( what )

        @logger.debug( what ) if @logger
        puts what
    end

    # This method returns the internet explorer object, so that methods, properties etc that the IEController does not support can be accessedcan be 
    def getIE()
        return @ie
    end

    # This method sets the frame to use for a single object access
    #   *   frameName  - string with the name of the frame to use
    def frame( frameName)
        @frame  = frameName
        return self
    end

    # this method is used internally to clear the name of the frame to use
    def clearFrame()
        @frame = ""
    end

    # This method is used to set the frame to use for multiple object actions
    #   *   frameName  - string with the name of the frame to use
    def presetFrame( frameName )
        @presetFrame = frameName
    end

    # This method is used to clear the frame that is used on multiple object accesses
    def clearPresetFrame( )
        @presetFrame = ""
    end

    # This method returns the name of the currently used frame. Only applies when presetFrame method is used
    def getCurrentFrame()
        return @presetFrame 
    end


    def form( how , formName=nil )
        # if only one value is supplied, its a form name
        if formName == nil
            formName = how
            formHow = :name
        else
            formName = formName
            formHow = how
        end
        log "form how is #{formHow} name is #{formName}"        
        return Form.new(self, formHow, formName)        
    end


    # This method is used internally to set the document to use.
    #  Raises UnknownFrameException if a specified frame cannot be found
    def getDocument()
        if @frame == "" and @presetFrame == ""

            doc = @ie.document
        else
            if @frame == "" 
                # using a preset frame
                frameToUse = @presetFrame
            else
                frameToUse = @frame
            end

            log "Getting a document in a frame - frameName is: #{frameToUse} "

            allFrames = @ie.document.frames
            frameExists = false

            for i in 0 .. allFrames.length-1
                begin
                    frameExists = true   if frameToUse  == allFrames[i.to_s].name.to_s
                rescue
                    # probably no name on this object
                end
            end

            raise UnknownFrameException if frameExists == false
            doc = @ie.document.frames[frameToUse.to_s].document
        end
        @doc = doc
        return doc
    end

    # this method returns true or false if the specified text was found
    #  * text - string or regular expression - the string to look for
    def pageContainsText(text)
        #log "-------------"
        #log getDocument().body.innerText
        #log "-------------"

        retryCount = 0
        begin
            retryCount += 1
            if text.kind_of? Regexp

                if ( getDocument().body.innerText.match(text)  ) != nil
                    log  "pageContainsText: Looking for: #{text} (regexp) - found it ok" 
                    return true
                else
                    log "pageContainsText: Looking for: #{text} (regexp)  - Didnt Find it" 
                    return false
                end

            elsif text.kind_of? String

                if ( getDocument().body.innerText.index(text)  ) != nil
                    log "pageContainsText: Looking for: #{text} (string) - found it ok" 
                    return true
                else
                    log  "pageContainsText: Looking for: #{text} (string)  - Didnt Find it" 
                    return false
                end

            end 
        rescue
            retry if retryCount < 2 
        end
    end

    # This method is used internally to cause execution to stop until the page has loaded in Internet Explorer
    def waitForIE( noSleep  = false )
         
        pageLoadStart = Time.now
        @pageHasReloaded= false

        #puts "waitForIE: busy" + @ie.busy.to_s
        s= Spinner.new
        while @ie.busy
            @pageHasReloaded = true
            sleep 0.02
            print  s.next
        end
        s.reverse

        #puts "waitForIE: readystate=" + @ie.readyState.to_s 
        until @ie.readyState == READYSTATE_COMPLETE
            @pageHasReloaded = true
            sleep 0.02
            print s.next
        end

        if @ie.document.frames.length > 0 
            begin
                0.upto @ie.document.frames.length-1 do |i|
                    until @ie.document.frames[i.to_s].document.readyState == "complete"
                        sleep 0.02
                        print s.next
                    end
                end
             rescue

             end
        else
            until @ie.document.readyState == "complete"
                sleep 0.02
                print s.next
            end
        end
        print "\b"
        #puts "waitForIE Complete"
        s=nil
        sleep 0.01
        sleep @defaultSleepTime unless noSleep  == true
    end

    def wait
        waitForIE
    end

    # this method causes Internet Explorer to navigate to the specified url
    #  * url  - string - the URL to navigate to
    def goto( url )
        @ie.navigate(url)
        waitForIE()
        sleep 0.2
    end

    def close
        @ie.quit
    end

    # this method is used to display the available frames that Internet Explorer currently has loaded.
    # really only used for debugging
    def showFrames()
        if @ie.document.frames
            allFrames = @ie.document.frames
            for i in allFrames.length-1..0
                begin
                    fname = allFrames[i.to_s].name.to_s
                    log "frame  index: #{i} name: #{fname}"
                rescue

                end
            end
        else
            log "no frames"
        end
    end

    # show all forms, shows us all the forms we have
    def showForms()
        if @ie.document.forms
            allForms = @ie.document.forms
            log "There are #{allForms.length} forms"
            for i in 0..allForms.length-1
                begin
                    log "Form name: #{allForms[i.to_s].invoke("name").to_s}"
                    log "       id: #{allForms[i.to_s].invoke("id").to_s}"
                    log "   method: #{allForms[i.to_s].invoke("method").to_s}"
                    log "   action: #{allForms[i.to_s].invoke("action").to_s}"

                rescue
                    log "Form caused an exception!"
                end
            end
        else
            log " No forms"
        end

    end


    def showImages()
        doc = getDocument()
        doc.images.each do |l|
            log "image: name: #{l.name}"
            log "         id: #{l.invoke("id")}"
            log "        src: #{l.src}"
        end

    end


    def showLinks()
        doc = getDocument()
        doc.links.each do |l|
            log "Link: name: #{l.name}"
            log "        id: #{l.invoke("id")}"
            log "      href: #{l.href}"
            log "      text: #{l.innerText}"
        end

    end

    def getHTML()
        return getDocument().body.innerHTML
    end

    def getText()
        return getDocument().body.innerText
    end


    # this method shows the available objects on the current page
    # really only used for debugging
    def showAllObjects()
        log "-----------Objects in  page -------------" 
        doc = getDocument()
        s = ""
        props=["name" ,"id" , "value"]
        doc.all.each do |n|
            begin
                s=s+n.invoke("type").to_s.ljust(16)
            rescue
                next
            end
            props.each do |prop|
                begin
                    p = n.invoke(prop)
                    s =s+ "  " + "#{prop}=#{p}".to_s.ljust(12)
                rescue
                    # this object probably doesnt have this property
                end
            end
            s=s+"\n"
        end
        log s+"\n\n\n"

    end




    def getImage( how, what )
        doc = getDocument()

        log"Finding an image how: #{how} What #{what}"

        images = doc.images
        o=nil
        images.each do |img|

            log "Image on page: src = #{img.src}"

            next unless o == nil
      

            case how
                when :src
                    if what.kind_of? String
                        if img.src == what
                            o = img
                        end
                    elsif what.kind_of? Regexp
                        if img.src.match(what) != nil
                            o = img
                        end
                    end
                when :name
                    if what.kind_of? String
                        if img.name == what
                            o = img
                        end
                    elsif what.kind_of? Regexp
                        if img.name.match(what) != nil
                            o = img
                        end
                    end
                when :id
                    if what.kind_of? String
                        if img.invoke("id") == what
                            o = img
                        end
                    elsif what.kind_of? Regexp
                        if img.invoke("id").match(what) != nil
                            o = img
                        end
                    end

                when :alt
                    if what.kind_of? String
                        if img.invoke("alt") == what
                            o = img
                        end
                    elsif what.kind_of? Regexp
                        if img.invoke("alt").match(what) != nil
                            o = img
                        end
                    end



                when :index

            end
        end
        return o
    end


    def getContainer()
      return getDocument.body.all
    end


    # this method is used to get a table from the page. :index (1 based)  and :id are supported - :name is not for tables, as it is not part of the dom
    #   * how - symbol - the way we look for the table. Supported values are
    #                  - :id
    #                  - :index
    #   * what  - string the thing we are looking for, ie id or index of the object we are looking for
    def getTable( how, what )
        allTables = getDocument.body.getElementsByTagName("TABLE")
        #log "There are #{ allTables.length } tables"
        table = nil
        tableIndex = 1
        allTables.each do |t|
            next  unless table == nil
            case how
                when :id
                    if t.invoke("id").to_s == what.to_s
                        table = t
                    end

                when :index
                    if tableIndex == what.to_i
                        table = t
                    end
            end
        end
        #puts "table - #{what}, #{how} Not found " if table ==  nil
        return table
    end
  
    # this is the main method for finding objects on a page
    #   * how - symbol - the way we look for the object. Supported values are
    #                  - :name
    #                  - :id
    #                  - :index
    #                  - :value
    #   * what  - string the thing we are looking for, ie the name, or id or index of the object we are looking for
    #   * types - what object types we will look at. Only used when index is specified as the how
    #   * value - used for objects that have one name, but many values, for example radios and checkboxes
    def getObject( how, what , types=nil ,  value=nil )
        container = getContainer()

        if types
            if types.kind_of?(Array)
                elementTypes = types
            else
                elementTypes = [types]
            end
        end

        o = nil

        #log "getting object - how is #{how} what is #{what} types = #{types} value = #{value}"

        if how == :index
            o = getObjectAtIndex( container, what , types , value)
        elsif how == :caption || how == :value # only applies to button
            o = getObjectWithValue( what, container , "submit" , "button" )
        else
            #log "How is #{how}"
            container.each do |object|
                next  unless o == nil
                case how
                    when :id
                        begin
                            if object.invoke("id") == what
                                if types

                                    if elementTypes.include?(object.invoke("type"))
                                        if value
                                            #log "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                            if object.value.to_s == value.to_s
                                                o = object
                                            end
                                        else
                                            o= object
                                        end
                                    end
                                else
                                     o= object
                                end
                            end
                       rescue => e
                           #log e.to_s + "\n" + e.backtrace.join("\n")
                       end
                    when :name
                        begin
                            #log "Comparing #{object.invoke("name")} with #{what}"
                            if object.invoke("name") == what
                                if types
                                    #log "Supplied objects is : " + elementTypes.join( " ")
                                    if elementTypes.include?(object.invoke("type"))
                                        if value
                                            #log "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                            if object.value.to_s == value.to_s
                                                o = object
                                            end
                                        else
                                            o= object
                                        end
                                    end
                                else
                                     o= object
                                end
                            end
                       rescue => e
                           #log e.to_s + "\n" + e.backtrace.join("\n")
                       end
                    end
            end
        end

        # if a value has been supplied, for example with a check box or a radio button, we need to go through the collection and get the correct one
        if value
            begin 
                n.each do |thisObject|
                    if thisObject.value == value.to_s and o ==nil
                        o = thisObject
                    end 
                end
            rescue
                # probably no value on this object
            end
        end

        #reset the frame reference
        clearFrame()
        return o
    end

    # This method is used internally to locate an object that has a value specified.
    # normally used for buttons with a caption
    #   * what              - what we are looking for - normally the caption of a button
    #   * container         - the container that we are searching in ( a form or the body of a document )
    #   * *htmlObjectTypes  - an array of the objects we are interested in
    def getObjectWithValue(what , container , *htmlObjectTypes )

        o = nil
        container.each do |r|
            next unless o ==nil
            begin
                if r.value == what and htmlObjectTypes.include?(r.invoke("type").downcase)
                    o = r
                end
            rescue
                # may not have a value...
            end 
        end
        return o

    end

    # this method is used to locate an object when indexes are used. 
    # used internally.
    #    * container  - the container we are looking in
    #    * index      - the index of the element we want to get - 1 based
    #    * types      - an array of the type of objects to look at
    #    * value      - the value of the object to get, used when getting itens like checkboxes and radios
    def getObjectAtIndex(container , index , types , value=nil)

        #log" getting object #{types.to_s}  at index( #{index}"

        o = nil
        objectIndex = 1
        container.each do | thisObject |
            begin

                if types.include?( thisObject.invoke("type") )
                    begin 
                        oName = thisObject.invoke("name")
                    rescue
                        oName = "unknown"
                    end
                    #log "checking object type is #{ thisObject.invoke("type") } name is #{oName} current index is #{objectIndex}  "

                    if objectIndex.to_s == index.to_s
                        o = thisObject
                        if value
                            if value == thisObject.value
                                break
                            end
                        else
                            break
                        end

                    end
                    objectIndex +=1
                end
            rescue
                # probably doesnt support type
            end
        end
        return o
    end

    # this method gets a link from the document
    #    * how  - symbol - how we get the link Supported types are:
    #                      :index - the link at position x , 1 based
    #                      :url   - get the link that has a url that matches. A regular expression match is performed
    #                      :text  - get link based on the supplied text. uses either a string or regular expression match
    #    * what - depends on how - an integer for index, a string or RE for url and text
    def getLink( how, what )
        doc = getDocument()
        links = doc.links

        link = nil

        case how

            when :index
                begin
                    link = links[ (what-1).to_s ]
                rescue
                    link=nil
                end
            when :url
                links.each do |thisLink|
                    if thisLink.href.match(Regexp.escape(what)) 
                        link = thisLink if link == nil
                    end
                end

            when :text
                links.each do |thisLink|
                    if what.kind_of?( String )
                        if thisLink.innerText==what 
                            link = thisLink if link == nil
                        end
                    elsif what.kind_of?( Regexp)
                        if what.innerText.match( thisLink )
                            link = thisLink if link == nil
                        end
                    end
                end
            else
                log "unknown way of finding a link...."
        end
        #reset the frame reference
        clearFrame()

        return link

    end

    # this is the main method for acessing a table
    def table( how, what )
        t = Table.new( self , how, what)
        return t
    end

    # this is the main method for accessing a button.
    #  *  how   - symbol - how we access the button , :index, :caption, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    # returns a Button object
    def button( how , what=nil  )
        if how.kind_of? Symbol
            raise MissingWayOfFindingObjectException if what==nil
            b = Button.new(self, how , what )
        elsif how.kind_of? String
            log "how is a string - #{how}"
            b = Button.new(self, :caption, how)
       end
    end

    # this is the main method for accessing a text field.
    #  *  how   - symbol - how we access the field , :index, :id, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    # returns a TextFieldobject
    def textField( how , what )
        t = TextField.new(self , how, what)
    end

    # this is the main method for accessing a select box.
    #  *  how   - symbol - how we access the select box , :index, :id, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    # returns a SelectBox object
    def selectBox( how , what )
        s = SelectBox.new(self , how, what)
    end

    # this is the main method for accessing a check box.
    #  *  how   - symbol - how we access the check box , :index, :id, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
    # returns a CheckBox object
    def checkBox( how , what , value=nil)
        c = CheckBox.new( self, how, what , value)
    end

    # this is the main method for accessing a radio button.
    #  *  how   - symbol - how we access the radio button, :index, :id, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
    # returns a RadioButton object
    def radio( how , what , value=nil)
        r = RadioButton.new( self, how, what , value)
    end

    # this is the main method for accessing a link.
    #  *  how   - symbol - how we access the link, :index, :id, :name etc
    #  *  what  - string, int or re , what we are looking for, 
    # returns a Link object
    def link( how , what)
        l = Link.new(self , how, what )
    end

    # this is the main method for accessing images
    #  *  how   - symbol - how we access the image, :index, :id, :name , :src
    #  *  what  - string, int or re , what we are looking for, 
    # returns an Image object
    def image( how , what)
        i = Image.new(self , how, what )
    end

   
end # class IE

# Form object 
#   * ieController  - an instance of an IEController
#   * how           - symbol - how we access the form (:name, :index, :action, :method)
#   * what          - what we use to access the form
class Form < IE
    def initialize( ieController, how, what )
        @ieController = ieController
        @formHow = how
        @formName = what
        @form = getForm()

        @typingspeed = ieController.typingspeed        
        @activeObjectHighLightColor = ieController.activeObjectHighLightColor       
    end

    def waitForIE
        @ieController.waitForIE
    end

    def getContainer()
        raise UnknownFormException if @form == nil
        @form.elements.all
    end    


    def exists?
        @form ? true : false
    end

    # Submit the data -- equivalent to pressing return
    def submit()
        raise UnknownFormException if @form == nil
        @form.submit 
        @ieController.waitForIE
    end   

    # Find the specified form  
    def getForm()
        log "Get form  formHow is #{@formHow}  formName is #{@formName} "
        count = 1
        doc = @ieController.getDocument()
        doc.forms.each do |thisForm|
        #0.upto(doc.forms.length -1 ) do |i|
            #thisForm = doc.forms[i.to_s]
            next unless @form == nil
            log "form on page, name is " + thisForm.invoke("name").to_s
            begin
                log "its a collection of forms - length is: " + thisForm.invoke("name").length.to_s
            rescue
                log "not a collection of forms"
            end

            case @formHow
                when :name 
                    
                    if thisForm.name == @formName
                        @form = thisForm
                    end
                when :id
                    
                    if thisForm.invoke("id").to_s == @formName.to_s
                        @form = thisForm
                    end

                when :index
                    if count == @formName.to_i
                        @form = thisForm
                    end

                when :method
                    if thisForm.invoke("method").downcase == @formName.downcase
                        @form = thisForm
                    end

                when :action
                   if @formName.kind_of? String
                        if thisForm.action == @formName
                             @form = thisForm
                        end
                   elsif 
                        if thisForm.action.match( @formName ) != nil
                             @form = thisForm
                        end
                   end
           end
           count = count +1
        end
        if @form == nil
            log "No form found!"
        else      
            log "set @form "   #to form with name #{@form.name}"
        end
        return @form
    end
  
end # class Form

# this class is used for dealing with tables
# it would not normally be used by users, as the table method of IEController would returned an initialised instance of a table
class Table < ObjectActions

    # returns an initialized instance of a table object
    #   * ieController  - an instance of an IEController
    #   * how           - symbol - how we access the table
    #   * what          - what we use to access the table - id, name index etc 
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getTable( how, what )
        super( @o )
        @how = how
        @what = what
    end


    # this method returns the number of rows in the table
    # raises an UnknownTableException if the table doesnt exist
    def rows
        raise UnknownTableException if @o == nil
        table_rows = @o.getElementsByTagName("TR")
        return table_rows.length
    end

    # this method returns the number of cols in the table
    # raises an UnknownTableException if the table doesnt exist
    def columns( rowToUse = 1)

        raise UnknownTableException if @o == nil
        table_rows = @o.getElementsByTagName("TR")
        cols = table_rows[rowToUse.to_s].getElementsByTagName("TD")
        return cols.length

    end

    # this method returns the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc
    # raises an UnknownTableException if the table doesnt exist
    def to_a
        raise UnknownTableException if @o == nil
        y = []
        table_rows = @o.getElementsByTagName("TR")
        for row in table_rows
          x = []
          for td in row.getElementsbyTagName("TD")
            x << td.innerText.strip
          end
          y << x
        end
        return y

    end

end



# this class is the means of accessing an image on a page
# it would not normally be used by users, as the image method of IEController would return an initialised instance of an image
class Image < ObjectActions

    # returns an initialized instance of a image  object
    #   * ieController  - an instance of an IEController
    #   * how           - symbol - how we access the image
    #   * what          - what we use to access the image, text, url, index etc
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getImage( how, what )
        super( @o )
        @how = how
        @what = what
        property = {
            "src"             =>  "src" ,
            "fileCreatedDate" => "fileCreatedDate" ,
            "fileSize"        => "fileSize" ,
            "width"           => "width" ,
            "height"          => "height"
        }
        setProperties(property )

    end


    def hasLoaded?
        raise UnknownObjectException if @o==nil
        return false  if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
        return true
    end


end


# this class is the means of accessing a link on a page
# it would not normally be used bt users, as the link method of IEController would returned an initialised instance of a link
class Link < ObjectActions
    # returns an initialized instance of a link object
    #   * ieController  - an instance of an IEController
    #   * how           - symbol - how we access the link
    #   * what          - what we use to access the link, text, url, index etc
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getLink( how, what )
        super( @o )
        @how = how
        @what = what
    end
end


# This class is the way in which select boxes are manipulated.
# it would not normally be created by a user, as it is returned by the selectBox method of IEController
class SelectBox < ObjectActions
    # returns an initialized instance of a SelectBox object
    #   * ieController  - an instance of an IEController
    #   * how           - symbol - how we access the select box
    #   * what          - what we use to access the select box, name, id etc
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what , ["select-one","select-multiple"] )
        super( @o )
        @how = how
        @what = what
    end

    # this method clears the selected items in the select box
    def clearSelection
        raise UnknownObjectException if @o==nil
        highLight( :set)
        @o.each do |selectBoxItem|
            selectBoxItem.selected = false
            @ieController.waitForIE()
        end
        highLight( :clear)
    end

    # this method selects an item, or items in a select box.
    # raises NoValueFoundException   if the specified value is not found
    #  * item   - the thing to select, string, reg exp or an array of string and reg exps

    def select( item )
        raise UnknownObjectException if @o==nil
        if item.kind_of?( Array )== false
            items = [item ]
        else
            items = item 
        end

        matchedAnItem = false
        highLight( :set)
        items.each do |thisItem|

            @ieController.log "Setting box #{@o.name} to #{thisItem} #{thisItem.class} "

            matchedAnItem = false
            if thisItem.kind_of?( Regexp )
                @o.each do |selectBoxItem|
                    if thisItem.match( selectBoxItem.text)
                        matchedAnItem = true
                        if selectBoxItem.selected == true
                            @ieController.log " #{selectBoxItem.text} is already selected"
                            doBreak = true
                        else
                            @ieController.log " #{selectBoxItem.text} is being selected"
                            selectBoxItem.selected = true
                            @o.fireEvent("onChange")
                            doBreak = true
                        end
                        @ieController.waitForIE()
                        break if doBreak
                    end
                end

            elsif thisItem.kind_of?( String )
                @o.each do |selectBoxItem|
                    @ieController.log " comparing #{thisItem } to #{selectBoxItem.text}"
                    if thisItem == selectBoxItem.text 
                        matchedAnItem = true
                        if selectBoxItem.selected == true
                            @ieController.log " #{selectBoxItem.text} is already selected"
                        else
                            @ieController.log " #{selectBoxItem.text} is being selected"
                            selectBoxItem.selected = true
                            @o.fireEvent("onChange")
                        end
                    end
                end
            end
            raise NoValueFoundException    if matchedAnItem ==false
        end
        highLight( :clear )
    end

    # This method returns all the items in the select list as an array. An empty array is returned if the select box has no contents
    #   raises UnknownObjectException  if the select box is not found
    def getAllContents()
        raise UnknownObjectException if @o==nil
        returnArray = []

        @ieController.log "There are #{@o.length} items"

        @o.each do |thisItem|
            returnArray << thisItem.text
        end
        return returnArray 

    end

    # This method returns all the selected items from the select box as an array
    #   raises UnknownObjectException  if the select box is not found
    def getSelectedItems
        raise UnknownObjectException if @o==nil
        returnArray = []
        @ieController.log "There are #{@o.length} items"
        @o.each do |thisItem|
            if thisItem.selected == true
                @ieController.log "Item ( #{thisItem.text} ) is selected"
                returnArray << thisItem.text 
            end
        end
        return returnArray 
    end
end

# this is the main class for accessing buttons .
# normally a user would not need to create this object as it is returned by the IEController Button method
class Button < ObjectActions
    # create an instance of the button object
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what , ["button" , "submit"] )
        super( @o )
        @how = how
        @what = what
    end
end

# this class is the parent class for radio buttons and check boxes. It contains methods common to both
# It should not be created by users.
class RadioCheckCommon < ObjectActions
    # Constant for setting, or determining if a check box or radio button is set
    CHECKED = true
    # Constant for unsetting, or determining if a check box or radio button is unset
    UNCHECKED = false

    def initialize( o )
        super(o)
    end

   # this method determines if a radio button or check box is set
   # returns true or false
   #   Raises UnknownObjectException  if its unable to locate an object
   def isSet?
        raise UnknownObjectException if @o==nil
        return true if @o.checked
        return false
   end

   # this method clears a radio button or check box  - beware on radios, as one of them will always be set
   # returns true or false
   #   Raises UnknownObjectException  if its unable to locate an object
   #          ObjectDisabledException  IF THE OBJECT IS DISABLED 
   def clear
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        @o.checked = false
        @ieController.waitForIE()
   end

   # this method sets the radio or check box
   #   Raises UnknownObjectException  if its unable to locate an object
   #          ObjectDisabledException  IF THE OBJECT IS DISABLED 
   def set
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        highLight( :set)
        @o.checked = true
        @ieController.waitForIE()
        highLight( :clear )
   end

   # this method gets the state of radio or check box
   # returns CHECKED or UNCHECKED
   #   Raises UnknownObjectException  if its unable to locate an object
   def getState
        raise UnknownObjectException if @o==nil
        return CHECKED if @o.checked == true
        return UNCHECKED 
   end

end

# this class is the main class for radio buttons
# it shouldnt normally be created, as the radio method of IEController will return a ninitialized object
class RadioButton < RadioCheckCommon
   
    def initialize( ieController,  how , what , value=nil )
        @ieController = ieController
        @o = ieController.getObject( how, what , "radio" , value)
        super( @o )
        @how = how
        @what = what
        @value = value
    end
end

# this class is the main class for Check boxes
# it shouldnt normally be created, as the checkBox method of IEController will return a ninitialized object
class CheckBox < RadioCheckCommon

    def initialize( ieController,  how , what , value=nil )
        @ieController = ieController
        @o = ieController.getObject( how, what , "checkbox", value)
        super( @o )
        @how = how
        @what = what
        @value = value
    end

end

# this class is the main class for Text Fields
# it shouldnt normally be created, as the textFiled method of IEController will return a ninitialized object
class TextField < ObjectActions
    
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what , ["text" , "password"] )
        super( @o )
        @how = how
        @what = what
        @properties = {
            "maxLength"  => "maxLength" ,
            "length"  => "length" 
        }
    end

    # this method returns true|false if the text field is read only
    #    Raises  UnknownObjectException if the object cant be found
    def readOnly?
        raise UnknownObjectException if @o==nil
        return @o.readOnly 
    end    

    # this method returns the current contents of the text field as a string
    #    Raises  UnknownObjectException if the object cant be found
    def getContents()
        raise UnknownObjectException if @o==nil
        return self.getProperty("value")
    end

    # This method returns true|false if the text field contents is either a string match or a regular expression match to the supplied value
    #    Raises  UnknownObjectException if the object cant be found
    #    * containsThis - string or reg exp  -  the text to verify 
    def verify_contains( containsThis )
        raise UnknownObjectException if @o==nil

        if containsThis.kind_of? String
            return true if self.getProperty("value") == containsThis
        elsif containsThis.kind_of? Regexp
            return true if self.getProperty("value").match(containsThis) != nil
        end
        return false
    end
  
    # This method clears the contents of the text box
    #    Raises  UnknownObjectException if the object cant be found
    #    Raises  ObjectDisabledException if the object is disabled
    #    Raises  ObjectReadOnlyException if the object is read only
    def clear()
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        raise ObjectReadOnlyException   if self.readOnly?

        highLight(:set)

        @o.scrollIntoView
        @o.focus
        @o.select()
        @o.fireEvent("onSelect")
        @o.value = ""
        @o.fireEvent("onKeyPress")
        @o.fireEvent("onChange")
        @ieController.waitForIE()
        highLight(:clear)

    end

    # This method appens the supplied text to the contents of the text box
    #    Raises  UnknownObjectException if the object cant be found
    #    Raises  ObjectDisabledException if the object is disabled
    #    Raises  ObjectReadOnlyException if the object is read only
    #   * setThis  - string - the text to append
    def append( setThis)
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        raise ObjectReadOnlyException   if self.readOnly?

        highLight(:set)
        @o.scrollIntoView
        @o.focus
        doKeyPress( setThis )
        highLight(:clear)
    end

    # This method sets the contents of the text box to the supplied text 
    #    Raises  UnknownObjectException if the object cant be found
    #    Raises  ObjectDisabledException if the object is disabled
    #    Raises  ObjectReadOnlyException if the object is read only
    #   * setThis  - string - the text to set 
    def set( setThis )
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        raise ObjectReadOnlyException   if self.readOnly?

        highLight(:set)
        @o.scrollIntoView
        @o.focus
        @o.select()
        @o.fireEvent("onSelect")
        @o.value = ""
        @o.fireEvent("onKeyPress")
        doKeyPress( setThis )
        highLight(:clear)
    end

    # this method is used internally by setText and appendText
    # it should not be used externally
    #   * value   - string  - The string to enter into the text field
    def doKeyPress( value )
        begin
            maxLength = @o.maxLength
            if value.length > maxLength
                value = suppliedValue[0 .. maxLength ]
                log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
            end
        rescue
            # its probably a text area - so it doesnt have a max Length
            maxLength = -1
        end

        for i in 0 .. value.length-1   
            sleep @ieController.typingspeed   # typing speed
            c = value[i]
            #log  " adding c.chr " + c.chr.to_s
            @o.value = @o.value.to_s + c.chr
            @o.fireEvent("onKeyPress")
            @ieController.waitForIE(true)
        end
    end
end


#  This is WATIR the web application testing framework for ruby
#  Home page is http://rubyforge.com/projects/wtr
#
#  Version "$Revision$"
#
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
    def initialize()
    end
end

# this exception is thrown if an attempt is made to access a property that either does not exist or has not been found
class UnknownPropertyException < WatirException
    def initialize()
    end
end

# this exception is thrown if an attempt is made to access an object that is in a disabled state
class ObjectDisabledException   < WatirException
    def initialize()
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
        raise UnknownPropertyException if !@ieProperties.has_key?(name)
        return @ieProperties[name]
    end

    # this method displays basic details about the object. Sample output for a button is shown
    # raises UnknownObjectException  if the object is not found
    #      name        b4
    #      type        button
    #      id          b5
    #      value       Disabled Button
    #      disabled    true
    def to_s
        raise UnknownObjectException if @o==nil
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
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        highLight(:set)
        @o.click()
        @ieController.waitForIE()
        highLight(:clear)
    end

    # this methods gives focus to the active element
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def focus()
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
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
        raise UnknownObjectException if @o==nil
        return false if @o.invoke("disabled")
        return true
    end

end



# This class is the main Internet Explorer Controller
# An instance of this should be created to access IE
class IE

    # Used internaly to determine when IE has fiished loading a page
    READYSTATE_COMPLETE = 4          

    # the default delay when typing 
    DEFAULT_TYPING_SPEED = 0.08

    # the default color for highlighting objects
    DEFAULT_HIGHLIGHT_COLOR = "yellow"

    # this is used to change the speed that typing goes at
    attr_accessor :typingspeed

    # the color we want to use for the active object. This can be any valid html color
    attr_accessor :activeObjectHighLightColor

    # this method creates an instance of the IE controller
    def initialize()

#        puts "##########################################################################"
#        puts "#                                                                        #"
#        puts "# This is a new version of WATIR. It is very untested.                   #"
#        puts "# It provides functionality like ie.form("form1").button("Submit").click #"
#        puts "# The existing unit tests work, and new ones are being created for this  #"
#        puts "# functionality. Please report any problems to the wtr mailing list      #"
#        puts "#  Thanks, Paul                                                          #"
#        puts "#                                                                        #"
#        puts "##########################################################################"

        @ie =   WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = TRUE
        @frame = ""
        @presetFrame = ""
        @form = nil
        @typingspeed = DEFAULT_TYPING_SPEED
        @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
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
            @formName = how
            @formHow = :name
            puts "form  how is #{@formHow} name is #{@formName}"

        else
            @formName = formName
            @formHow = how
            puts "form  how is #{@formHow} name is #{@formName}"

        end

        #temp = getDocument()
        return self
    end

    def submit()
        getForm()
        raise UnknownFormException if @form == nil
        @form.submit 
        waitForIE
        clearForm()
    end   
 
    # this applies to a form. - it will be refactored into a Form object eventually
    def exists?
        @doc = getDocument(false)  
        getForm()
        formExists = false
        formExists = true if @form
        clearForm()
        return false if formExists == false
        return true
    end

    def clearForm()
        @formName = nil
        @formHow = nil
        @form = nil
    end

    def getForm()
        puts "Get form  formHow is #{@formHow}  formName is #{@formName} "
        count =1
        @doc.forms.each do |thisForm|
            next unless @form == nil
            puts "form on page, name is " + thisForm.name.to_s
            case @formHow
                when :name
                    if thisForm.name == @formName
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
        puts "set @form "   #to form with name #{@form.name}"
        return @form
    end


    # This method is used internally to set the document to use.
    #  Raises UnknownFrameException if a specified frame cannot be found
    def getDocument(useForm = true)
        #if @formName and useForm
        #    doc = getForm()
        #    puts "Getting a form #{@formName} "
        #elsif @frame == "" and @presetFrame == ""
        if @frame == "" and @presetFrame == ""

            doc = @ie.document
        else
            if @frame == "" 
                # using a preset frame
                frameToUse = @presetFrame
            else
                frameToUse = @frame
            end

            puts "Getting a document in a frame - frameName is: #{frameToUse} "

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
        puts "-------------"
        puts getDocument().body.innerText
        puts "-------------"

        if text.kind_of? Regexp

            if ( getDocument().body.innerText.match(text)  ) != nil
                puts  "pageContainsText: Looking for: #{text} (regexp) - found it ok" 
                return true
            else
                puts "pageContainsText: Looking for: #{text} (regexp)  - Didnt Find it" 
                return false
            end

        elsif text.kind_of? String

            if ( getDocument().body.innerText.index(text)  ) != nil
                puts "pageContainsText: Looking for: #{text} (string) - found it ok" 
                return true
            else
                puts  "pageContainsText: Looking for: #{text} (string)  - Didnt Find it" 
                return false
            end

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
        print "\b"
        #puts "waitForIE Complete"
        s=nil
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
            for i in 0 .. allFrames.length-1
                begin
                    fname = allFrames[i.to_s].name.to_s
                    puts "frame  index: #{i} name: #{fname}"
                rescue

                end
            end
        else
            puts "no frames"
        end
    end

    # this method shows the available objects on the current page
    # really only used for debugging
    def showAllObjects()
        puts "elements in  page:" 
        doc = getDocument()
        doc.all.each do |n|
            begin
                puts n.invoke("type") + "  #{n.name}"
            rescue
                # no name probably
            end
        end
        puts "\n\n\n"

    end




    def getImage( how, what )
        doc = getDocument()

        puts"Finding an image how: #{how} What #{what}"

        images = doc.images
        o=nil
        images.each do |img|

            puts "Image on page: src = #{img.src}"

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

                when :index

            end
        end
        return o
    end




    # this is the main method for finding objects on a page
    #   * how - symbol - the way we look for the object. Supported values are
    #                  - :name
    #                  - :id
    #                  - :index
    #   * what  - string the thing we are looking for, ie the name, or id or index of the object we are looking for
    #   * types - what object types we will look at. Only used when index is specified as the how
    #   * value - used for objects that have one name, but many values, for example radios and checkboxes
    def getObject( how, what , types=nil ,  value=nil )
        doc = getDocument()

        if @form
            container  = @form.elements.all
            puts "getObject - using form #{@form.name} how is #{how} what is #{what}"
        else
            container = doc.body.all
            puts "Container is doc.body.all"
        end
        if types
            if types.kind_of?(Array)
                elementTypes = types
            else
                elementTypes = [types]
            end
        end

        o = nil

        puts "getting object - how is #{how} what is #{what} types = #{types} value = #{value}"

        if how == :index
            o = getObjectAtIndex( container, what , types , value)
        elsif how ==:caption  #only applies to button
            o = getObjectWithValue( what, container , "submit" , "button" )
        else
            #puts "How is #{how}"
            container.each do |object|
                next  unless o == nil
                case how
                    when :id
                        begin
                            if object.invoke("id") == what
                                if types
                                    if types.include?(object.invoke("type"))
                                        if value
                                            puts "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                            if object.value.to_s == value.to_s
                                                o = object
                                            end
                                        else
                                            o= object
                                        end
                                    else
                                        o= object
                                    end
                                else
                                     o= object
                                end
                            end
                       rescue => e
                           #puts e.to_s + "\n" + e.backtrace.join("\n")
                       end
                    when :name
                        begin
                            #puts "Comparing #{object.invoke("name")} with @{what}"
                            if object.invoke("name") == what
                                if types
                                    if types.include?(object.invoke("type"))
                                        if value
                                            puts "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                            if object.value.to_s == value.to_s
                                                o = object
                                            end
                                        else
                                            o= object
                                        end
                                    else
                                        o= object
                                    end
                                else
                                     o= object
                                end
                            end
                       rescue => e
                           #puts e.to_s + "\n" + e.backtrace.join("\n")
                       end
                    end
            end
        end

        # if a value has been supplied, for exampe with a check box or a radio button, we need to go through the collection and get the correct one
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
        clearForm()
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

        #puts" getting object #{types.to_s}  at index( #{index}"

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
                    #puts "checking object type is #{ thisObject.invoke("type") } name is #{oName} current index is #{objectIndex}  "

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
                puts "unknown way of finding a link...."
        end
        #reset the frame reference
        clearFrame()

        return link

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
            puts "how is a string - #{how}"
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

    


end

# this class is the means of accessing an image on a page
# it would not normally be used bt users, as the link method of IEController would returned an initialised instance of a link
class Image < ObjectActions

    # returns an initialized instance of a image  object
    #   * ieController  - an instance of an IEController
    #   * how           - symbol - how we access the image
    #   * what          - what we use to access the image, text, url, index etc
    def initialize( ieController,  how , what )
       @ieController = ieController
       @o = ieController.getImage( how, what )
       super( @o )
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
       @o = ieController.getObject( how, what , "select" )
       super( @o )
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

            puts "Setting box #{@o.name} to #{thisItem} #{thisItem.class} "

            matchedAnItem = false
            if thisItem.kind_of?( Regexp )
                @o.each do |selectBoxItem|
                    if thisItem.match( selectBoxItem.text)
                        matchedAnItem = true
                        selectBoxItem.selected = true
                        puts " #{selectBoxItem.text} is being selected"
                        @ieController.waitForIE()
                    end
                end

            elsif thisItem.kind_of?( String )
                @o.each do |selectBoxItem|
                    puts " comparing #{thisItem } to #{selectBoxItem.text}"
                    if thisItem == selectBoxItem.text 
                        matchedAnItem = true
                        puts " #{selectBoxItem.text} is being selected"
                        selectBoxItem.selected = true     
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

        puts "There are #{@o.length} items"

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
        puts "There are #{@o.length} items"
        @o.each do |thisItem|
            if thisItem.selected == true
                puts "Item ( #{thisItem.text} ) is selected"
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
    end
end

# this class is the main class for Check boxes
# it shouldnt normally be created, as the checkBox method of IEController will return a ninitialized object
class CheckBox < RadioCheckCommon

    def initialize( ieController,  how , what , value=nil )
        @ieController = ieController
        @o = ieController.getObject( how, what , "checkbox", value)
        super( @o )
    end

end

# this class is the main class for Text Fields
# it shouldnt normally be created, as the textFiled method of IEController will return a ninitialized object
class TextField < ObjectActions
    
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what , ["text" , "password"] )
        super( @o )

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
                puts " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
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
            @ieController.waitForIE()
        end
    end
end


require 'win32ole'


#
#  Version "$Revision$"
#

class Spinner

    def initialize
       @s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
       @i=0
    end
    def reverse
        @s.reverse
    end
    def next
        @i=@i+1
        @i=0 if @i>@s.length-1
        return @s[@i]
    end
end


class WatirException < RuntimeError  
    def initialize()

    end
end

class UnknownObjectException < WatirException
    def initialize()

    end
end
class UnknownPropertyException < WatirException
    def initialize()

    end
end

class ObjectDisabledException   < WatirException
    def initialize()

    end
end
 
class UnknownFrameException< WatirException
    def initialize()

    end
end

class UnknownFormException< WatirException
    def initialize()

    end
end

class ObjectReadOnlyException  < WatirException
    def initialize()

    end
end

class NoValueFoundException < WatirException
    def initialize()

    end
end

class ObjectActions

    def initialize( o)
        @o = o
            @defaultProperties = { 
                "type"   =>  "type" ,
                "id"     =>  "id" ,
                "name"   => "name",
                "value"  => "value"  ,
                "disabled" => "disabled"
            }

        @ieProperties = Hash.new
        setProperties
        @originalColor = nil

    end

    def setProperties

        if @o 
            @defaultProperties.each_pair do |a,b|
                begin
                    setProperty(a , @o.invoke("#{b}" ) )
                rescue
                   # object probably doesnt support this item
                end 
            end
        end  #if @o
    end

    def setProperty(name , val)
        @ieProperties[name] = val
    end

    def getProperty(name)
        raise UnknownPropertyException if !@ieProperties.has_key?(name)
        return @ieProperties[name]
    end
    def to_s

        raise UnknownObjectException if @o==nil

        #return nil if @o == nil
        n = []
        @ieProperties.each_pair do |k,v|        
             n << "#{k}".ljust(12) + "#{v}"
        end
        return n
    end

    def highLight( setOrClear )
 
        if setOrClear == :set
            begin
                @originalColor = @o.style.backgroundColor
                @o.style.backgroundColor = @ieController.activeObjectHighLightColor
            rescue
                @originalColor = nil
            end
        else
            @o.style.backgroundColor  = @originalColor unless @originalColor == nil
            @originalColor = nil
        end
    end


    def click()
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        highLight(:set)
        @o.click()
        highLight(:clear)
    end

    def focus()
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        @o.focus()
    end

    def exists?
        return false if @o == nil
        return true
    end

    def enabled?
        raise UnknownObjectException if @o==nil
        return false if @o.invoke("disabled")
        return true
    end


end


class IE

    # Used internaly to determine when IE has fiished loading a page
    READYSTATE_COMPLETE = 4          

    # the default delay when typing 
    DEFUALT_TYPING_SPEED = 0.08

    # the default color for highlighting objects
    DEFAULT_HIGHLIGHT_COLOR = "yellow"

    # this is used to change the speed that typing goues at
    attr_accessor :typingspeed

    # the color we want to use for the active object
    attr_accessor :activeObjectHighLightColor

    def initialize()

        @ie =   WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = TRUE
        @frame = ""
        @form = ""
        @typingspeed = DEFUALT_TYPING_SPEED
        @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
    end

    def getIE()
        return @ie
    end

    def frame( frameName)
        @frame  = frameName
        return self
    end

    


    #def method_missing( method , args )
        #@ie.invoke( :method( args ) )
    #end

    def getDocument()
        if @frame == ""
            doc = @ie.document
        else
            puts "Getting a document in a frame #{@frame} "
            allFrames = @ie.document.frames
            frameExists = false
            for i in 0 .. allFrames.length-1
                begin
                    frameExists = true   if @frame  == allFrames[i.to_s].name.to_s
                rescue
                    # probably no name on this object
                end
            end

            raise UnknownFrameException if frameExists == false
            doc = @ie.document.frames[@frame.to_s].document
        end

        
        return doc
    end

    def pageContainsText(text)


puts "-------------"
puts getDocument.body.innerText

puts "-------------"
         if text.kind_of? Regexp

            if ( getDocument.body.innerText.match(text)  ) != nil
                puts  "pageContainsText: Looking for: #{text} (regexp) - found it ok" 
                return true
            else
                puts "pageContainsText: Looking for: #{text} (regexp)  - Didnt Find it" 
                return false
            end


        elsif text.kind_of? String

            if ( getDocument.body.innerText.index(text)  ) != nil
                puts "pageContainsText: Looking for: #{text} (string) - found it ok" 
                return true
            else
                puts  "pageContainsText: Looking for: #{text} (string)  - Didnt Find it" 
                return false
            end

        end    end

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
        puts "waitForIE Complete"
        s=nil
    end

    def goto( url )
        @ie.navigate(url)
        waitForIE()
        sleep 3
    end

    def showFrames()
        if @ie.document.frames
            allFrames = @ie.document.frames
            for i in 0 .. allFrames.length-1
                begin
                    fname = allFrames[i.to_s].name.to_s
                    puts "frame: #{fname}"
                rescue

                end
            end
        else
            puts "no frames"
        end
    end

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


    def getObject( how, what , value=nil )
        doc = getDocument()

        o = nil
        case how
            when :id
                o = doc.getElementByID(what)
                
            when :name
                begin 
                    #p "getobject by name  #{what}"
                    n = doc.getElementsByName(what)
                    if n.length == 0 
                        o=nil
                        #puts "getElementByName gets nothing!"
                    else
                        #puts "getelement by name returns len = #{n.length}"
                        o=n["0"] if value ==nil
                        #puts "o type is : " + o.invoke("type")
                    end
                rescue => e
                    puts e
                end
            when :caption  #only applies to button
                o = getObjectWithValue( what, doc , "submit" , "button" )
            #when :index
            #  we need to know what type of object
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

            end
        end


        #reset the frame reference
        frame("")
        

        return o
    end

    def getObjectWithValue(what , doc , *htmlObjectTypes )

        o = nil
        doc.all.each do |r|
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

    def button( how , what  )
        b = Button.new(self , how , what )
    end

    def textField( how , what )
        t = TextField.new(self , how, what)
    end

    def selectBox( how , what )
        s = SelectBox.new(self , how, what)
    end

    def checkBox( how , what , value=nil)
        c = CheckBox.new( self, how, what , value)

    end

    def radio( how , what , value=nil)
        r = RadioButton.new( self, how, what , value)
    end


 

end


class SelectBox < ObjectActions

    def initialize( ieController,  how , what )
       @ieController = ieController
       @o = ieController.getObject( how, what )
       super( @o )
    end

    def clearSelection
        raise UnknownObjectException if @o==nil
        highLight( :set)
        @o.each do |selectBoxItem|
            selectBoxItem.selected = false
        end
        highLight( :clear)

    end

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

    def getAllContents()
        raise UnknownObjectException if @o==nil
        returnArray = []

        puts "There are #{@o.length} items"

        @o.each do |thisItem|
            returnArray << thisItem.text
        end
        return returnArray 

    end

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

class Button < ObjectActions
    
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what )
        super( @o )
    end

end

class RadioCheckCommon < ObjectActions

    CHECKED = true
    UNCHECKED = false


    def initialize( o )
        super(o)
    end

   def isSet?
        raise UnknownObjectException if @o==nil
        return true if @o.checked
        return false

   end

   def clear

        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        @o.checked = false

   end

   def set
  
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        highLight( :set)
        @o.checked = true
        highLight( :clear )


   end

   def getState

        raise UnknownObjectException if @o==nil
        return CHECKED if @o.checked == true
        return UNCHECKED 

   end



end


class RadioButton < RadioCheckCommon

   
    def initialize( ieController,  how , what , value=nil )
        @ieController = ieController
        @o = ieController.getObject( how, what , value)
        super( @o )
    end



end

class CheckBox < RadioCheckCommon

    def initialize( ieController,  how , what , value=nil )
        @ieController = ieController
        @o = ieController.getObject( how, what , value)
        super( @o )
    end

end


class TextField < ObjectActions
    
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what )
        super( @o )

        @properties = {
            "maxLength"  => "maxLength" ,
            "length"  => "length" ,


        }

    end


    def readOnly?
        return @o.readOnly 
    end    


    def getContents()
        raise UnknownObjectException if @o==nil
        return self.getProperty("value")

    end

    def verify_contains( containsThis )
        raise UnknownObjectException if @o==nil

        if containsThis.kind_of? String
            return true if self.getProperty("value") == containsThis
        elsif containsThis.kind_of? Regexp
            return true if self.getProperty("value").match(containsThis) != nil
        end
        return false
    end
  
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

        highLight(:clear)

    end


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



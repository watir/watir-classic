require 'win32ole'


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


    def click()
        raise UnknownObjectException if @o==nil
        raise ObjectDisabledException   if !self.enabled?
        @o.click()
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



    def initialize()

        @ie =   WIN32OLE.new('InternetExplorer.Application')
        @ie.visible = TRUE
        @frame = ""
        @form = ""
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
        if ( getDocument.body.innerText =~ /#{text}/ ) != nil
            log "pageContainsText: Looking for: #{text} - found it ok" 
            return true
        else
            log "pageContainsText: Looking for: #{text} - Didnt Find it" 
            return false
        end
    end

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
        s=nil
    end

    def goto( url )
        @ie.navigate(url)
        waitForIE()
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


    def getObject( how, what  )
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
                        o=n["0"]
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

end


class Button < ObjectActions
    
    def initialize( ieController,  how , what )
        @ieController = ieController
        @o = ieController.getObject( how, what )
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
 
    

    def set( setThis )

    end

end



=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2004-2005, Paul Rogers and Bret Pettichord
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Paul Rogers, Bret Pettichord nor the names of contributors to
  this software may be used to endorse or promote products derived from this
  software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  --------------------------------------------------------------------------
  (based on BSD Open Source License)
=end

#  This is Watir, a web application testing tool for Ruby
#  Home page is http://wtr.rubyforge.com
#
#  Version "$Revision$"
#
#  Typical usage: 
#   # include the controller 
#   require 'watir' 
#   # create an instance of the controller 
#   ie = Watir::IE.new  
#   # go to the page you want to test 
#   ie.goto("http://myserver/mypage") 
#   # to enter text into a text field - assuming the field is name "username" 
#   ie.textField(:name, "username").set("Paul") 
#   # if there was a text field that had an id of "company_ID", you could set it to Ruby Co: 
#   ie.textField(:id ,"company_ID").set("Ruby Co") 
#   # to click a button that has a caption of 'Cancel' 
#   ie.button(:caption, "Cancel").click 
#   
#  The ways that are available to identify an html object depend upon the object type. 
#   :id      used for an object that has an ID attribute -- this is the best way!
#   :name    used for an object that has a name attribute. 
#   :value   value of text fields, captions of buttons 
#   :index   finds the nth object of the specified type - eg button(:index , 2) finds the second button. This is 1 based. <br>

require 'win32ole'
require 'logger'
require 'watir/winClicker'
require 'watir/exceptions'

# http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/webbrowser.asp
# http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/overview/overview.asp

class String
    def matches (x)
        return self == x
    end
end

class Regexp
    def matches (x)
        return self.match(x) 
    end
end


# ARGV needs to be deleted to enable the Test::Unit functionatily that grabs
# the remaining ARGV as a filter on what tests to run.
$HIDE_IE = ARGV.include?('-b'); ARGV.delete('-b')

module Watir
    include Watir::Exception
    
    # this class is the simple WATIR logger. Any other logger can be used, however it must provide these methods.
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
    
    
    # This class displays the spinner object that appears in the console when a page is being loaded
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

    #
    # MOVETO: watir/browser_driver.rb
    # Module Watir::BrowserDriver
    #
    
    
    # This class is the main Internet Explorer Controller
    # An instance of this must be created to access Internet Explorer.
    class IE
        include Watir::Exception
        
        # Used internally to determine when IE has finished loading a page
        READYSTATE_COMPLETE = 4         
        
        # The default delay when entering text on a web page.
        DEFAULT_TYPING_SPEED = 0.08
        
        # The default time we wait after a page has loaded.
        DEFAULT_SLEEP_TIME = 0.1
        
        # The default color for highlighting objects as they are accessed.
        DEFAULT_HIGHLIGHT_COLOR = "yellow"
        
        # This is used to change the typing speed when entering text on a page.
        attr_accessor :typingspeed
        
        # This is used to change how long after a page has finished loading that we wait for.
        attr_accessor :defaultSleepTime
        
        # The color we want to use for the active object. This can be any valid web-friendly color.
        attr_accessor :activeObjectHighLightColor
        
        # When a new window is created it is stored in newWindow
        attr_accessor :newWindow
        
        attr_reader :ie
                        
        def initialize(suppress_new_window=nil)
            unless suppress_new_window
                create_browser_window
                set_defaults
            end
        end
        
        # Create a new IE Window, starting at the specified url.
        # If no url is given, start empty.
        def IE.start( url = nil )
            ie = new
            ie.goto(url) if url
            return ie
        end
        
        # Attach to an existing IE window, either by url or title.
        # IE.attach(:url, 'http://www.google.com')
        # IE.attach(:title, 'Google') 
        def IE.attach(how, what)
            ie = new(true) # don't create window
            ie.attach_init(how, what)
            return ie
        end   

        def attach_init( how, what )
            attach_browser_window(how, what)
            set_defaults                        
        end        
        
        def set_defaults
            @form = nil

            @ie.visible = ! $HIDE_IE
            @typingspeed = DEFAULT_TYPING_SPEED
            @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
            @defaultSleepTime = DEFAULT_SLEEP_TIME

            @logger = nil
        end
        private :set_defaults        
        
        def create_browser_window
            @ie = WIN32OLE.new('InternetExplorer.Application')
        end
        private :create_browser_window

        def attach_browser_window( how, what )
            puts "Seeking Window with #{how}: #{ what }"
            shell = WIN32OLE.new("Shell.Application")
            appWindows = shell.Windows()
            
            ieTemp = nil
            appWindows.each do |aWin| 
                print "Found a window: #{aWin}. "
                
                case how
                when :url
                    log " url is: #{aWin.locationURL}\n"
                    ieTemp = aWin if (what.matches(aWin.locationURL) )
                when :title
                    # normal windows explorer shells do not have document
                    title = nil
                    begin
                        title = aWin.document.title
                    rescue WIN32OLERuntimeError
                    end
                    ieTemp = aWin if (what.matches( title ) ) 
                else
                    raise ArgumentError
                end
            end

            #if it can not find window
            if ieTemp == nil
                 raise NoMatchingWindowFoundException,
                 "Unable to locate a window with #{ how} of #{what}"
            end
            @ie = ieTemp
        end
        private :attach_browser_window

        def set_logger( logger )
            @logger = logger
        end

        #
        # Accessing data outside the document
        #
        
        # Return the title of the window
        def title
            @ie.document.title
        end
        
        # Return the status of the window, typically from the status bar at the bottom.
        def status
            raise NoStatusBarException if !@ie.statusBar
            return @ie.statusText()
        end
        alias getStatus status

        #
        # Navigation
        #

        # Causes the Internet Explorer browser to navigate to the specified URL.
        #  * url  - string - the URL to navigate to
        def goto( url )
            @ie.navigate(url)
            waitForIE()
            sleep 0.2
        end
        
        # Goes to the previous page - the same as clicking the browsers back button
        # an WIN32OLERuntimeError exception is raised if the browser cant go back
        def back
            @ie.GoBack()
            waitForIE
        end

        # Goes to the next page - the same as clicking the browsers forward button
        # an WIN32OLERuntimeError exception is raised if the browser cant go forward
        def forward
            @ie.GoForward()
            waitForIE
        end
        
        # Refreshes the current page - the same as clicking the browsers refresh button
        # an WIN32OLERuntimeError exception is raised if the browser cant refresh
        def refresh
            @ie.refresh2(3)
            waitForIE
        end
        
        # Closes the Browser
        def close
            @ie.quit
        end
        

        def capture_events
            ev = WIN32OLE_EVENT.new(@ie, 'DWebBrowserEvents2')
            
            ev.on_event_with_outargs("NewWindow3") {|ppdisp, cancel, flags, fromURL, toURL , args| 
                
                # http://msdn.microsoft.com/workshop/browser/webbrowser/reference/ifaces/dwebbrowserevents2/newwindow2.asp
                # http://groups.google.ca/groups?q=on_event_with_outargs&hl=en&lr=&group=comp.lang.ruby&safe=off&selm=e249d8e7.0410060843.3f55fa05%40posting.google.com&rnum=1
                # http://groups.google.ca/groups?q=on_event&hl=en&lr=&group=comp.lang.ruby&safe=off&selm=200202211155.UAA05077%40ums509.nifty.ne.jp&rnum=8
                
                log "New Window URL: #{ toURL }"
                log "Flags: #{flags}"
                args[1] = true
                @newWindow = IE.new
                @newWindow.goto(toURL)
            }
        end
        
        # used by the popup code only
        def dir
            return File.expand_path(File.dirname(__FILE__))
        end
        
        def log ( what )
            @logger.debug( what ) if @logger
            puts what
        end
        
        # Deprecated: Use IE#.ie instead
        # This method returns the Internet Explorer object. 
        # Methods, properties,  etc. that the IEController does not support can be accessed.
        def getIE()
            return @ie
        end
        
        #
        # Document and Document Data
        #
        
        # Return the current document
        def document()
            return @ie.document
        end
        alias getDocument document
                
        # Search the current page for specified text or regexp.
        # Returns true if the specified text was found.
        # Returns matchdata object if the specified regexp was found.
        #  * text - string or regular expression - the string to look for
        def pageContainsText(text)
            #log "-------------"
            #log getDocument().body.innerText
            #log "-------------"
            returnValue = false
            retryCount = 0
            begin
                retryCount += 1
                returnValue = 
                if text.kind_of? Regexp
                    getDocument().body.innerText.match(text)
                elsif text.kind_of? String
                    getDocument().body.innerText.index(text)
                else
                    raise MissingWayOfFindingObjectException
                end 
            rescue MissingWayOfFindingObjectException => e
                raise e
            rescue
                retry if retryCount < 2 
            end
            return returnValue
        end
        
        # 
        # Synchronization
        #
        
        # This method is used internally to cause an execution to stop until the page has loaded in Internet Explorer.
        def wait( noSleep  = false )
            begin
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
                sleep 0.02
                
                until @ie.document.readyState == "complete"
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
                end
                print "\b"
                #puts "waitForIE Complete"
                s=nil
            rescue WIN32OLERuntimeError
              
            end
            sleep 0.01
            sleep @defaultSleepTime unless noSleep  == true
        end
        alias waitForIE wait
        
        # this method returns the HTML of the current page
        def html()
            return getDocument().body.innerHTML
        end
        alias getHTML html
        
        # this method returns the text of the current document
        def text()
            return getDocument().body.innerText
        end
        alias getText text

        #
        # Show me state
        #        
        
        # This method is used to display the available html frames that Internet Explorer currently has loaded.
        # This method is usually only used for debugging test scripts.
        def show_frames()
            if allFrames = getDocument().frames
                count = allFrames.length
                puts "there are #{count} frames"
                for i in 0..count-1 do  
                    begin
                        fname = allFrames[i.to_s].name.to_s
                        log "frame  index: #{i} name: #{fname}"
                    rescue => e
                        log "frame  index: #{i} --Access Denied--" if e.to_s.match(/Access is denied/)
                    end
                end
            else
                log "no frames"
            end
        end
        alias showFrames show_frames
        
        # Show all forms displays all the forms that are on a web page.
        def show_forms()
            if allForms = getDocument.forms
                count = allForms.length
                log "There are #{count} forms"
                for i in 0..count-1 do
                    wrapped = FormWrapper.new(allForms.item(i))
                    log "Form name: #{wrapped.name}"
                    log "       id: #{wrapped.id}"
                    log "   method: #{wrapped.method}"
                    log "   action: #{wrapped.action}"
                end
            else
                log "No forms"
            end
        end
        alias showForms show_forms
        
        def show_images()
            doc = getDocument()
            doc.images.each do |l|
                log "image: name: #{l.name}"
                log "         id: #{l.invoke("id")}"
                log "      src: #{l.src}"
            end
        end
        alias showImages show_images
        
        def show_links()
            doc = getDocument()
            doc.links.each do |l|
                log "Link: name: #{l.name}"
                log "      id: #{l.invoke("id")}"
                log "      href: #{l.href}"
                log "      text: #{l.innerText}"
            end
        end
        alias showLinks show_links
        
        # this method shows the name, id etc of the object that is currently active - ie the element that has focus
        # its mostly used in irb when creating a script
        def show_active
            s = "" 
            
            current = getDocument.activeElement
            begin
                s=s+current.invoke("type").to_s.ljust(16)
            rescue
            end
            props=["name" ,"id" , "value" , "alt" , "src","innerText","href"]
            props.each do |prop|
                begin
                    p = current.invoke(prop)
                    s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
                rescue
                    #this object probably doesnt have this property
                end
            end
            s=s+"\n"
        end
        alias showActive show_active
        
        # This method shows the available objects on the current page.
        # This is usually only used for debugging or writing new test scripts.
        # This is a nice feature to help find out what HTML objects are on a page
        # when developing a test case using Watir.
        def show_all_objects()
            log "-----------Objects in  page -------------" 
            doc = getDocument()
            s = ""
            props=["name" ,"id" , "value" , "alt" , "src"]
            doc.all.each do |n|
                begin
                    s=s+n.invoke("type").to_s.ljust(16)
                rescue
                    next
                end
                props.each do |prop|
                    begin
                        p = n.invoke(prop)
                        s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
                    rescue
                        # this object probably doesnt have this property
                    end
                end
                s=s+"\n"
            end
            log s+"\n\n\n"
        end
        alias showAllObjects show_all_objects

        def show_divs( )
            divs = getDocument().getElementsByTagName("DIV")
            puts "Found #{divs.length} div tags"
            divs.each do |d|
                puts "id=#{d.invoke('id')}      style=#{d.invoke("className")}"
            end
        end
        alias showDivs show_divs

        
        #
        # Searching for Page Elements
        #        
        
        def getContainer()
            return getDocument.body.all
        end
        private :getContainer
        
        
        # This is the main method for finding objects on a web page.
        #   * how - symbol - the way we look for the object. Supported values are
        #                  - :name
        #                  - :id
        #                  - :index
        #                  - :value
        #   * what  - string that we are looking for, ex. the name, or id tag attribute or index of the object we are looking for.
        #   * types - what object types we will look at. Only used when index is specified as the how.
        #   * value - used for objects that have one name, but many values. ex. radio lists and checkboxes
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
            elsif how == :src || how ==:alt
                o = getObjectWithSrcOrAlt(what , how , container, types)
            else
                #log "How is #{how}"
                container.each do |object|
                    next  unless o == nil
                    
                    begin
                        ns = false
                        case how
                        when :id
                            attribute = object.invoke("id")
                        when :name
                            attribute = object.invoke("name")
                        when :beforeText
                            attribute = object.getAdjacentText("afterEnd").strip
                        when :afterText
                            attribute = object.getAdjacentText("beforeBegin").strip
                        else
                            next
                        end
                        
                        if  what.matches( attribute )  #attribute == what
                            if types
                                if elementTypes.include?(object.invoke("type"))
                                    if value
                                        #log "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                        if object.value.to_s == value.to_s
                                            o = object
                                        end
                                    else # no value
                                        o = object
                                    end
                                end
                            else # no types
                                o = object
                            end
                        end
                    rescue => e
                        #log e.to_s + "\n" + e.backtrace.join("\n")
                    end
                    
                end
            end
            
            # If a value has been supplied, such as with a check box or a radio button, 
            # we need to go through the collection and get the correct one.
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
            
            return o
        end
        
        # This method is used internally to locate an object that has a value specified.
        # It is normally used for buttons with a caption (HTML value attribute).
        #   * what            - what we are looking for - normally the value or caption of a button
        #   * container         - the container that we are searching in ( a form or the body of a document )
        #   * *htmlObjectTypes  - an array of the objects we are interested in
        def getObjectWithValue(what , container , *htmlObjectTypes )
            
            o = nil
            container.each do |r|
                next unless o == nil
                begin
                    next unless htmlObjectTypes.include?(r.invoke("type").downcase)
                    o = r if what.matches(r.value)
                rescue
                    # may not have a value...
                end 
            end
            return o
            
        end
        
        # This method is used on buttons that are of type "image". Usually an <img src=""> or <input type="image"> HTML tag.
        # When an image is used to submit a form, it is treated as a button.
        #   * what            - what we are looking for - normally the src or alt tag attribute of a button
        #   * container         - the container that we are searching in ( a form or the body of a document )
        #   * htmlObjectTypes  - an array of the objects we are interested in
        def getObjectWithSrcOrAlt( what , how , container , htmlObjectTypes )
            o = nil
            
            container.each do |r|
                next unless o == nil
                begin
                    next unless htmlObjectTypes.include?(r.invoke("type").downcase)
                    
                    case how
                    when :alt
                        attribute = r.alt
                    when :src
                        attribute = r.src
                    else
                        next
                    end
                    
                    o = r if what.matches( attribute )         
                    
                rescue
                end 
            end
            return o
        end
        
        
        
        # This method is used to locate an object when an "index" is used. 
        # It is used internally.
        #   * container  - the container we are looking in
        #   * index      - the index of the element we want to get - 1 based counting
        #   * types      - an array of the type of objects to look at
        #   * value      - the value of the object to get, used when getting itens like checkboxes and radios
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
        
        # This method gets a link from the document. This is a hyperlink, generally declared in the <a href="http://testsite">test site</a> HTML tag.
        #   * how  - symbol - how we get the link Supported types are:
        #                     :index - the link at position x , 1 based
        #                     :url   - get the link that has a url that matches. A regular expression match is performed
        #                     :text  - get link based on the supplied text. uses either a string or regular expression match
        #   * what - depends on how - an integer for index, a string or regexp for url and text
        def getLink( how, what )
            doc = getDocument()
            links = doc.links
            
            # Guard ensures watir won't crash if somehow the list of links is nil
            if (links == nil)
                raise UnknownObjectException, "Unknown Object in getLink: attempted to click a link when no links present"
            end
            
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
                    if what.matches(thisLink.innerText) 
                        link = thisLink if link == nil
                    end
                end
                
            when :id
                links.each do |thisLink|
                    if what.matches(thisLink.invoke("id"))
                        link = thisLink if link == nil
                    end
                end
            when :name
                links.each do |thisLink|
                    if what.matches(thisLink.invoke("name"))
                        link = thisLink if link == nil
                    end
                end
                
            when :beforeText
                links.each do |thisLink|
                    if what.matches(thisLink.getAdjacentText("afterEnd").strip)
                        link = thisLink if link == nil
                    end
                end

            when :afterText
                links.each do |thisLink|
                    if what.matches(thisLink.getAdjacentText("beforeBegin").strip)
                        link = thisLink if link == nil
                    end
                end

                

                
            else
                raise MissingWayOfFindingObjectException, "unknown way of finding a link ( {what} )"
            end
            
            # if no link found, link will be a nil.  This is OK.  Actions taken on links (e.g. "click") should rescue 
            # the nil-related exceptions and provide useful information to the user.
            return link
        end

        # This method gets a table row or cell 
        #   * how  - symbol - how we get the link row or cell types are:
        #            id
        #   * what -  a string or regexp 
        def getTablePart( part , how , what )
             doc = getDocument()
             parts = doc.all.tags( part )
             n = nil
             parts.each do | p |
                 next unless n==nil
                 n = p if what.matches( p.invoke("id") )
             end
             return n
        end


        def getNonControlObject(part , how, what )

             doc = getDocument()
             parts = doc.all.tags( part )
             n = nil
             case how
                when :id
                    attribute = "id"
                when :name
                    attribute = "id"
                when :title
                    attribute = "title"
             end

             parts.each do | p |
                 next unless n==nil
                 n = p if what.matches( p.invoke(attribute) )
             end
             return n


        end


        #
        # This method is to keep current users happy, until the frames object is implemented
        #     Paul, now that we have a frame object, what should we do? -Bret

        def focus()
            doc = getDocument()
            doc.activeElement.blur
            doc.focus
        end

       
        
        #
        # Factory Methods
        #

        def frame( frameName)
            return Frame.new(self, frameName)
        end
        
        def form( how , formName=nil )
            # If only one value is supplied, it is a form name
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

        # This method is used to get a table from the page. 
        # :index (1 based counting)and :id are supported. 
        #  NOTE :name is not supported, as the table tag does not have a name attribute. It is not part of the DOM.
        # :index can be used when there are multiple forms on a page. 
        # The first form can be accessed with :index 1, the second :index 2, etc. 
        #   * how - symbol - the way we look for the table. Supported values are
        #                  - :id
        #                  - :index
        #   * what  - string the thing we are looking for, ex. id or index of the object we are looking for
        def table( how, what )
            return Table.new( self , how, what)
        end

        def cell( how, what )
           return Cell.new( self, how, what)
        end

        def row( how, what )
           return Row.new( self, how, what)
        end


        # This is the main method for accessing a button. Often declared as an <input type = submit> tag.
        #  *  how   - symbol - how we access the button , :index, :caption, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        # Returns a Button object.
        def button( how , what=nil )
            if how.kind_of? Symbol and what != nil
                return Button.new(self, how , what )
            elsif how.kind_of? String and what == nil
                log "how is a string - #{how}"
                return Button.new(self, :caption, how)
            else
                raise MissingWayOfFindingObjectException
            end
        end
        # This is the main method for accessing a file field. Usually an <input type = file> HTML tag.  
        #  *  how   - symbol - how we access the field , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        # returns a FileField object
        def file_field( how , what )
            f = FileField.new(self , how, what)
        end
        alias fileField file_field
        
        # This is the main method for accessing a text field. Usually an <input type = text> HTML tag.  
        #  *  how   - symbol - how we access the field , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        # returns a TextFieldobject
        def text_field( how , what )
            t = TextField.new(self , how, what)
        end
        alias textField text_field
        
        # This is the main method for accessing a select box. Usually a <select> HTML tag.
        #  *  how   - symbol - how we access the select box , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        # returns a SelectBox object
        def select_box( how , what )
            s = SelectBox.new(self , how, what)
        end
        alias selectBox select_box
        
        # This is the main method for accessing a check box. Usually an <input type = checkbox> HTML tag.
        #  *  how   - symbol - how we access the check box , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
        # returns a CheckBox object
        def check_box( how , what , value=nil)
            c = CheckBox.new( self, how, what , value)
        end
        alias checkBox check_box
        
        # This is the main method for accessing a radio button. Usually an <input type = radio> HTML tag.
        #  *  how   - symbol - how we access the radio button, :index, :id, :name etc
        #  *  what  - string, int or regexp , what we are looking for, 
        #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
        # returns a RadioButton object
        def radio( how , what , value=nil)
            r = RadioButton.new( self, how, what , value)
        end
        
        # This is the main method for accessing a link.
        #  *  how   - symbol - how we access the link, :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        # returns a Link object
        def link( how , what)
            l = Link.new(self , how, what )
        end
        
        # This is the main method for accessing images.
        #  *  how   - symbol - how we access the image, :index, :id, :name , :src
        #  *  what  - string, int or re , what we are looking for, 
        # returns an Image object
        #This method retrieves an image on a web page for use.
        #Uses an <img src="image.gif"> HTML tag.
        def image( how , what)
            i = Image.new(self , how, what )
        end
        
        # This is the main method for accessing JavaScript popups.
        # returns a PopUp object
        def popup( )
            i = PopUp.new(self )
        end
        
        def div( how , what )
            return Div.new(self , how , what)
        end

    end # class IE
    
    
    # 
    # MOVETO: watir/popup.rb
    # Module Watir::Popup
    #
    
    # POPUP object
    class PopUp
        def initialize( ieController )
            @ieController = ieController
        end
        
        def button( caption )
            return JSButton.new(  @ieController.getIE.hwnd , caption )
        end
        
    end
    
    class JSCommon
        def initialize()
        end
    end
    
    
    class JSButton < JSCommon
        def initialize( hWnd , caption )
            @hWnd = hWnd
            @caption = caption
        end
        
        def startClicker( waitTime = 3 )
            
            clicker = WinClicker.new
            clicker.clickJSDialog_Thread
            # clickerThread = Thread.new( @caption ) {
            #   sleep waitTime
            #   puts "After the wait time in startClicker"
            #   clickWindowsButton_hwnd(hwnd , buttonCaption )
            #}
        end
        
    end
    
    #
    # 
    # Module Watir::Control or Watir::BrowserDriver
    #

    class Frame < IE
    
        def initialize(container, name)
            @container = container
            @frame = nil
        
            frames = @container.getDocument.frames

            for i in 0 .. frames.length-1
                this_frame = frames[i.to_s]
                begin
                    if name == this_frame.name.to_s
                          @frame = this_frame
                    end
                rescue
                    # probably no name on this object
                end
            end
            
            unless @frame
                raise UnknownFrameException , "Unable to locate a frame with name #{ name } " 
            end

            @typingspeed = container.typingspeed      
            @activeObjectHighLightColor = container.activeObjectHighLightColor      
        end

        def getDocument
            @frame.document
        end

        def wait(no_sleep = false)
            @container.wait(no_sleep)
        end
        alias waitForIE wait
    end
    

    # Forms

    module FormWrapperMethods
        def name
            @form.getAttributeNode('name').value
        end
        def action
            @form.action
        end
        def method
            @form.invoke('method')
        end
        def id
            @form.invoke("id").to_s
        end
    end        
        
    # wraps around a form ole object
    class FormWrapper
        include FormWrapperMethods
        def initialize ( ole_object )
            @form = ole_object
        end
    end
       
    #   Form Factory object 
    #   * ieController  - an instance of an IEController
    #   * how         - symbol - how we access the form (:name, :id, :index, :action, :method)
    #   * what         - what we use to access the form
    class Form < IE
        include FormWrapperMethods

        attr_accessor :form
        def initialize( container, how, what )
            @container = container
            @formHow = how
            @formName = what
            
            log "Get form  formHow is #{@formHow}  formName is #{@formName} "
            count = 1
            doc = @container.getDocument()
            doc.forms.each do |thisForm|
                next unless @form == nil

                wrapped = FormWrapper.new(thisForm)

                log "form on page, name is " + wrapped.name
                
                @form =
                case @formHow
                when :name 
                    wrapped.name == @formName ? thisForm : nil
                when :id
                    wrapped.id == @formName.to_s ? thisForm : nil
                when :index
                    count == @formName.to_i ? thisForm : nil
                when :method
                    wrapped.method.downcase == @formName.downcase ? thisForm : nil
                when :action
                    @formName.matches(wrapped.action) ? thisForm : nil
                else
                    raise MissingWayOfFindingObjectException
                end
                count = count +1
            end
            
            @typingspeed = @container.typingspeed      
            @activeObjectHighLightColor = @container.activeObjectHighLightColor      
        end

        def exists?
            @form ? true : false
        end
        
        # Submit the data -- equivalent to pressing Enter or Return to submit a form. 
        def submit()
            raise UnknownFormException ,  "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
            @form.submit 
            @container.waitForIE
        end   

        def getContainer()
            raise UnknownFormException , "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
            @form.elements.all
        end   
        private :getContainer

        def wait(no_sleep = false)
            @container.wait(no_sleep)
        end
        alias waitForIE wait 
                                
    end # class Form
    

    #
    # MOVETO: watir/driver.rb
    # Module Watir::Driver
    #
        
    # This class is the base class for most actions ( such as "click ", etc. ) that occur on an object.
    # This is not a class that users would normally access. 
    class ObjectActions
        include Watir::Exception
        
        # Creates an instance of this class.
        # The "initialize" method creates several default properties for the object.
        # These properties are accessed using the setProperty and getProperty methods
        #   o  - the object that watir is using
        def initialize( o )
            @o = o
            @defaultProperties = { 
         "type"     =>  "type" ,
         "id"       =>  "id" ,
         "name"     => "name",
         "value"    => "value"  ,
         "disabled" => "disabled"
            }
            @ieProperties = Hash.new
            setProperties(@defaultProperties)
            @originalColor = nil
        end
        
        # This method sets the properties for the object
        def setProperties(propertyHash )
            if @o 
                propertyHash.each_pair do |a,b|
                    begin
                        setProperty(a , @o.invoke("#{b}" ) )
                    rescue
                        # Object probably doesn't support this item, so rescue
                    end 
                end
            end  #if @o
        end
        
        # This method is used to set a property
        #   * name  - string - the name of the property to set
        #   * val   - string - the value to set
        def setProperty(name , val)
            @ieProperties[name] = val
        end
        
        # This method retrieves the value of the specified property.
        #   * name  - string - the name of the property to retrieve
        def getProperty(name)
            raise UnknownPropertyException("Unable to locate property, #{name}") if !@ieProperties.has_key?(name)
            return @ieProperties[name]
        end
        
        def getOLEObject()
            return @o
        end
        
        # This method displays basic details about the object. Sample output for a button is shown.
        # Raises UnknownObjectException if the object is not found.
        #      name      b4
        #      type      button
        #      id         b5
        #      value      Disabled Button
        #      disabled   true
        def to_s
            raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
            n = []
            @ieProperties.each_pair do |k,v|      
                n << "#{k}".ljust(18) + "#{v}"
            end
            return n
        end
        
        # This method is responsible for setting and clearing the colored highlighting on the currently active element.
        # use :set   to set the highlight
        #   :clear  to clear the highlight
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
        
        #   This method clicks the active element.
        #   raises: UnknownObjectException  if the object is not found
        #   ObjectDisabledException if the object is currently disabled
        def click()
            raise UnknownObjectException ,"Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
            raise ObjectDisabledException ,"object #{@how.to_s} and #{@what.to_s} is disabled" if !self.enabled?
            
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
        
        # This method executes a user defined "fireEvent" for objects with JavaScript events tied to them such as DHTML menus.
        #   usage: allows a generic way to fire javascript events on page objects such as "onMouseOver", "onClick", etc.
        #   raises: UnknownObjectException  if the object is not found
        #           ObjectDisabledException if the object is currently disabled
        def fireEvent(event)
            raise UnknownObjectException ,"Unable to locate object, using #{@how.to_s} and #{@what.to_s}" if @o==nil
            raise ObjectDisabledException ,"object #{@how.to_s} and #{@what.to_s} is disabled"   if !self.enabled?
            
            highLight(:set)
            @o.fireEvent("#{event}")
            @ieController.waitForIE()
            highLight(:clear)
        end
        
        # This method sets focus on the active element.
        #   raises: UnknownObjectException  if the object is not found
        #           ObjectDisabledException if the object is currently disabled
        def focus()
            raise UnknownObjectException("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
            raise ObjectDisabledException("Object #{@how.to_s} #{@what.to_s} is disabled ")   if !self.enabled?
            @o.focus()
        end
        
        # This methods checks to see if the current element actually exists. 
        def exists?
            @o? true: false
        end
        
        # This method returns true if the current element is enable, false if it isn't.
        #   raises: UnknownObjectException  if the object is not found
        def enabled?
            raise UnknownObjectException.new("Unable to locate object, using #{@how.to_s} and #{@what.to_s}") if @o==nil
            return false if @o.invoke("disabled")
            return true
        end
    end

    class Div < ObjectActions
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getNonControlObject("div" , how, what )
            super( @o )
            @how = how
            @what = what
        end

        def text()
            raise UnknownObjectException ,  "Unable to locate a div using #{@how} and #{@what} "  if @o == nil
            d = @o.innerText
            return d
        end

        def style
            raise UnknownObjectException ,  "Unable to locate a div using #{@how} and #{@what} "  if @o == nil
            d = @o.invoke("className")
            return d
        end

    end

        
    # This class is used for dealing with tables.
    # This will not be normally used by users, as the table method of IEController would return an initialised instance of a table.
    class Table < ObjectActions
        
        # Returns an initialized instance of a table object
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the table
        #   * what         - what we use to access the table - id, name index etc 
        def initialize( ieController,  how , what )
            @ieController = ieController
            allTables = @ieController.getDocument.body.getElementsByTagName("TABLE")
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
                tableIndex = tableIndex + 1
            end
            #puts "table - #{what}, #{how} Not found " if table ==  nil
            @o = table
            super( @o )
            @how = how
            @what = what
        end
                
        # This method returns the number of rows in the table.
        # Raises an UnknownTableException if the table doesnt exist.
        def row_count
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} "  if @o == nil
            table_rows = @o.getElementsByTagName("TR")
            return table_rows.length
        end
        
        # This method returns the number of columns in the table.
        # Raises an UnknownTableException if the table doesn't exist.
        def column_count( rowToUse = 1)
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} "  if @o == nil
            table_rows = @o.getElementsByTagName("TR")
            cols = table_rows[rowToUse.to_s].getElementsByTagName("TD")
            return cols.length
        end
        
        # This method returns the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
        # Raises an UnknownTableException if the table doesn't exist.
        def to_a
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
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


# this class is a table cell
    class Cell < ObjectActions

        # Returns an initialized instance of a table cell
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the cell
        #   * what         - what we use to access the cell - id, name index etc 
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getTablePart( "TD" , how , what )
            super( @o )
            @how = how
            @what = what
        end

        def getContents()
            raise UnknownObjectException , "Unable to locate table cell with #{@how} of #{@what}" if @o == nil
            return @o.innerText
 
        end

    end

    # this class is a table row
    class Row < ObjectActions

        # Returns an initialized instance of a table cell
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the cell
        #   * what         - what we use to access the cell - id, name index etc 
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getTablePart( "TR" , how , what )
            super( @o )
            @how = how
            @what = what
        end
    end
        
    # This class is the means of accessing an image on a page.
    # It would not normally be used by users, as the image method of IEController would return an initialised instance of an image.
    class Image < ObjectActions
        
        # Returns an initialized instance of a image  object
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the image
        #   * what         - what we use to access the image, text, url, index etc
        def initialize( ieController,  how , what )
            @ieController = ieController
            doc = ieController.getDocument()
            
            puts "Finding an image how: #{how} What #{what}"
            count = 1
            images = doc.images
            o=nil
            images.each do |img|
                
                puts "Image on page: src = #{img.src}"
                
                next unless o == nil
                if how == :index
                    o = img if count == what.to_i
                else                
                    case how
                        
                    when :src
                        attribute = img.src
                    when :name
                        attribute = img.name
                    when :id
                        attribute = img.invoke("id")
                    when :alt
                        attribute = img.invoke("alt")
                    else
                        next
                    end
                    
                    o = img if what.matches(attribute)
                end
                count +=1
            end # do
            @o = o

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
        
        # This method attempts to find out if the image was actually loaded by the web browser. 
        # If the image was not loaded, the browser is unable to determine some of the properties. 
        # We look for these missing properties to see if the image is really there or not. 
        # If the Disk cache is full ( tools menu -> Internet options -> Temporary Internet Files) , it may produce incorrect responses.
        def hasLoaded?
            raise UnknownObjectException ,  "Unable to locate image using #{@how} and #{@what} " if @o==nil
            return false  if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
            return true
        end

        def highLight( setOrClear )
            if setOrClear == :set
                begin
                    @original_border = @o.border
                    @o.border = 1
                rescue
                    @original_border = nil
                end
            else
                begin 
                    @o.border = @original_border 
                    @original_border = nil
                rescue
                    # we could be here for a number of reasons...
                ensure
                    @original_border = nil
                end
            end
        end

    end
    
    
    # This class is the means of accessing a link on a page
    # It would not normally be used bt users, as the link method of IEController would returned an initialised instance of a link.
    class Link < ObjectActions
        # Returns an initialized instance of a link object
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the link
        #   * what         - what we use to access the link, text, url, index etc
        def initialize( ieController,  how , what )
            @ieController = ieController
            begin
                @o = ieController.getLink( how, what )
            rescue UnknownObjectException
                @o = nil
            end
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
        #   * how         - symbol - how we access the select box
        #   * what         - what we use to access the select box, name, id etc
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getObject( how, what , ["select-one","select-multiple"] )
            super( @o )
            @how = how
            @what = what
        end
        
        # This method clears the selected items in the select box
        def clearSelection
            raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} " if @o==nil
            highLight( :set)
            @o.each do |selectBoxItem|
                selectBoxItem.selected = false
                @ieController.waitForIE()
            end
            highLight( :clear)
        end
        
        # This method selects an item, or items in a select box.
        # Raises NoValueFoundException   if the specified value is not found.
        #  * item   - the thing to select, string, reg exp or an array of string and reg exps
        def select( item )
            select_item_in_select_list( :text , item )
        end


        # This method selects an item, or items in a select box.
        # Raises NoValueFoundException   if the specified value is not found.
        #  * item   - the value of the thing to select, string, reg exp or an array of string and reg exps
        def select_value( item )
            select_item_in_select_list( :value , item )
        end



        # this method is used internally to select something from the select box
        #  * name  - symbol  :vale or :text - how we find an item in the select box
        #  * item  - string or reg exp - what we are looking for
        def select_item_in_select_list( name_or_value, item )

            raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} "  if @o==nil
            if item.kind_of?( Array ) == false
                items = [item]
            else
                items = item 
            end
            
            

            highLight( :set)
            doBreak = false
            items.each do |thisItem|
                
                @ieController.log "Setting box #{@o.name} to #{thisItem} #{thisItem.class} "
                
                @o.each do |selectBoxItem|
                    @ieController.log " comparing #{thisItem } to #{selectBoxItem.invoke(name_or_value.to_s) }"
                    if thisItem.matches( selectBoxItem.invoke(name_or_value.to_s))
                        matchedAnItem = true
                        if selectBoxItem.selected == true
                            @ieController.log " #{selectBoxItem.invoke(name_or_value.to_s)} is already selected"
                            doBreak = true
                        else
                            @ieController.log " #{selectBoxItem.invoke(name_or_value.to_s)} is being selected"
                            selectBoxItem.selected = true
                            @o.fireEvent("onChange")
                            doBreak = true
                        end
                        @ieController.waitForIE()
                        break if doBreak
                    end
                end
                
                raise NoValueFoundException , "Selectbox was found, but didnt find item with #{name_or_value.to_s} of #{item} "   if doBreak == false
            end
            highLight( :clear )
        end

        private :select_item_in_select_list







        
        # This method returns all the items in the select list as an array. An empty array is returned if the select box has no contents.
        # Raises UnknownObjectException if the select box is not found
        def getAllContents()
            raise UnknownObjectException  ,  "Unable to locate a selectbox  using #{@how} and #{@what} " if @o==nil
            returnArray = []
            
            @ieController.log "There are #{@o.length} items"
            
            @o.each do |thisItem|
                returnArray << thisItem.text
            end
            return returnArray 
            
        end
        
        # This method returns all the selected items from the select box as an array.
        # Raises UnknownObjectException if the select box is not found.
        def getSelectedItems
            raise UnknownObjectException ,  "Unable to locate a selectbox  using #{@how} and #{@what} "  if @o==nil
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
    
    # This is the main class for accessing buttons.
    # Normally a user would not need to create this object as it is returned by the IEController Button method.
    class Button < ObjectActions
        # Create an instance of the button object
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getObject( how, what , ["button" , "submit" , "image"] )
            super( @o )
            @how = how
            @what = what
        end
    end
    
    # File dialog
    class FileField < ObjectActions
        # Create an instance of the file object
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getObject( how, what , ["file"] )
            super( @o )
            @how = how
            @what = what
        end
        
        def set(setPath)	        
            Thread.new {
                clicker = WinClicker.new
                clicker.setFileRequesterFileName_newProcess(setPath)
            }
            # may need to experiment with this value.  if it takes longer than this
            # to open the new external Ruby process, the current thread may become
            # blocked by the file chooser.
            sleep(1)	
            self.click
        end
    end

    # This class is the parent class for radio buttons and check boxes. It contains methods common to both.
    # It should not be created by users.
    class RadioCheckCommon < ObjectActions
        # Constant for setting, or determining if a check box or radio button is set.
        CHECKED = true
        # Constant for unsetting, or determining if a check box or radio button is unset.
        UNCHECKED = false
        
        def initialize( o )
            super(o)
        end
        
        # This method determines if a radio button or check box is set.
        # Returns true is set or false if not set.
        # Raises UnknownObjectException if its unable to locate an object.
        def isSet?
            raise UnknownObjectException ,  "Unable to locate a radio button using #{@how} and #{@what} "if @o==nil
            return true if @o.checked
            return false
        end
        
        # This method clears a radio button or check box. Note, with radio buttons one of them will almost always be set.
        # Returns true if set or false if not set.
        #   Raises UnknownObjectException if its unable to locate an object
        #         ObjectDisabledException  IF THE OBJECT IS DISABLED 
        def clear
            raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
            raise ObjectDisabledException  ,  "object #{@how} and #{@what} is disabled " if !self.enabled?
            @o.checked = false
            @o.fireEvent("onClick")
            @ieController.waitForIE()
        end
        
        # This method sets the radio list item or check box.
        #   Raises UnknownObjectException  if its unable to locate an object
        #         ObjectDisabledException  IF THE OBJECT IS DISABLED 
        def set
            raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
            raise ObjectDisabledException  ,  "object #{@how} and #{@what} is disabled " if !self.enabled?
            highLight( :set)
            @o.checked = true
            @o.fireEvent("onClick")
            @ieController.waitForIE()
            highLight( :clear )
        end
        
        # This method gets the state of a radio list item or check box.
        # Returns CHECKED or UNCHECKED
        #   Raises UnknownObjectException  if its unable to locate an object
        def getState
            raise UnknownObjectException ,  "Unable to locate an object using #{@how} and #{@what} " if @o==nil
            return CHECKED if @o.checked == true
            return UNCHECKED 
        end
        
    end
    
    # This class is the main class for radio buttons.
    # It shouldn't normally be created, as the radio method of IEController will return an initialized object.
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
    
    # This class is the main class for Check boxes.
    # It shouldnt normally be created, as the checkBox method of IEController will return an initialized object.
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
    
    # This class is the main class for Text Fields
    # It shouldn't normally be created, as the textField method of IEController will return an initialized object.
    class TextField < ObjectActions
        
        def initialize( ieController,  how , what )
            @ieController = ieController
            @o = ieController.getObject( how, what , ["text" , "password","textarea"] )
            super( @o )
            @how = how
            @what = what
            @properties = {
         "maxLength"  =>      "maxLength" ,
         "length"     =>      "length" 
            }
        end
        
        # This method returns true or false if the text field is read only.
        #   Raises  UnknownObjectException if the object can't be found.
        def readOnly?
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "   if @o==nil
            return @o.readOnly 
        end   
        
        # This method returns the current contents of the text field as a string.
        #   Raises  UnknownObjectException if the object can't be found
        def getContents()
            raise UnknownObjectException if @o==nil
            return self.getProperty("value")
        end
        
        # This method returns true orfalse if the text field contents is either a string match 
        # or a regular expression match to the supplied value.
        #   Raises  UnknownObjectException if the object can't be found
        #   * containsThis - string or reg exp  -  the text to verify 
        def verify_contains( containsThis )
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
            
            if containsThis.kind_of? String
                return true if self.getProperty("value") == containsThis
            elsif containsThis.kind_of? Regexp
                return true if self.getProperty("value").match(containsThis) != nil
            end
            return false
        end

        # this method is used to drag the entire contents of the text field to another text field
        #  19 Jan 2005 - It is added as prototype functionality, and may change
        #   * destination_how   - symbol, :id, :name how we identify the drop target 
        #   * destination_what  - string or regular expression, the name, id, etc of the text field that will be the drop target
        def dragContentsTo( destination_how , destination_what)
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil

            destination = @ieController.textField(destination_how , destination_what)

            raise UnknownObjectException ,  "Unable to locate destination using #{destination_how } and #{destination_what } "   if destination.exists? == false

            @o.focus
            @o.select()
            value = self.getProperty("value")

            @o.fireEvent("onSelect")
            @o.fireEvent("ondragstart")
            @o.fireEvent("ondrag")
            destination.fireEvent("onDragEnter")
            destination.fireEvent("onDragOver")
            destination.fireEvent("ondrop")

            @o.fireEvent("ondragend")
            destination.value= ( destination.value + value.to_s  )
            self.value = ""
        end


        # This method clears the contents of the text box.
        #   Raises  UnknownObjectException if the object can't be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        def clear()
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
            raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
            raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?
            
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
        
        # This method appens the supplied text to the contents of the text box.
        #   Raises  UnknownObjectException if the object cant be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        #   * setThis  - string - the text to append
        def append( setThis)
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
            raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
            raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?
            
            
            highLight(:set)
            @o.scrollIntoView
            @o.focus
            doKeyPress( setThis )
            highLight(:clear)
            
        end
        
        # This method sets the contents of the text box to the supplied text 
        #   Raises  UnknownObjectException if the object cant be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        #   * setThis  - string - the text to set 
        def set( setThis )
            raise UnknownObjectException ,  "Unable to locate a textfield using #{@how} and #{@what} "  if @o==nil
            raise ObjectDisabledException , "Textfield #{@how} and #{@what} is disabled "   if !self.enabled?
            raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only "  if self.readOnly?
            
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
        
        # this method sets the value of the text field directly. It causes no events to be fired or exceptions to be raised, so generally shouldnt be used
        # it is preffered to use the set method.
        def value=(v)
            @o.value = v.to_s
        end


        # returns the current value of the text field
        def value
            return @o.value.to_s
        end



        # This method is used internally by setText and appendText
        # It should not be used externally.
        #   * value   - string  - The string to enter into the text field
        def doKeyPress( value )
            begin
                maxLength = @o.maxLength
                if value.length > maxLength
                    value = suppliedValue[0 .. maxLength ]
                    log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
                end
            rescue
                # probably a text area - so it doesnt have a max Length
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
        private :doKeyPress
    end
    
end
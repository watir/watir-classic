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

=begin rdoc
   This is Watir, Web Application Testing In Ruby
   The home page for this project is is http://wtr.rubyforge.org

   Version "$Revision: 1.282 $"

   Typical usage:
    # include the controller
    require "watir"

    # go to the page you want to test
    ie = Watir::IE.start("http://myserver/mypage")

    # enter "Paul" into an input field named "username"
    ie.text_field(:name, "username").set("Paul")

    # enter "Ruby Co" into input field with id "company_ID"
    ie.text_field(:id, "company_ID").set("Ruby Co")

    # click on a link that has "green" somewhere in the text that is displayed
    # to the user, using a regular expression
    ie.link(:text, /green/)

    # click button that has a caption of "Cancel"
    ie.button(:value, "Cancel").click

   WATIR allows your script to read and interact with HTML objects--HTML tags
   and their attributes and contents.  Types of objects that WATIR can identify
   include:

   Type         Description
   ===========  ===============================================================
   button       <input> tags, with the type="button" attribute
   check_box    <input> tags, with the type="checkbox" attribute
   div          <div> tags
   form
   frame
   hidden       hidden <input> tags
   image        <img> tags
   label
   link         <a> (anchor) tags
   p            <p> (paragraph) tags
   radio        radio buttons; <input> tags, with the type="radio" attribute
   select_list  <select> tags, known informally as drop-down boxes
   span         <span> tags
   table        <table> tags
   text_field   <input> tags with the type="text" attribute (a single-line
                text field), the type="text_area" attribute (a multi-line
                text field), and the type="password" attribute (a
                single-line field in which the input is replaced with asterisks)

   In general, there are several ways to identify a specific object.  WATIR's
   syntax is in the form (how, what), where "how" is a means of identifying
   the object, and "what" is the specific string or regular expression
   that WATIR will seek, as shown in the examples above.  Available "how"
   options depend upon the type of object, but here are a few examples:

   How           Description
   ============  ===============================================================
   :id           Used to find an object that has an "id=" attribute. Since each
                 id should be unique, according to the XHTML specification,
                 this is recommended as the most reliable method to find an
                 object.
   :name         Used to find an object that has a "name=" attribute.  This is
                 useful for older versions of HTML, but "name" is deprecated
                 in XHTML.
   :value        Used to find a text field with a given default value, or a
                 button with a given caption
   :index        Used to find the nth object of the specified type on a page.
                 For example, button(:index, 2) finds the second button.
                 Current versions of WATIR use 1-based indexing, but future
                 versions will use 0-based indexing.
   :before_text  Used to find the object immediately before the specified text.
                 Note:  This fails if the text is in a table cell.
   :after_text   Used to find the object immediately before the specified text.
                 Note:  This fails if the text is in a table cell.

   Note that the XHTML specification requires that tags and their attributes be
   in lower case.  WATIR doesn't enforce this; WATIR will find tags and
   attributes whether they're in upper, lower, or mixed case.  This is either
   a bug or a feature.

   WATIR uses Microsoft's Document Object Model (DOM) as implemented by Internet
   Explorer.  For further information on Internet Explorer and on the DOM, go to
   the following Web pages:

   http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/webbrowser.asp
   http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/overview/overview.asp

   WATIR supports command-line options:

   -b  (background)   Run Internet Explorer invisibly
   -f  (fast)         By default, WATIR types slowly and pauses briefly between
                      actions.  This switch removes the delays and sets WATIR
                      to run at full speed.  The set_fast_speed method of the
                      IE object performs the same function; set_slow_speed
                      returns WATIR to its default behaviour.
   -x  (spinner)      Adds a spinner that displays in the command window when
                      pages are waiting to be loaded.

=end

# Use our modified win32ole library
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'watir', 'win32ole')

require 'win32ole'
require 'logger'
require 'watir/winClicker'
require 'watir/WindowHelper'
require 'watir/exceptions'
require 'container'

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

class Integer
    def matches (x)
        return self == x
    end
end

# ARGV needs to be deleted to enable the Test::Unit functionality that grabs
# the remaining ARGV as a filter on what tests to run.
# Note: this means that watir must be require'd BEFORE test/unit.
def command_line_flag(switch)
    setting = ARGV.include?(switch) 
    ARGV.delete(switch)
    return setting
end            

# Constant to make Internet explorer minimise. -b stands for background
$HIDE_IE = command_line_flag('-b') 

# Constant to enable/disable the spinner
$ENABLE_SPINNER = command_line_flag('-x') 

# Constant to set fast speed
$FAST_SPEED = command_line_flag('-f')

# Variable to setting which browser we are using.
$Browser = ""

# Eat the -s command line switch (deprecated)
command_line_flag('-s')

module Watir
    include Watir::Exception
    
    @@dir = File.expand_path(File.dirname(__FILE__))

    def self.until_with_timeout(timeout) # block
        start_time = Time.now
        until yield or Time.now - start_time > timeout do
            sleep 0.05
        end
    end

    def self.avoids_error(error) # block
        begin
            yield
            true
        rescue error
            false
        end
    end
    
    # BUG: this won't work right until the null objects are pulled out
    def exists?
        begin
            yield
            true
        rescue
            false
        end
    end

    class WatirLogger < Logger
        def initialize(  filName , logsToKeep, maxLogSize )
            super( filName , logsToKeep, maxLogSize )
            self.level = Logger::DEBUG
            self.datetime_format = "%d-%b-%Y %H:%M:%S"
            self.debug("Watir starting")
        end
    end
    
    class DefaultLogger < Logger
        def initialize()
            super(STDERR)
            self.level = Logger::WARN
            self.datetime_format = "%d-%b-%Y %H:%M:%S"
            self.info "Log started"
        end
    end
    
    # Displays the spinner object that appears in the console when a page is being loaded
    class Spinner
        def initialize(enabled = true)
            @s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
            @i=0
            @enabled = enabled
        end
        
        # reverse the direction of spinning
        def reverse
            @s.reverse!
        end
        
        def spin
            print self.next if @enabled
        end

        # get the next character to display
        def next
            @i=@i+1
            @i=0 if @i>@s.length-1
            return @s[@i]
        end
    end

    # This class is the main Internet Explorer Controller
    # An instance of this must be created to access Internet Explorer.
    class IE
        include Watir::Exception
        include Container 

        @@extra = nil
        
        # Maximum number of seconds to wait when attaching to a window
        @@attach_timeout = 0.2
        def self.attach_timeout
            @@attach_timeout
        end
        def self.attach_timeout=(timeout)
            @@attach_timeout = timeout
        end

        # The revision number (according to CVS)
        REVISION = "$Revision: 1.269 $"

        # The Release number
        VERSION = "1.4"
        
        # Used internally to determine when IE has finished loading a page
        READYSTATE_COMPLETE = 4         
                
        # Whether the spinner is on and off
        attr_accessor :enable_spinner

        # The download time for the last command
        attr_reader :down_load_time
        
        # Whether the speed is :fast or :slow
        attr_reader :speed
        
        # the ole internet explorer object        
        attr_reader :ie

        # access to the logger object
        attr_accessor :logger

        # this contains the list of unique urls that have been visited
        attr_reader :url_list                        

        def initialize(suppress_new_window=nil)
            require 'IEBaseElement.rb'
            require 'htmlelements.rb'
                       
            unless suppress_new_window
                create_browser_window
                set_defaults
            end
            
            $Browser = "IE"
        end
        
        # Create a new IE Window, starting at the specified url.
        # If no url is given, start empty.
        def self.start(url = nil)
            ie = new
            ie.goto(url) if url
            return ie
        end
        
        # Attach to an existing IE window, either by url or title.
        # IE.attach(:url, 'http://www.google.com')
        # IE.attach(:title, 'Google') 
        def self.attach(how, what)
            ie = new(true) # don't create window
            ie.attach_init(how, what)
            return ie
        end   

        # this method is used internally to attach to an existing window
        # dont make private
        def attach_init( how, what )
            attach_browser_window(how, what)
            set_defaults
            wait                        
        end        
        
        def set_defaults
            @ole_object = nil

            @enable_spinner = $ENABLE_SPINNER
            @error_checkers= []

            @ie.visible = ! $HIDE_IE
            @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
            if $FAST_SPEED
                set_fast_speed
            else
                set_slow_speed
            end

            @logger = DefaultLogger.new()

            @url_list = []

            # IE inserts some element whose tagName is empty and just acts as block level element
            # Probably some IE method of cleaning things
            # To pass the same to REXML we need to give some name to empty tagName  
            @empty_tag_name = "DUMMY"
            
            # add an error checker for http navigation errors, such as 404, 500 etc
            navigation_checker=Proc.new{ |ie|
                if ie.document.frames.length > 1
                    1.upto ie.document.frames.length do |i|
                        check_for_http_error(ie.frame(:index, i)  )
                    end
                else
                    check_for_http_error(ie)
                end
             }

            add_checker(  navigation_checker )       

        end
        private :set_defaults        
        
        # This method checks the currently displayed page for http errors, 404, 500 etc
        # It gets called internally by the wait method, so a user does not need to call it explicitly
        def check_for_http_error(ie)
            url=ie.document.url 
            # puts "url is " + url
            if /shdoclc.dll/.match(url)
                #puts "Match on shdoclc.dll"
                m = /id=IEText.*?>(.*?)</i.match(ie.html)
                if m
                
                    #puts "Error is #{m[1]}"
                    raise NavigationException , m[1]
                end
            end
        end

        def speed=(how_fast)
            case how_fast
            when :fast : set_fast_speed
            when :slow : set_slow_speed
            else
              raise ArgumentError, "Invalid speed: #{how_fast}"
            end
        end

        def set_fast_speed
            @typingspeed = 0
            @defaultSleepTime = 0.01
            @speed = :fast
        end            

        def set_slow_speed
            @typingspeed = DEFAULT_TYPING_SPEED
            @defaultSleepTime = DEFAULT_SLEEP_TIME
            @speed = :slow
        end
        
        def visible
            @ie.visible
        end
        def visible=(boolean)
            @ie.visible = boolean
        end
            
        def create_browser_window
            unless @@extra
                @@extra = WIN32OLE.new('InternetExplorer.Application')
                @@extra.visible = false
            end
            @ie = WIN32OLE.new('InternetExplorer.Application')
        end
        private :create_browser_window

        # return window as specified; otherwise nil
        def find_window(how, what)
            shell = WIN32OLE.new("Shell.Application")
            ieTemp = nil
            shell.Windows.each do |aWin| 
                log "Found a window: #{aWin}"
                
                case how
                when :url
                    log "url is: #{aWin.locationURL}\n"
                    ieTemp = aWin if (what.matches(aWin.locationURL) )
                when :title
                    # normal windows explorer shells do not have document
                    title = nil
                    begin
                        title = aWin.document.title
                    rescue WIN32OLERuntimeError
                    end
                    ieTemp = aWin if (what.matches(title) ) 
                else
                    raise ArgumentError
                end
            end
            return ieTemp
        end
        private :find_window

        def attach_browser_window(how, what)
            log "Seeking Window with #{how}: #{what}"
            start_time = Time.now
            ieTemp = nil
            until ieTemp or Time.now - start_time > @@attach_timeout do
              ieTemp = find_window(how, what)
              sleep 0.05 unless ieTemp            
            end
            unless ieTemp
                 raise NoMatchingWindowFoundException,
                 "Unable to locate a window with #{how} of #{what}"
            end
            @ie = ieTemp
        end
        private :attach_browser_window

        # this will find the IEDialog.dll file in its build location
        @@iedialog_file = (File.expand_path(File.dirname(__FILE__)) + "/watir/IEDialog/Release/IEDialog.dll").gsub('/', '\\')
        @@fnFindWindowEx = Win32API.new('user32.dll', 'FindWindowEx', ['l', 'l', 'p', 'p'], 'l')
        @@fnGetUnknown = Win32API.new(@@iedialog_file, 'GetUnknown', ['l', 'p'], 'v')

        def self.attach_modal(title)
            hwnd_modal = 0
            Watir::until_with_timeout(10) do
                hwnd_modal = @@fnFindWindowEx.call(0, 0, nil, title)
                hwnd_modal > 0
            end

            intPointer = " " * 4 # will contain the int value of the IUnknown*
            @@fnGetUnknown.call(hwnd_modal, intPointer)

            intArray = intPointer.unpack('L')
            intUnknown = intArray.first
            raise "Unable to attach to Modal Window #{title}" unless intUnknown > 0

            htmlDoc = WIN32OLE.connect_unknown(intUnknown)
            ModalPage.new(htmlDoc)
        end
        
        # deprecated: use logger= instead
        def set_logger(logger)
            @logger = logger
        end

        def log (what)
            @logger.debug(what) if @logger
        end
        
        #
        # Accessing data outside the document
        #
        
        # Return the title of the document
        def title
            @ie.document.title
        end
        
        # Return the status of the window, typically from the status bar at the bottom.
        def status
            raise NoStatusBarException if !@ie.statusBar
            return @ie.statusText
        end

        #
        # Navigation
        #

        # Navigate to the specified URL.
        #  * url  - string - the URL to navigate to
        def goto(url)
            @ie.navigate(url)
            wait()
            sleep 0.2
            return @down_load_time
        end
        
        # Go to the previous page - the same as clicking the browsers back button
        # an WIN32OLERuntimeError exception is raised if the browser cant go back
        def back
            @ie.GoBack()
            wait
        end

        # Go to the next page - the same as clicking the browsers forward button
        # an WIN32OLERuntimeError exception is raised if the browser cant go forward
        def forward
            @ie.GoForward()
            wait
        end
        
        # Refresh the current page - the same as clicking the browsers refresh button
        # an WIN32OLERuntimeError exception is raised if the browser cant refresh
        def refresh
            @ie.refresh2(3)
            wait
        end
        
        # clear the list of urls that we have visited
        def clear_url_list
            @url_list.clear
        end

        # Closes the Browser
        def close
            @ie.quit
        end
        
        # Maximize the window (expands to fill the screen)
        def maximize; set_window_state :SW_MAXIMIZE; end
        
        # Minimize the window (appears as icon on taskbar)
        def minimize; set_window_state :SW_MINIMIZE; end

        # Restore the window (after minimizing or maximizing)
        def restore;  set_window_state :SW_RESTORE;  end
        
        # Make the window come to the front
        def bring_to_front
    		autoit.WinActivate title, ''		
     	end

     	def front?
    		1 == autoit.WinActive(title, '')		
     	end	     	         

        private
        def set_window_state (state)
		    autoit.WinSetState title, '', autoit.send(state)			
        end

        private
        def autoit
            Watir::autoit
        end        
                
		# Send key events to IE window. 
		# See http://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm
		# for complete documentation on keys supported and syntax.
        public
        def send_keys (key_string)
            autoit.WinActivate title
            autoit.Send key_string
        end

        def dir
            return File.expand_path(File.dirname(__FILE__))
        end
        
        #
        # Document and Document Data
        #
        
        # Return the current document
        public
        def document
            return @ie.document
        end
           
        # returns the current url, as displayed in the address bar of the browser 
        def url
            return @ie.LocationURL
        end

        # Search the current page for specified text or regexp.
        # Returns the index if the specified text was found.
        # Returns matchdata object if the specified regexp was found.
        # In either case, this method is suitable for use in an if or assert statement.
        #  * target - string or regular expression - the string to look for
        def contains_text(target)
            returnValue = false
            retryCount = 0
            begin
                retryCount += 1
                returnValue = 
                if target.kind_of? Regexp
                    self.text.match(target)
                elsif target.kind_of? String
                    self.text.index(target)
                else
                    raise MissingWayOfFindingObjectException
                end 
            # bug we should remove this...
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
        def wait(no_sleep = false)
            begin
                @down_load_time=0
                pageLoadStart = Time.now
                @pageHasReloaded= false
                
                s= Spinner.new(@enable_spinner)
                while @ie.busy
                    @pageHasReloaded = true
                    sleep 0.02
                    s.spin
                end
                s.reverse
                
                log "wait: readystate=" + @ie.readyState.to_s 
                until @ie.readyState == READYSTATE_COMPLETE
                    @pageHasReloaded = true
                    sleep 0.02
                    s.spin
                end
                sleep 0.02
                
                until Watir::avoids_error(WIN32OLERuntimeError) {@ie.document} do
                    sleep 0.02
                end
                
                until @ie.document.readyState == "complete"
                    sleep 0.02
                    s.spin
                end
                                
                if @ie.document.frames.length > 1
                    begin
                        0.upto @ie.document.frames.length-1 do |i|
                            until @ie.document.frames[i.to_s].document.readyState == "complete"
                                sleep 0.02
                                s.spin
                            end
                            @url_list << @ie.document.frames[i.to_s].document.url unless url_list.include?(@ie.document.frames[i.to_s].document.url)
                        end
                    rescue=>e
                        #puts 'Setting rexmlDomobject to nil'. Used for finding element using xpath.
                        @rexmlDomobject = nil
                        @logger.warn 'frame error in wait'   + e.to_s + "\n" + e.backtrace.join("\n")
                    end
                else
                    @url_list << @ie.document.url unless @url_list.include?(@ie.document.url)
                end
                @down_load_time = Time.now - pageLoadStart 

                run_error_checks

                print "\b" unless @enable_spinner == false
                
                s=nil
                #Variables used for supporting xpath queries.
                #puts 'Setting rexmlDomobject to nil'
                @rexmlDomobject = nil
            rescue WIN32OLERuntimeError => e
                @logger.info "runtime error in wait: #{e}\n#{e.backtrace.join("\\\n")}"
            end
            sleep 0.01
            sleep @defaultSleepTime unless no_sleep == true
        end

        # Error checkers

        # this method runs the predefined error checks
        def run_error_checks
            @error_checkers.each do |e|
                e.call(self)
            end
        end

        # this method is used to add an error checker that gets executed on every page load
        # *  checker   Proc Object, that contains the code to be run 
        def add_checker( checker) 
            @error_checkers << checker
        end
        
        # this allows a checker to be disabled
        # *  checker   Proc Object, the checker that is to be disabled
        def disable_checker( checker )
            @error_checkers.delete(checker)
        end

        # The HTML of the current page
        def html
            return document.body.parentelement.outerhtml
        end
        
        # The text of the current document
        def text
            return document.body.parentelement.innertext.strip
        end

        #
        # Show me state
        #        
        
        # This method is used to display the available html frames that Internet Explorer currently has loaded.
        # This method is usually only used for debugging test scripts.
        def show_frames
            if allFrames = document.frames
                count = allFrames.length
                puts "there are #{count} frames"
                for i in 0..count-1 do  
                    begin
                        fname = allFrames[i.to_s].name.to_s
                        puts "frame  index: #{i + 1} name: #{fname}"
                    rescue => e
                        puts "frame  index: #{i + 1} --Access Denied--" if e.to_s.match(/Access is denied/)
                    end
                end
            else
                puts "no frames"
            end
        end
        
        # Show all forms displays all the forms that are on a web page.
        def show_forms
            if allForms = document.forms
                count = allForms.length
                puts "There are #{count} forms"
                for i in 0..count-1 do
                    wrapped = FormWrapper.new(allForms.item(i))
                    puts "Form name: #{wrapped.name}"
                    puts "       id: #{wrapped.id}"
                    puts "   method: #{wrapped.method}"
                    puts "   action: #{wrapped.action}"
                end
            else
                puts "No forms"
            end
        end

        # this method shows all the images availble in the document
        def show_images
            doc = document
            index = 1
            doc.images.each do |l|
                puts "image: name: #{l.name}"
                puts "         id: #{l.invoke("id")}"
                puts "        src: #{l.src}"
                puts "      index: #{index}"
                index += 1
            end
        end
        
        # this method shows all the links availble in the document
        def show_links 
            props = ["name", "id", "href"]
            print_sizes = [12, 12, 60]
            doc = document
            index = 0
            text_size = 60
            # draw the table header
            s = "index".ljust(6) 
            props.each_with_index do |p, i|
                s += p.ljust(print_sizes[i]) 
            end
            s += "text/src".ljust(text_size)
            s += "\n"
            
            # now get the details of the links
            doc.links.each do |n|
                index += 1
                s = s + index.to_s.ljust(6)
                props.each_with_index do |prop, i|
                    printsize = print_sizes[i]
                    begin
                        p = n.invoke(prop)
                        temp_var = "#{p}".to_s.ljust(printsize)
                    rescue
                        # this object probably doesnt have this property
                        temp_var = "".to_s.ljust(printsize)
                    end
                    s += temp_var
                end
                s += n.innerText
                if n.getElementsByTagName("IMG").length > 0
                    s += " / " + n.getElementsByTagName("IMG")[0.to_s].src
                end
                s += "\n"
            end
            puts  s
        end

        # this method shows the name, id etc of the object that is currently active - ie the element that has focus
        # its mostly used in irb when creating a script
        def show_active
            s = "" 
            
            current = document.activeElement
            begin
                s += current.invoke("type").to_s.ljust(16)
            rescue
            end
            props = ["name", "id", "value", "alt", "src", "innerText", "href"]
            props.each do |prop|
                begin
                    p = current.invoke(prop)
                    s += "  " + "#{prop}=#{p}".to_s.ljust(18)
                rescue
                    #this object probably doesnt have this property
                end
            end
            s += "\n"
        end
        
        # this method shows all the divs availble in the document
        def show_divs
            divs = document.getElementsByTagName("DIV")
            puts "Found #{divs.length} div tags"
            index = 1
            divs.each do |d|
                puts "#{index}  id=#{d.invoke('id')}      class=#{d.invoke("className")}"
                index += 1
            end
        end

        # this method is used to show all the tables that are available
        def show_tables
            tables = document.getElementsByTagName("TABLE")
            puts "Found #{tables.length} tables"
            index = 1
            tables.each do |d|
                puts "#{index}  id=#{d.invoke('id')}      rows=#{d.rows.length}   columns=#{d.rows["0"].cells.length }"
                index += 1
            end
        end

		def show_pres
			pres = document.getElementsByTagName( "PRE" )
			puts "Found #{ pres.length } pre tags"
			index = 1
			pres.each do |d|
                puts "#{index}   id=#{d.invoke('id')}      class=#{d.invoke("className")}"
                index+=1
            end
        end

        # this method shows all the spans availble in the document
        def show_spans
            spans = document.getElementsByTagName("SPAN")
            puts "Found #{spans.length} span tags"
            index = 1
            spans.each do |d|
                puts "#{index}   id=#{d.invoke('id')}      class=#{d.invoke("className")}"
                index += 1
            end
        end

        def show_labels
            labels = document.getElementsByTagName("LABEL")
            puts "Found #{labels.length} label tags"
            index = 1
            labels.each do |d|
                puts "#{index}  text=#{d.invoke('innerText')}      class=#{d.invoke("className")}  for=#{d.invoke("htmlFor")}"
                index += 1
            end
        end

        #
        # This method gives focus to the frame
        # It may be removed and become part of the frame object
        def focus
            document.activeElement.blur
            document.focus
        end
       
        #      
        # Functions written for using xpath for getting the elements.
        #

        # Get the Rexml object.
        def rexml_document_object
            #puts "Value of rexmlDomobject is : #{@rexmlDomobject}"
            if @rexmlDomobject == nil
                create_rexml_document_object()
            end
            return @rexmlDomobject
        end
        
        # Create the Rexml object if it is nil. This method is private so can be called only
        # from rexml_document_object method.
        def create_rexml_document_object
            require 'rexml/document'
            if @rexmlDomobject == nil
                #puts 'Here creating rexmlDomobject'
                htmlSource = "<HTML>"
                htmlSource = html_source(document.body,htmlSource," ")
                htmlSource += "\n</HTML>\n"
                #puts htmlSource
                #Give htmlSource as input to Rexml.
                begin
                    @rexmlDomobject = REXML::Document.new(htmlSource)
                rescue  => e
                    #puts e.to_s
                    error = File.open("error.xml","w")
                    error.print(htmlSource)
                    error.close()
                    #puts htmlSource
                    #gets   
                end
            end
        end
        private :create_rexml_document_object
       
        #Function Tokenizes the tag line and returns array of tokens.
        #Token could be either tagName or "=" or attribute name or attribute value
        #Attribute value could be either quoted string or single word
        def tokenize_tagline(outerHtml)
            outerHtml = outerHtml.gsub(/\n|\r/," ")
            #removing "< symbol", opening of current tag
            outerHtml =~ /^\s*<(.*)$/
            outerHtml = $1
            tokens = Array.new
            i = startOffset  = 0
            length = outerHtml.length
            #puts outerHtml
            parsingValue = false
            while i < length do
                i +=1 while (i < length && outerHtml[i,1] =~ /\s/)
                next if i == length
                currentToken = outerHtml[i,1]

                #Either current tag has been closed or user has not closed the tag > 
                # and we have received the opening of next element
                break if currentToken =~ /<|>/

                #parse quoted value
                if(currentToken == "\"" || currentToken == "'")
                    parsingValue = false
                    quote = currentToken
                    startOffset = i
                    i += 1
                    i += 1 while (i < length && (outerHtml[i,1] != quote || outerHtml[i-1,1] == "\\"))
                    if i == length 
                        tokens.push  quote + outerHtml[startOffset..i-1]
                    else    
                        tokens.push  outerHtml[startOffset..i]
                    end 
                elsif currentToken == "="
                    tokens.push "=" 
                    parsingValue = true
                else
                    startOffset = i
                    i += 1 while(i < length && !(outerHtml[i,1] =~ /\s|=|<|>/)) if !parsingValue
                    i += 1 while(i < length && !(outerHtml[i,1] =~ /\s|<|>/)) if parsingValue
                    parsingValue = false
                    i -= 1
                    tokens.push outerHtml[startOffset..i]
                end
                i += 1
            end
            return tokens
        end 
        private :tokenize_tagline

        # This function get and clean all the attributes of the tag.
        def all_tag_attributes(outerHtml)
            tokens = tokenize_tagline(outerHtml)
            #puts tokens
            tagLine = ""
            count = 1
            tokensLength = tokens.length
            expectedEqualityOP= false
            while count < tokensLength do
                if expectedEqualityOP == false
                    #print Attribute Name
                    # If attribute name is valid. Refer: http://www.w3.org/TR/REC-xml/#NT-Name
                    if tokens[count] =~ /^(\w|_|:)(.*)$/
                        tagLine += " #{tokens[count]}"                                
                        expectedEqualityOP = true
                    end
                elsif tokens[count] == "=" 
                    count += 1
                    if count == tokensLength
                        tagLine += "=\"\""
                    elsif(tokens[count][0,1] == "\"" || tokens[count][0,1] == "'")
                        tagLine += "=#{tokens[count]}"
                    else
                        tagLine += "=\"#{tokens[count]}\""
                    end
                    expectedEqualityOP = false
                else
                    #Opps! equality was expected but its not there. 
                    #Set value same as the attribute name e.g. selected="selected"
                    tagLine += "=\"#{tokens[count-1]}\""
                    expectedEqualityOP = false
                    next
                end
                count += 1 
            end
            tagLine += "=\"#{tokens[count-1]}\" " if expectedEqualityOP == true
            #puts tagLine
            return tagLine
        end
        private :all_tag_attributes

        # This function is used to escape the characters that are not valid XML data.
        def xml_escape (str)
            str = str.gsub(/&/,'&amp;')
            str = str.gsub(/</,'&lt;')
            str = str.gsub(/>/,'&gt;')
            str = str.gsub(/"/, '&quot;')
            str
        end
        private :xml_escape

        #Returns HTML Source 
        #Traverse the DOM tree rooted at body element  
        #and generate the HTML source. 
        #element: Represent Current element
        #htmlString:HTML Source
        #spaces:(Used for debugging). Helps in indentation  
        def html_source(element, htmlString, spaceString)
            begin
                tagLine = ""
                outerHtml = ""
                tagName = ""
                begin
                    tagName = element.tagName.downcase
                    tagName = @empty_tag_name if tagName == ""  
                    # If tag is a mismatched tag.
                    if !(tagName =~ /^(\w|_|:)(.*)$/)
                        return htmlString
                    end
                rescue
                    #handling text nodes
                    htmlString +=  xml_escape(element.to_s)
                    return htmlString
                end
                #puts tagName
                #Skip comment and script tag
                if tagName =~ /^!/ || tagName== "script" || tagName =="style"           
                    return htmlString
                end
                #tagLine += spaceString
                begin
                    outerHtml = all_tag_attributes(element.outerHtml) if tagName != @empty_tag_name
                    tagLine += "\n<#{tagName} #{outerHtml}"

                    canHaveChildren = element.canHaveChildren
                    if canHaveChildren 
                        tagLine += "> \n" 
                    else
                        tagLine += "/> \n" #self closing tag
                    end
                    #spaceString += spaceString
                    htmlString += tagLine
                    childElements = element.childnodes
                    childElements.each do |child|
                    htmlString = html_source(child,htmlString,spaceString)
                    end
                rescue
                    canHaveChildren = false if canHaveChildren == nil     
                end
                if canHaveChildren
                #tagLine += spaceString
                    tagLine ="\n</" + tagName + ">\n"
                    htmlString += tagLine 
                end
                return htmlString
            rescue => e
                puts e.to_s 
            end
            return htmlString
        end
        private :html_source
 
        # return the first element that matches the xpath
        def element_by_xpath(xpath)
            temp = elements_by_xpath(xpath)
            temp = temp[0] if temp
            return temp
        end
        
        # execute xpath and return an array of elements
        def elements_by_xpath(xpath)
            doc = rexml_document_object()
            modifiedXpath = ""
            selectedElements = Array.new
            doc.elements.each(xpath) do |element|
                modifiedXpath  =  element.xpath
                temp = element_by_absolute_xpath(modifiedXpath)
                selectedElements << temp if temp != nil
            end
            #puts selectedElements.length
            if selectedElements.length == 0
                return nil
            else
                return selectedElements
            end
        end

        # Method that iterates over IE DOM object and get the elements for the given
        # xpath.
        def element_by_absolute_xpath(xpath)
            curElem = nil

            #puts "Hello; Given xpath is : #{xpath}"
            doc = document()
            curElem = doc.getElementsByTagName("body")["0"]
            xpath =~ /^.*\/body\[?\d*\]?\/(.*)/
            xpath = $1

            if xpath == nil
                puts "Function Requires absolute XPath."
                return
            end

            arr = xpath.split(/\//)
            return nil if arr.length == 0

            lastTagName = arr[arr.length-1].to_s.upcase

            # lastTagName is like tagName[number] or just tagName. For the first case we need to
            # separate tagName and number.
            lastTagName =~ /(\w*)\[?\d*\]?/
            lastTagName = $1
            #puts lastTagName

            for element in arr do
                element =~ /(\w*)\[?(\d*)\]?/
                tagname = $1
                tagname = tagname.upcase

                if $2 != nil && $2 != ""
                    index = $2
                    index = "#{index}".to_i - 1
                else
                    index = 0
                end

                #puts "#{element} #{tagname} #{index}"
                allElemns = curElem.childnodes
                if allElemns == nil || allElemns.length == 0
                    puts "#{element} is null"
                    next # Go to next element
                end

                #puts "Current element is : #{curElem.tagName}"
                allElemns.each do |child|
                    gotIt = false
                    begin
                        curTag = child.tagName
                        curTag = @empty_tag_name if curTag == ""  
                    rescue
                        next
                    end
                    #puts child.tagName
                    if curTag == tagname
                        index-=1
                        if index < 0
                            curElem = child
                            break
                        end
                    end
                end

                #puts "Node selected at index #{index.to_s} : #{curElem.tagName}"
            end
            begin
                if curElem.tagName == lastTagName
                    #puts curElem.tagName
                    return curElem
                else
                    return nil
                end
            rescue
                return nil
            end
        end
        private :element_by_absolute_xpath

        def eval_in_spawned_process(command)
            command.strip!
            load_path_code = _code_that_copies_readonly_array($LOAD_PATH, '$LOAD_PATH')
            ruby_code = "require 'watir'; ie = Watir::IE.attach(:title, '#{title}'); ie.instance_eval(#{command.inspect})"
            exec_string = "rubyw -e #{(load_path_code + ';' + ruby_code).inspect}"
            Thread.new { system(exec_string) }
        end
                
    end # class IE
    
    #
    # Angrez: Added class for Mozilla
    #
    class Firefox
       
        include Container
        
        # XPath Result type. Return only first node that matches the xpath expression.
        # More details: "http://developer.mozilla.org/en/docs/DOM:document.evaluate"
        FIRST_ORDERED_NODE_TYPE = 9
        
        def initialize(requireSocket = true)
            require 'MozillaBaseElement.rb'
            require 'htmlelements.rb'
            require 'socket'
                   
            # JSSH listens on port 9997. Create a new socket to connect to port 9997.
            $jssh_socket = TCPSocket::new(MACHINE_IP, "9997")
            read_socket()
            @@current_window = 0
            @@already_closed = false
            @@total_windows = 1
            # This will store the information about the window.
            @@window_stack = Array.new
            @@window_stack.push(0)
            @jspopup_handle = nil
            $Browser = "Firefox"
        end

        def goto(url)

            set_defaults()
            # Load the given url.
            $jssh_socket.send("#{BROWSER_VAR}.loadURI(\"#{url}\");\n" , 0)
            read_socket()

            wait()
        end
       
        def set_defaults
            
            # Get the first window in variable WINDOW_VAR.
            $jssh_socket.send("var #{WINDOW_VAR} = getWindows()[#{@@current_window}];\n" , 0)
            read_socket() 
           
            # Get the browser in variable BROWSER_VAR.
            $jssh_socket.send("var #{BROWSER_VAR} = #{WINDOW_VAR}.getBrowser();\n" , 0)
            read_socket()
            
            set_slow_speed()    
        end
 
        def set_slow_speed
            @typingspeed = DEFAULT_TYPING_SPEED
            @defaultSleepTime = DEFAULT_SLEEP_TIME
        end
        
        def set_browser_document
            # Get the browser in variable BROWSER_VAR.
            $jssh_socket.send("var #{BROWSER_VAR} = #{WINDOW_VAR}.getBrowser();\n" , 0)
            read_socket()

            $jssh_socket.send("var #{DOCUMENT_VAR} = #{BROWSER_VAR}.contentDocument;\n" , 0)
            read_socket()

            $jssh_socket.send("var #{BODY_VAR} = #{DOCUMENT_VAR}.body;\n", 0)
            read_socket()
            
            set_slow_speed()
        end
        
        def close()
            # This is the case if some click event has closed the window. Click() function sets the variable
            # alread_closed as true. So in that case just return.
            if @@already_closed
                @@already_closed = false
                return
            end
            
            if @@current_window == 0
                #$jssh_socket.send(" getWindows()[0].close(); \n", 0)
            else
                $jssh_socket.send(" getWindows()[#{@@current_window}].close(); \n", 0)
                read_socket();
                @@current_window = @@window_stack.pop()
                set_defaults()
                set_browser_document()
            end
        end
       
        # Attach to an existing IE window, either by url or title.
        # Firefox.attach(:url, 'http://www.google.com')
        # Firefox.attach(:title, 'Google') 
        # TODO: Add support to attach using url. Currently only Title is supported.
        def attach(how, what)
            find_window(what)
        end

        def find_window(title)
            $jssh_socket.send("var windows = getWindows(); windows.length; \n", 0)
            #read_socket()
            #$jssh_socket.send("windows.length;\n", 0)
            length = read_socket().to_i
            @@total_windows = length
            puts "Length of windows is : #{length}"
            for i in 0..length - 1
                $jssh_socket.send("var title = getWindows()[#{i}].getBrowser().contentDocument.title; title; \n", 0)
                result = read_socket()
                puts "Title is : #{result}"
                if title.match(result)
                    puts "Title is matched. Found window with number : #{i}"
                    @@window_stack.push(@@current_window)
                    @@current_window = i
                    set_defaults()
                    set_browser_document()
                end
            end
            self
        end
        private :find_window
        
        def contains_text(match_text)
            #puts "Text to match is : #{match_text}"
            #puts "Html is : #{self.text}"
            return (match_text.match(self.text) == nil) ? false : true
        end

        def url()
            $jssh_socket.send("#{DOCUMENT_VAR}.URL;\n", 0)
            return read_socket()
        end 

        def title()
            $jssh_socket.send("#{DOCUMENT_VAR}.title;\n", 0)
            return read_socket()
        end

        def text()
            $jssh_socket.send("#{BODY_VAR}.innerHTML;\n", 0)
            return read_socket()
        end

        def wait()
            #puts "In wait function "
            isLoadingDocument = ""
            while isLoadingDocument != "false"
                $jssh_socket.send("#{BROWSER_VAR}.webProgress.isLoadingDocument;\n" , 0)
                isLoadingDocument = read_socket()
                #puts isLoadingDocument
            end
            set_browser_document()
        end
      
        def jspopup_appeared(popupText = "", wait = 2)
            #winclicker = WinClicker.new
            #@jspopup_handle = winclicker.getWindowHandle("JavaScript Application")
            #puts "Handle of window is : #{@jspopup_handle}"
            #if @jspopup_handle == nil || @jspopup_handle == -1
            #    return false
            #else
            #    return true
            #end
            winHelper = WindowHelper.new()
            return winHelper.hasPopupAppeared("[JavaScript Application]",popupText, wait)
        end
 
        def click_jspopup_button(button)
            #winclicker = WinClicker.new

            #if button =~ /ok/i
            #    winclicker.clickWindowsButton_hwnd(@jspopup_handle, "OK")
            #elsif button =~ /cancel/i
            #    winclicker.clickWindowsButton_hwnd(@jspopup_handle, "Cancel")
            #end
            winHelper = WindowHelper.new()
            if button =~ /ok/i
                puts "ok: clicking button #{button}"
                winHelper.push_confirm_button_ok("[JavaScript Application]")
            elsif button =~ /cancel/i
                puts "cancel: clicking button #{button}"
                winHelper.push_confirm_button_cancel("[JavaScript Application]")
            end
            read_socket()
        end 
               
        def document
             Document.new("#{DOCUMENT_VAR}")
        end
       
        # Mozilla browser directly supports XPath query on its DOM. So need need to create
        # the DOM tree as we did with IE.
        #
        def element_by_xpath(xpath)
            $jssh_socket.send("var element = #{DOCUMENT_VAR}.evaluate(\"#{xpath}\", #{DOCUMENT_VAR}, null, #{FIRST_ORDERED_NODE_TYPE}, null).singleNodeValue; element;\n", 0)             
            result = read_socket()
            if(result == "null")
                return nil
            else
                return Element.new("element")
            end
        end
        
    end # Class Firefox
        
    # 
    # MOVETO: watir/popup.rb
    # Module Watir::Popup
    #
    
    # POPUP object
    class PopUp
        def initialize( container )
            @container = container
        end
        
        def button( caption )
            return JSButton.new(  @container.getIE.hwnd , caption )
        end
    end
    
    class JSButton 
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
    
    
    class ElementMapper # Still to be used
        include Container
        
        def initialize wrapper_class, container, how, what
            @wrapper_class = wrapper_class
            @container = container
            @how = how
            @what = what
        end
        
        def method_missing method, *args
            locate
            @wrapper_class.new(@o).send(method, *args)
        end
    end
    

  @@autoit = nil

    def self.autoit
        unless @@autoit
            begin
                @@autoit = WIN32OLE.new('AutoItX3.Control')
            rescue WIN32OLERuntimeError
                _register('AutoItX3.dll')
                @@autoit = WIN32OLE.new('AutoItX3.Control')
            end
        end
        @@autoit
    end

    def self._register(dll)
      system("regsvr32.exe /s "    + "#{@@dir}/watir/#{dll}".gsub('/', '\\'))
    end
    def self._unregister(dll)
      system("regsvr32.exe /s /u " + "#{@@dir}/watir/#{dll}".gsub('/', '\\'))
    end
end

# why won't this work when placed in the module (where it properly belongs)
def _code_that_copies_readonly_array(array, name)
    "temp = Array.new(#{array.inspect}); #{name}.clear; temp.each {|element| #{name} << element}"
end        

require 'watir/camel_case'

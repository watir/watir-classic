=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2004 - 2005, Paul Rogers and Bret Pettichord
  Copyright (c) 2006 - 2007, Bret Pettichord
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. Neither the names Paul Rogers, nor Bret Pettichord nor the names of any 
  other contributors to this software may be used to endorse or promote 
  products derived from this software without specific prior written 
  permission.

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


require 'watir/win32ole'

require 'logger'
require 'watir/winClicker'
require 'watir/exceptions'
require 'watir/utils'
require 'watir/close_all'
require 'watir/waiter'
require 'watir/ie-process'

require 'dl/import'
require 'dl/struct'
require 'Win32API'

class String
  def matches(x)
    return self == x
  end
end

class Regexp
  def matches(x)
    return self.match(x)
  end
end

class Integer
  def matches(x)
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

# Make Internet Explorer minimize. -b stands for background
$HIDE_IE = command_line_flag('-b')

# Run fast
$FAST_SPEED = command_line_flag('-f')

# Eat the -s command line switch (deprecated)
command_line_flag('-s')

require 'watir/logger'
require 'watir/win32'
require 'watir/container'

module Watir
  include Watir::Exception
  
  # Directory containing the watir.rb file
  @@dir = File.expand_path(File.dirname(__FILE__))

  def wait_until(*args)
    Waiter.wait_until(*args) {yield}
  end

  ATTACHER = Waiter.new
  # Like regular Ruby "until", except that a TimeOutException is raised
  # if the timeout is exceeded. Timeout is IE.attach_timeout.
  def self.until_with_timeout # block
    ATTACHER.timeout = IE.attach_timeout
    ATTACHER.wait_until { yield }
  end
      
  class TaggedElementLocator
    include Watir
    include Watir::Exception

    def initialize(container, tag)
      @container = container
      @tag = tag
    end
    
    def set_specifier(how, what)    
      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end
        
      @specifiers = {:index => 1} # default if not specified

      specifiers.each do |how, what|  
        what = what.to_i if how == :index
        how = :href if how == :url
        how = :class_name if how == :class
        
        @specifiers[how] = what
      end

    end

    def each_element tag
      @container.document.getElementsByTagName(tag).each do |ole_element| 
        yield Element.new(ole_element) 
      end
    end    

    def locate
      index_target = @specifiers[:index]

      count = 0
      each_element(@tag) do |element|
        
        catch :next_element do
          @specifiers.each do |how, what|
            next if how == :index
            unless match? element, how, what
              throw :next_element
            end
          end
          count += 1
          unless index_target == count
            throw :next_element
          end
          return element.ole_object          
        end

      end # elements
      nil
    end
    
    def match?(element, how, what)
      begin 
        method = element.method(how)
      rescue NameError
        raise MissingWayOfFindingObjectException,
              "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
      case method.arity
      when 0
        what.matches method.call
       when 1
       	method.call(what)
      else
        raise MissingWayOfFindingObjectException,
              "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
    end

  end  
    
  # A PageContainer contains an HTML Document. In other words, it is a 
  # JavaScript Window.
  module PageContainer
    include Watir::Exception

    # This method checks the currently displayed page for http errors, 404, 500 etc
    # It gets called internally by the wait method, so a user does not need to call it explicitly

    def check_for_http_error
      # check for IE7
      n = self.document.invoke('parentWindow').navigator.appVersion
      m=/MSIE\s(.*?);/.match( n )
      if m and m[1] =='7.0'
        if m=/HTTP (\d\d\d.*)/.match( self.title )
          raise NavigationException, m[1]
        end
      else
        # assume its IE6
        url = self.document.url
        if /shdoclc.dll/.match(url)
          m = /id=IEText.*?>(.*?)</i.match(self.html)
          raise NavigationException, m[1] if m
        end
      end
      false
    end 
    
    # The HTML Page
    def page
      document.documentelement
    end
    private :page
        
    # The HTML of the current page
    def html
      page.outerhtml
    end
    
    # The url of the page object. 
    def url
      page.document.location.href
    end
    
    # The text of the current page
    def text
      page.innertext.strip
    end

    def eval_in_spawned_process(command)
      command.strip!
      load_path_code = _code_that_copies_readonly_array($LOAD_PATH, '$LOAD_PATH')
      ruby_code = "require 'watir'; "
#      ruby_code = "$HIDE_IE = #{$HIDE_IE};" # This prevents attaching to a window from setting it visible. However modal dialogs cannot be attached to when not visible.
      ruby_code << "pc = #{attach_command}; " # pc = page container
      # IDEA: consider changing this to not use instance_eval (it makes the code hard to understand)
      ruby_code << "pc.instance_eval(#{command.inspect})"
      exec_string = "start rubyw -e #{(load_path_code + '; ' + ruby_code).inspect}"
      system(exec_string)
    end
    
    def set_container container
      @container = container
      @page_container = self
    end
    
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
            puts "frame  index: #{i + 1} Access Denied, see http://wiki.openqa.org/display/WTR/FAQ#access-denied" if e.to_s.match(/Access is denied/)
          end
        end
      else
        puts "no frames"
      end
    end

    # Search the current page for specified text or regexp.
    # Returns the index if the specified text was found.
    # Returns matchdata object if the specified regexp was found.
    # 
    # *Deprecated* 
    # Instead use 
    #   IE#text.include? target 
    # or
    #   IE#text.match target
    def contains_text(target)
        if target.kind_of? Regexp
          self.text.match(target)
        elsif target.kind_of? String
          self.text.index(target)
        else
          raise ArgumentError, "Argument #{target} should be a string or regexp."
        end
    end

  end # module

=begin rdoc
   This is Watir, Web Application Testing In Ruby
   http://wtr.rubyforge.org

   Version "$Revision$"
   
   Example:

    # Load the Watir library.
    require "watir"

    # Go to the page you want to test.
    ie = Watir::IE.start("http://myserver/mypage")

    # Enter "Paul" in a text input field named "username".
    ie.text_field(:name, "username").set("Paul")

    # Enter "Ruby Co" in the text input field whose "id" is "company_ID".
    ie.text_field(:id, "company_ID").set("Ruby Co")

    # Click on a link that includes the word "green".
    ie.link(:text, /green/)

    # Click button that is labelled "Cancel".
    ie.button(:value, "Cancel").click

   The Watir::IE class allows your test to read and interact with HTML 
   elements on a page, including their attributes and contents. 
   The class includes many methods for accessing HTML elements, including the
   following:
   
   #button::     <input> tags with type=button, submit, image or reset
   #check_box::  <input> tags with type=checkbox
   #div::        <div> tags
   #form::       <form> tags
   #frame::      frames, including both the <frame> elements and the 
                corresponding pages.
   #hidden::       <input> tags with type=hidden
   #image::        <img> tags
   #label::        <label> tags (including "for" attribute)
   #link::         <a> (anchor) tags
   #p::            <p> (paragraph) tags
   #radio::        <input> tags with the type=radio; known as radio buttons
   #select_list::  <select> tags, known as drop-downs or drop-down lists
   #span::         <span> tags
   #table::        <table> tags, including +row+ and +cell+ methods for accessing
                nested elements.
   #text_field   <input> tags with the type=text (single-line), type=textarea 
                (multi-line), and type=password 
   #map::          <map> tags
   #area::         <area> tags
   #li::           <li> tags

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
   :xpath        Uses xpath (see separate doc)

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
=end
  class IE
    include Watir::Exception
    include Container
    include PageContainer
    
    def self.quit
    end
    
    # Maximum number of seconds to wait when attaching to a window
    def self.reset_attach_timeout
      @@attach_timeout = 2.0
    end
    reset_attach_timeout
    def self.attach_timeout
      @@attach_timeout
    end
    def self.attach_timeout=(timeout)
      @@attach_timeout = timeout
    end
    
    # The revision number (according to Subversion)
    REVISION_STRING = '$Revision$'
    REVISION_STRING.scan(/Revision: (\d*)/)
    REVISION = $1 or 'unknown'
    
    # The Release number
    VERSION_SHORT = '1.5.2'
    VERSION = VERSION_SHORT + '.' + REVISION
    
    # Used internally to determine when IE has finished loading a page
    READYSTATE_COMPLETE = 4
    
    # TODO: the following constants should be able to be specified by object (not class)
    
    # The delay when entering text on a web page when speed = :slow.
    DEFAULT_TYPING_SPEED = 0.08
    
    # The default time we wait after a page has loaded when speed = :slow.
    DEFAULT_SLEEP_TIME = 0.1
    
    # The default color for highlighting objects as they are accessed.
    HIGHLIGHT_COLOR = 'yellow'
    
    # IE inserts some element whose tagName is empty and just acts as block level element
    # Probably some IE method of cleaning things
    # To pass the same to REXML we need to give some name to empty tagName
    EMPTY_TAG_NAME = "DUMMY"
    
    # The time, in seconds, it took for the new page to load after executing the
    # the last command
    attr_reader :down_load_time
    
    # Whether the speed is :fast or :slow
    attr_reader :speed
    
    # the OLE Internet Explorer object
    attr_accessor :ie
    
    # access to the logger object
    attr_accessor :logger
    
    # this contains the list of unique urls that have been visited
    attr_reader :url_list
    
    # Create a new IE window. Works just like IE.new in Watir 1.4.
    def self.new_window
      ie = new true
      ie._new_window_init
      ie
    end
    
    # Create an IE browser.
    def initialize suppress_new_window=nil 
      _new_window_init unless suppress_new_window 
    end
    
    def _new_window_init
      create_browser_window
      set_defaults
      goto 'about:blank' # this avoids numerous problems caused by lack of a document
    end
    
    # Create a new IE Window, starting at the specified url.
    # If no url is given, start empty.
    def self.start url=nil
      start_window url
    end
    
    # Create a new IE window, starting at the specified url.
    # If no url is given, start empty. Works like IE.start in Watir 1.4.
    def self.start_window url=nil
      ie = new_window
      ie.goto url if url
      ie
    end

    # Create a new IE window in a new process. 
    # This method will not work when
    # Watir/Ruby is run under a service (instead of a user).
    def self.new_process
      ie = new true
      ie._new_process_init
      ie
    end
    
    def _new_process_init
      iep = Process.start
      @ie = iep.window
      @process_id = iep.process_id
      set_defaults
      goto 'about:blank'      
    end
    
    # Create a new IE window in a new process, starting at the specified URL. 
    # Same as IE.start.
    def self.start_process url=nil
      ie = new_process
      ie.goto url if url
      ie
    end
    
    # Return a Watir::IE object for an existing IE window. Window can be
    # referenced by url, title, or window handle.
    # Second argument can be either a string or a regular expression in the 
    # case of of :url or :title. 
    # IE.attach(:url, 'http://www.google.com')
    # IE.attach(:title, 'Google')
    # IE.attach(:hwnd, 528140)
    # This method will not work when
    # Watir/Ruby is run under a service (instead of a user).
    def self.attach how, what
      ie = new true # don't create window
      ie._attach_init(how, what)
      ie
    end
    
    # this method is used internally to attach to an existing window
    def _attach_init how, what
      attach_browser_window how, what
      set_defaults
      wait
    end

    # Return an IE object that wraps the given window, typically obtained from
    # Shell.Application.windows.
    def self.bind window
      ie = new true
      ie.ie = window
      ie.set_defaults
      ie
    end
  
    def create_browser_window
      @ie = WIN32OLE.new('InternetExplorer.Application')
    end
    private :create_browser_window
    
    def set_defaults
      self.visible = ! $HIDE_IE
      @ole_object = nil
      @page_container = self
      @error_checkers = []
      @activeObjectHighLightColor = HIGHLIGHT_COLOR

      if $FAST_SPEED
        set_fast_speed
      else
        set_slow_speed
      end
      
      @logger = DefaultLogger.new
      @url_list = []
    end

    def speed= how_fast
      case how_fast
      when :fast : set_fast_speed
      when :slow : set_slow_speed
      else
        raise ArgumentError, "Invalid speed: #{how_fast}"
      end
    end
    
    # deprecated: use speed = :fast instead
    def set_fast_speed
      @typingspeed = 0
      @defaultSleepTime = 0.01
      @speed = :fast
    end

    # deprecated: use speed = :slow instead    
    def set_slow_speed
      @typingspeed = DEFAULT_TYPING_SPEED
      @defaultSleepTime = DEFAULT_SLEEP_TIME
      @speed = :slow
    end
    
    def visible
      @ie.visible
    end
    def visible=(boolean)
      @ie.visible = boolean if boolean != @ie.visible
    end
    
    # Yields successively to each IE window on the current desktop. Takes a block.
    # This method will not work when
    # Watir/Ruby is run under a service (instead of a user).
	# Yields to the window and its hwnd.
    def self.each
      shell = WIN32OLE.new('Shell.Application')
      shell.Windows.each do |window|
        next unless (window.path =~ /Internet Explorer/ rescue false)
        next unless (hwnd = window.hwnd rescue false)
        ie = IE.bind(window)
        ie.hwnd = hwnd
        yield ie
      end
    end

    # return internet explorer instance as specified. if none is found, 
    # return nil.
    # arguments:
    #   :url, url -- the URL of the IE browser window
    #   :title, title -- the title of the browser page
    #   :hwnd, hwnd -- the window handle of the browser window.
    # This method will not work when
    # Watir/Ruby is run under a service (instead of a user).
    def self.find(how, what)
      ie_ole = IE._find(how, what)
      IE.bind ie_ole if ie_ole
    end

    def self._find(how, what)
      ieTemp = nil
      IE.each do |ie|
        window = ie.ie
        
        case how
        when :url
          ieTemp = window if (what.matches(window.locationURL))
        when :title
          # normal windows explorer shells do not have document
          # note window.document will fail for "new" browsers
          begin
            title = window.locationname
            title = window.document.title
          rescue WIN32OLERuntimeError
          end
          ieTemp = window if what.matches(title)
        when :hwnd
          begin
            ieTemp = window if what == window.HWND
          rescue WIN32OLERuntimeError
          end
        else
          raise ArgumentError
        end
      end
      return ieTemp
    end
    
    def attach_browser_window how, what 
      log "Seeking Window with #{how}: #{what}"
      ieTemp = nil
      begin
        Watir::until_with_timeout do
          ieTemp = IE._find how, what
        end
      rescue TimeOutException
        raise NoMatchingWindowFoundException,
                 "Unable to locate a window with #{how} of #{what}"
      end
      @ie = ieTemp
    end
    private :attach_browser_window
    
    # Return the current window handle
    def hwnd
      raise "Not attached to a browser" if @ie.nil? 
      @hwnd ||= @ie.hwnd
    end
    attr_writer :hwnd
    
    include Watir::Win32

  	# Are we attached to an open browser?
    def exists?
      return false if @closing
      begin
        @ie.name =~ /Internet Explorer/
      rescue WIN32OLERuntimeError
        false
      end
    end
    alias :exist? :exists?
    
    # deprecated: use logger= instead
    def set_logger(logger)
      @logger = logger
    end
    
    def log(what)
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
    #  * url - string - the URL to navigate to
    def goto(url)
      @ie.navigate(url)
      wait
      return @down_load_time
    end
    
    # Go to the previous page - the same as clicking the browsers back button
    # an WIN32OLERuntimeError exception is raised if the browser cant go back
    def back
      @ie.GoBack
      wait
    end
    
    # Go to the next page - the same as clicking the browsers forward button
    # an WIN32OLERuntimeError exception is raised if the browser cant go forward
    def forward
      @ie.GoForward
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
      @closing = true
      @ie.quit
    end
    
    # Maximize the window (expands to fill the screen)
    def maximize
      set_window_state :SW_MAXIMIZE
    end
    
    # Minimize the window (appears as icon on taskbar)
    def minimize
      set_window_state :SW_MINIMIZE
    end
    
    # Restore the window (after minimizing or maximizing)
    def restore
      set_window_state :SW_RESTORE
    end
    
    # Make the window come to the front
    def bring_to_front
      autoit.WinActivate title, ''
    end
    
    def front?
      1 == autoit.WinActive(title, '')
    end
    
    private
    def set_window_state(state)
      autoit.WinSetState title, '', autoit.send(state)
    end
    def autoit
      Watir::autoit
    end
    public
    
    # Send key events to IE window.
    # See http://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm
    # for complete documentation on keys supported and syntax.
    def send_keys(key_string)
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
    def document
      return @ie.document
    end
    
    # returns the current url, as displayed in the address bar of the browser
    def url
      return @ie.LocationURL
    end
        
    #
    # Synchronization
    #
    include Watir::Utils
    
    # Block execution until the page has loaded.
    # =nodoc
    # Note: This code needs to be prepared for the ie object to be closed at 
    # any moment!
    def wait(no_sleep=false)
      @rexmlDomobject = nil
      @down_load_time = 0.0
      a_moment = 0.2 # seconds
      start_load_time = Time.now

      begin      
        while @ie.busy # XXX need to add time out
          sleep a_moment
        end
        until @ie.readyState == READYSTATE_COMPLETE do
          sleep a_moment
        end
        sleep a_moment
        until @ie.document do
          sleep a_moment
        end

        documents_to_wait_for = [@ie.document]

      rescue WIN32OLERuntimeError # IE window must have been closed
        @down_load_time = Time.now - start_load_time
        sleep @defaultSleepTime unless no_sleep
        return @down_load_time
      end
            
      while doc = documents_to_wait_for.shift
        begin
          until doc.readyState == "complete" do
            sleep a_moment
          end
          @url_list << doc.url unless @url_list.include?(doc.url)
          doc.frames.length.times do |n|
            begin
              documents_to_wait_for << doc.frames[n.to_s].document
            rescue WIN32OLERuntimeError
            end
          end
        rescue WIN32OLERuntimeError
        end
      end

      @down_load_time = Time.now - start_load_time
      run_error_checks
      sleep @defaultSleepTime unless no_sleep
      @down_load_time
    end
    
    # Error checkers
    
    # this method runs the predefined error checks
    def run_error_checks
      @error_checkers.each { |e| e.call(self) }
    end
    
    # this method is used to add an error checker that gets executed on every page load
    # *  checker   Proc Object, that contains the code to be run
    def add_checker(checker)
      @error_checkers << checker
    end
    
    # this allows a checker to be disabled
    # *  checker   Proc Object, the checker that is to be disabled
    def disable_checker(checker)
      @error_checkers.delete(checker)
    end
    
    #
    # Show me state
    #
    
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
      puts s
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
        puts "#{index}  id=#{d.invoke('id')}      rows=#{d.rows.length}   columns=#{begin d.rows["0"].cells.length; rescue; end}"
        index += 1
      end
    end
    
    def show_pres
      pres = document.getElementsByTagName("PRE")
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
    
    # Gives focus to the frame
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
        create_rexml_document_object
      end
      return @rexmlDomobject
    end
    
    # Create the Rexml object if it is nil. This method is private so can be called only
    # from rexml_document_object method.
    def create_rexml_document_object
      # Use our modified rexml libraries
      require 'rexml/document'
      unless REXML::Version >= '3.1.4'
        raise "Requires REXML version of at least 3.1.4. Actual: #{REXML::Version}"
      end
      if @rexmlDomobject == nil
        htmlSource ="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<HTML>\n"
        htmlSource = html_source(document.body,htmlSource," ")
        htmlSource += "\n</HTML>\n"
	# Angrez: Resolving Jira issue WTR-114
	htmlSource = htmlSource.gsub(/&nbsp;/, '&#160;')
        begin
          @rexmlDomobject = REXML::Document.new(htmlSource)
        rescue => e
          output_rexml_document("error.xml", htmlSource)
          raise e
        end
      end
    end
    private :create_rexml_document_object
    
    def output_rexml_document(name, text)
      file = File.open(name,"w")
      file.print(text)
      file.close
    end
    private :output_rexml_document
    
    #Function Tokenizes the tag line and returns array of tokens.
    #Token could be either tagName or "=" or attribute name or attribute value
    #Attribute value could be either quoted string or single word
    def tokenize_tagline(outerHtml)
      outerHtml = outerHtml.gsub(/\n|\r/," ")
      #removing "< symbol", opening of current tag
      outerHtml =~ /^\s*<(.*)$/
      outerHtml = $1
      tokens = Array.new
      i = startOffset = 0
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
            tokens.push quote + outerHtml[startOffset..i-1]
          else
            tokens.push outerHtml[startOffset..i]
          end
        elsif currentToken == "="
          tokens.push "="
          parsingValue = true
        else
          startOffset = i
          i += 1 while (i < length && !(outerHtml[i,1] =~ /\s|=|<|>/)) if !parsingValue
          i += 1 while (i < length && !(outerHtml[i,1] =~ /\s|<|>/)) if parsingValue
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
    def xml_escape(str)
      str = str.gsub(/&/,'&amp;')
      str = str.gsub(/</,'&lt;')
      str = str.gsub(/>/,'&gt;')
      str = str.gsub(/"/, '&quot;')
      str
    end
    private :xml_escape
    
    # Returns HTML Source
    # Traverse the DOM tree rooted at body element
    # and generate the HTML source.
    # element: Represent Current element
    # htmlString:HTML Source
    # spaces:(Used for debugging). Helps in indentation
    def html_source(element, htmlString, spaceString)
      begin
        tagLine = ""
        outerHtml = ""
        tagName = ""
        begin
          tagName = element.tagName.downcase
          tagName = EMPTY_TAG_NAME if tagName == ""
          # If tag is a mismatched tag.
          if !(tagName =~ /^(\w|_|:)(.*)$/)
            return htmlString
          end
        rescue
          #handling text nodes
          htmlString += xml_escape(element.toString)
          return htmlString
        end
        #puts tagName
        #Skip comment and script tag
        if tagName =~ /^!/ || tagName== "script" || tagName =="style"
          return htmlString
        end
        #tagLine += spaceString
        outerHtml = all_tag_attributes(element.outerHtml) if tagName != EMPTY_TAG_NAME
        tagLine += "<#{tagName} #{outerHtml}"
        
        canHaveChildren = element.canHaveChildren
        if canHaveChildren
          tagLine += ">"
        else
          tagLine += "/>" #self closing tag
        end
        #spaceString += spaceString
        htmlString += tagLine
        childElements = element.childnodes
        childElements.each do |child|
          htmlString = html_source(child,htmlString,spaceString)
        end
        if canHaveChildren
          #tagLine += spaceString
          tagLine ="</" + tagName + ">"
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
      doc = rexml_document_object
      modifiedXpath = ""
      selectedElements = Array.new
      doc.elements.each(xpath) do |element|
        modifiedXpath = element.xpath                   # element = a REXML element
#        puts "modified xpath: #{modifiedXpath}"
#        puts "text: #{element.text}"
#        puts "class: #{element.attributes['class']}"
#        require 'breakpoint'; breakpoint
        temp = element_by_absolute_xpath(modifiedXpath) # temp = a DOM/COM element
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
      doc = document
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
            curTag = EMPTY_TAG_NAME if curTag == ""
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
    
    def attach_command
      "Watir::IE.attach(:hwnd, #{hwnd})"
    end
    
    
  end # class IE
  
  #
  # MOVETO: watir/popup.rb
  # Module Watir::Popup
  #
  
  # POPUP object
  class PopUp
    def initialize(container)
      @container = container
      @page_container = container.page_container
    end
    
    def button(caption)
      return JSButton.new(@container.getIE.hwnd, caption)
    end
  end
  
  class JSButton
    def initialize(hWnd, caption)
      @hWnd = hWnd
      @caption = caption
    end
    
    def startClicker(waitTime=3)
      clicker = WinClicker.new
      clicker.clickJSDialog_Thread
      # clickerThread = Thread.new(@caption) {
      #   sleep waitTime
      #   puts "After the wait time in startClicker"
      #   clickWindowsButton_hwnd(hwnd, buttonCaption)
      #}
    end
  end
  
  # Base class for html elements.
  # This is not a class that users would normally access.
  class Element # Wrapper
    include Watir::Exception
    include Container # presumes @container is defined
    attr_accessor :container
    
    # number of spaces that separate the property from the value in the to_s method
    TO_S_SIZE = 14
    
    # ole_object - the ole object for the element being wrapped
    def initialize(ole_object)
      @o = ole_object
      @original_color = nil
    end
    
    # Return the ole object, allowing any methods of the DOM that Watir doesn't support to be used.
    def ole_object # BUG: should use an attribute reader and rename the instance variable
      return @o
    end
    def ole_object=(o)
      @o = o
    end
    
    private
    def self.def_wrap(ruby_method_name, ole_method_name=nil)
      ole_method_name = ruby_method_name unless ole_method_name
      class_eval "def #{ruby_method_name}
                          assert_exists
                          ole_object.invoke('#{ole_method_name}')
                        end"
    end
    def self.def_wrap_guard(method_name)
      class_eval "def #{method_name}
                          assert_exists
                          begin
                            ole_object.invoke('#{method_name}')
                          rescue
                            ''
                          end
                        end"
    end

    public
    def assert_exists
      locate if defined?(locate)
      unless ole_object
        raise UnknownObjectException.new("Unable to locate object, using #{@how} and #{@what}")
      end
    end
    def assert_enabled
      unless enabled?
        raise ObjectDisabledException, "object #{@how} and #{@what} is disabled"
      end
    end
    
    # return the name of the element (as defined in html)
    def_wrap_guard :name
    # return the id of the element
    def_wrap_guard :id
    # return whether the element is disabled
    def_wrap :disabled
    alias disabled? disabled
    # return the value of the element
    def_wrap_guard :value
    # return the title of the element
    def_wrap_guard :title
    # return the style of the element
    def_wrap_guard :style
    
    def_wrap_guard :alt
    def_wrap_guard :src
    
    # return the type of the element
    def_wrap_guard :type # input elements only
    # return the url the link points to
    def_wrap :href # link only
    # return the ID of the control that this label is associated with
    def_wrap :for, :htmlFor # label only
    # return the class name of the element
    # raise an ObjectNotFound exception if the object cannot be found
    def_wrap :class_name, :className
    # return the unique COM number for the element
    def_wrap :unique_number, :uniqueNumber
    # Return the outer html of the object - see http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/outerhtml.asp?frame=true
    def_wrap :html, :outerHTML

    # return the text before the element
    def before_text # label only
      assert_exists
      begin
        ole_object.getAdjacentText("afterEnd").strip
      rescue
                ''
      end
    end
    
    # return the text after the element
    def after_text # label only
      assert_exists
      begin
        ole_object.getAdjacentText("beforeBegin").strip
      rescue
                ''
      end
    end
    
    # Return the innerText of the object
    # Raise an ObjectNotFound exception if the object cannot be found
    def text
      assert_exists
      return ole_object.innerText.strip
    end
    
    def ole_inner_elements
      assert_exists
      return ole_object.all
    end
    private :ole_inner_elements
    
    def document
      assert_exists
      return ole_object
    end

    # Return the element immediately containing self. 
    def parent
      assert_exists
      result = Element.new(ole_object.parentelement)
      result.set_container self
      result
    end
    
    include Comparable
    def <=> other
      assert_exists
      other.assert_exists
      ole_object.sourceindex <=> other.ole_object.sourceindex
    end

    # Return true if self is contained earlier in the html than other. 
    alias :before? :< 
    # Return true if self is contained later in the html than other. 
    alias :after? :> 
      
    def typingspeed
      @container.typingspeed
    end
    
    def activeObjectHighLightColor
      @container.activeObjectHighLightColor
    end
    
    # Return an array with many of the properties, in a format to be used by the to_s method
    def string_creator
      n = []
      n <<   "type:".ljust(TO_S_SIZE) + self.type
      n <<   "id:".ljust(TO_S_SIZE) +         self.id.to_s
      n <<   "name:".ljust(TO_S_SIZE) +       self.name.to_s
      n <<   "value:".ljust(TO_S_SIZE) +      self.value.to_s
      n <<   "disabled:".ljust(TO_S_SIZE) +   self.disabled.to_s
      return n
    end
    private :string_creator
    
    # Display basic details about the object. Sample output for a button is shown.
    # Raises UnknownObjectException if the object is not found.
    #      name      b4
    #      type      button
    #      id         b5
    #      value      Disabled Button
    #      disabled   true
    def to_s
      assert_exists
      return string_creator.join("\n")
    end
    
    # This method is responsible for setting and clearing the colored highlighting on the currently active element.
    # use :set   to set the highlight
    #   :clear  to clear the highlight
    # TODO: Make this two methods: set_highlight & clear_highlight
    # TODO: Remove begin/rescue blocks
    def highlight(set_or_clear)
      if set_or_clear == :set
        begin
          @original_color ||= style.backgroundColor
          style.backgroundColor = @container.activeObjectHighLightColor
        rescue
          @original_color = nil
        end
      else # BUG: assumes is :clear, but could actually be anything
        begin
          style.backgroundColor = @original_color unless @original_color == nil
        rescue
          # we could be here for a number of reasons...
          # e.g. page may have reloaded and the reference is no longer valid
        ensure
          @original_color = nil
        end
      end
    end
    private :highlight
    
    #   This method clicks the active element.
    #   raises: UnknownObjectException  if the object is not found
    #   ObjectDisabledException if the object is currently disabled
    def click
      click!
      @container.wait
    end
    
    def click_no_wait
      assert_enabled
      
      highlight(:set)
      object = "#{self.class}.new(self, :unique_number, #{self.unique_number})"
      @page_container.eval_in_spawned_process(object + ".click!")
      highlight(:clear)
    end

    def click!
      assert_enabled
      
      highlight(:set)
      ole_object.click
      highlight(:clear)
    end
    
    # Flash the element the specified number of times.
    # Defaults to 10 flashes.
    def flash number=10
      assert_exists
      number.times do
        highlight(:set)
        sleep 0.05
        highlight(:clear)
        sleep 0.05
      end
      nil
    end
    
    # Executes a user defined "fireEvent" for objects with JavaScript events tied to them such as DHTML menus.
    #   usage: allows a generic way to fire javascript events on page objects such as "onMouseOver", "onClick", etc.
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def fire_event(event)
      assert_enabled
      
      highlight(:set)
      ole_object.fireEvent(event)
      @container.wait
      highlight(:clear)
    end
    
    # This method sets focus on the active element.
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def focus
      assert_enabled
      ole_object.focus
    end
    
    # Returns whether this element actually exists.
    def exists?
      begin
        locate if defined?(locate)
      rescue WIN32OLERuntimeError
        @o = nil
      end
      @o ? true: false
    end
    alias :exist? :exists?
    
    # Returns true if the element is enabled, false if it isn't.
    #   raises: UnknownObjectException  if the object is not found
    def enabled?
      assert_exists
      return ! disabled
    end
    
    # Get attribute value for any attribute of the element.
    # Returns null if attribute doesn't exist.
    def attribute_value(attribute_name)
      assert_exists
      return ole_object.getAttribute(attribute_name)
    end
    
  end
  
  class ElementMapper # Still to be used
    include Container
    
    def initialize wrapper_class, container, how, what
      @wrapper_class = wrapper_class
      set_container
      @how = how
      @what = what
    end
    
    def method_missing method, *args
      locate
      @wrapper_class.new(@o).send(method, *args)
    end
  end
  
  class Frame
    include Container
    include PageContainer
    
    # Find the frame denoted by how and what in the container and return its ole_object
    def locate
      how = @how
      what = @what
      frames = @container.document.frames
      target = nil
      
      for i in 0..(frames.length - 1)
        this_frame = frames.item(i)
        case how
        when :index
          index = i + 1
          return this_frame if index == what
        when :name
          begin
            return this_frame if what.matches(this_frame.name)
          rescue # access denied?
          end
        when :id
          # We assume that pages contain frames or iframes, but not both.
          this_frame_tag = @container.document.getElementsByTagName("FRAME").item(i)
          return this_frame if this_frame_tag and what.matches(this_frame_tag.invoke("id"))
          this_iframe_tag = @container.document.getElementsByTagName("IFRAME").item(i)
          return this_frame if this_iframe_tag and what.matches(this_iframe_tag.invoke("id"))
        when :src
          this_frame_tag = @container.document.getElementsByTagName("FRAME").item(i)
          return this_frame if this_frame_tag and what.matches(this_frame_tag.src)
          this_iframe_tag = @container.document.getElementsByTagName("IFRAME").item(i) 
          return this_frame if this_iframe_tag and what.matches(this_iframe_tag.src)
        else
          raise ArgumentError, "Argument #{how} not supported"
        end
      end
      
      raise UnknownFrameException, "Unable to locate a frame with #{how.to_s} #{what}"
    end
    
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      @o = locate
      copy_test_config container
    end
    
    def document
      @o.document
    end

    def attach_command
      @container.page_container.attach_command + ".frame(#{@how.inspect}, #{@what.inspect})"
    end
    
  end
  
  class ModalDialog
    include Container
    include PageContainer
    include Win32

    # Return the current window handle
    attr_reader :hwnd

    def find_modal_from_window
      # Use handle of our parent window to see if we have any currently
      # enabled popup.
      hwnd = @container.hwnd
      hwnd_modal = 0
      begin
        Watir::until_with_timeout do
          hwnd_modal, arr = GetWindow.call(hwnd, GW_ENABLEDPOPUP) # GW_ENABLEDPOPUP = 6
          hwnd_modal > 0
        end
      rescue TimeOutException
        return nil
      end
      if hwnd_modal == hwnd || hwnd_modal == 0
        hwnd_modal = nil
      end
      @hwnd = hwnd_modal
    end
    private :find_modal_from_window

    def locate
      how = @how
      what = @what

      case how
      when nil
        unless find_modal_from_window
          raise NoMatchingWindowFoundException, 
            "Modal Dialog not found. Timeout = #{Watir::IE.attach_timeout}"
        end
      when :title
        case what.class.to_s
        # TODO: re-write like WET's so we can select on regular expressions too.
        when "String"
          begin
            Watir::until_with_timeout do
              title = "#{what} -- Web Page Dialog"
              @hwnd, arr = FindWindowEx.call(0, 0, nil, title)
              @hwnd > 0
            end
          rescue TimeOutException
            raise NoMatchingWindowFoundException, 
              "Modal Dialog with title #{what} not found. Timeout = #{Watir::IE.attach_timeout}"
          end
        else
          raise ArgumentError, "Title value must be String"
        end
      else
        raise ArgumentError, "Only null and :title methods are supported"
      end

      intUnknown = 0
      begin
        Watir::until_with_timeout do
          intPointer = " " * 4 # will contain the int value of the IUnknown*
          GetUnknown.call(@hwnd, intPointer)
          intArray = intPointer.unpack('L')
          intUnknown = intArray.first
          intUnknown > 0
        end
      rescue TimeOutException => e        
        raise NoMatchingWindowFoundException, 
          "Unable to attach to Modal Window #{what.inspect} after #{e.duration} seconds."
      end
      
      copy_test_config @parent_container
      @document = WIN32OLE.connect_unknown(intUnknown)
    end

    def initialize(container, how, what=nil)
      set_container container
      @how = how
      @what = what
      @parent_container = container
      # locate our modal dialog's Document object and save it
      begin
        locate
      rescue NoMethodError => e
        message = 
          "IE#modal_dialog not supported with the current version of Ruby (#{RUBY_VERSION}).\n" + 
          "See http://jira.openqa.org/browse/WTR-2 for details.\n" +
            e.message
        raise NoMethodError.new(message)
      end
    end

    def document
      @document
    end
    
    # Return the title of the document
    def title
      document.title
    end

    def close
      document.parentWindow.close
    end

    def attach_command
      "Watir::IE.find(:hwnd, #{@container.hwnd}).modal_dialog"
    end
      
    def wait(no_sleep=false)
    end
    
    # Return true if the modal exists. Mostly this is useful for testing whether
    # a modal has closed.
    def exists?
      Watir::Win32::window_exists? @hwnd
    end
    alias :exist? :exists?
  end

  # this class is the super class for the iterator classes (buttons, links, spans etc
  # it would normally only be accessed by the iterator methods (spans, links etc) of IE
  class ElementCollections
    include Enumerable
    
    # Super class for all the iteractor classes
    #   * container - an instance of an IE object
    def initialize(container)
      @container = container
      @page_container = container.page_container
      @length = length # defined by subclasses
      
      # set up the items we want to display when the show method is used
      set_show_items
    end
    
    private
    def set_show_items
      @show_attributes = AttributeLengthPairs.new("id", 20)
      @show_attributes.add("name", 20)
    end
    
    public
    def get_length_of_input_objects(object_type)
      object_types =
      if object_type.kind_of? Array
        object_type
      else
        [object_type]
      end
      
      length = 0
      objects = @container.document.getElementsByTagName("INPUT")
      if objects.length > 0
        objects.each do |o|
          length += 1 if object_types.include?(o.invoke("type").downcase)
        end
      end
      return length
    end
    
    # iterate through each of the elements in the collection in turn
    def each
      0.upto(@length-1) { |i| yield iterator_object(i) }
    end
    
    # allows access to a specific item in the collection
    def [](n)
      return iterator_object(n-1)
    end
    
    # this method is the way to show the objects, normally used from irb
    def show
      s = "index".ljust(6)
      @show_attributes.each do |attribute_length_pair|
        s += attribute_length_pair.attribute.ljust(attribute_length_pair.length)
      end
      
      index = 1
      self.each do |o|
        s += "\n"
        s += index.to_s.ljust(6)
        @show_attributes.each do |attribute_length_pair|
          begin
            s += eval('o.ole_object.invoke("#{attribute_length_pair.attribute}")').to_s.ljust(attribute_length_pair.length)
          rescue => e
            s += " ".ljust(attribute_length_pair.length)
          end
        end
        index += 1
      end
      puts s
    end
    
    # this method creates an object of the correct type that the iterators use
    private
    def iterator_object(i)
      element_class.new(@container, :index, i + 1)
    end
  end
  
  
  # Forms
  
  module FormAccess
    def name
      @ole_object.getAttributeNode('name').value
    end
    def action
      @ole_object.action
    end
    def method
      @ole_object.invoke('method')
    end
    def id
      @ole_object.invoke('id')
    end
  end
  
  # wraps around a form OLE object
  class FormWrapper
    include FormAccess
    def initialize(ole_object)
      @ole_object = ole_object
    end
  end
  
  #   Form Factory object
  class Form < Element
    include FormAccess
    include Container
    
    attr_accessor :form
    
    #   * container   - the containing object, normally an instance of IE
    #   * how         - symbol - how we access the form (:name, :id, :index, :action, :method)
    #   * what        - what we use to access the form
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      
      log "Get form how is #{@how}  what is #{@what} "
      
      # Get form using xpath.
      if @how == :xpath
        @ole_object = @container.element_by_xpath(@what)
      else
        count = 1
        doc = @container.document
        doc.forms.each do |thisForm|
          next unless @ole_object == nil
          
          wrapped = FormWrapper.new(thisForm)
          
          log "form on page, name is " + wrapped.name
          
          @ole_object =
          case @how
          when :name, :id, :method, :action
            @what.matches(wrapped.send(@how)) ? thisForm : nil
          when :index
            count == @what ? thisForm : nil
          else
            raise MissingWayOfFindingObjectException, "#{how} is an unknown way of finding a form (#{what})"
          end
          count = count +1
        end
      end
      super(@ole_object)
      
      copy_test_config container
    end
    
    def exists?
      @ole_object ? true : false
    end
    alias :exist? :exists?
    
    # Submit the data -- equivalent to pressing Enter or Return to submit a form.
    def submit # XXX use assert_exists
      raise UnknownFormException, "Unable to locate a form using #{@how} and #{@what} " if @ole_object == nil
      @ole_object.submit
      @container.wait
    end
    
    def ole_inner_elements # XXX use assert_exists
      raise UnknownFormException, "Unable to locate a form using #{@how} and #{@what} " if @ole_object == nil
      @ole_object.elements
    end
    private :ole_inner_elements
    
    def document
      return @ole_object
    end
    
    def wait(no_sleep=false)
      @container.wait(no_sleep)
    end
    
    # This method is responsible for setting and clearing the colored highlighting on the specified form.
    # use :set  to set the highlight
    #   :clear  to clear the highlight
    def highlight(set_or_clear, element, count)
      
      if set_or_clear == :set
        begin
          original_color = element.style.backgroundColor
          original_color = "" if original_color==nil
          element.style.backgroundColor = activeObjectHighLightColor
        rescue => e
          puts e
          puts e.backtrace.join("\n")
          original_color = ""
        end
        @original_styles[count] = original_color
      else
        begin
          element.style.backgroundColor = @original_styles[ count]
        rescue => e
          puts e
          # we could be here for a number of reasons...
        ensure
        end
      end
    end
    private :highlight
    
    # causes the object to flash. Normally used in IRB when creating scripts
    # Default is 10
    def flash number=10
      @original_styles = {}
      number.times do
        count = 0
        @ole_object.elements.each do |element|
          highlight(:set, element, count)
          count += 1
        end
        sleep 0.05
        count = 0
        @ole_object.elements.each do |element|
          highlight(:clear, element, count)
          count += 1
        end
        sleep 0.05
      end
    end
    
  end # class Form
  
  # this class contains items that are common between the span, div, and pre objects
  # it would not normally be used directly
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class NonControlElement < Element
    include Watir::Exception
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        @o = @container.locate_tagged_element(self.class::TAG, @how, @what)
      end
    end
    
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
    end
    
    # this method is used to populate the properties in the to_s method
    def span_div_string_creator
      n = []
      n <<   "class:".ljust(TO_S_SIZE) + self.class_name
      n <<   "text:".ljust(TO_S_SIZE) + self.text
      return n
    end
    private :span_div_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    def to_s
      assert_exists
      r = string_creator
      r += span_div_string_creator
      return r.join("\n")
    end
  end
  
  class Pre < NonControlElement
    TAG = 'PRE'
  end
  
  class P < NonControlElement
    TAG = 'P'
  end
  
  # this class is used to deal with Div tags in the html page. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
  # It would not normally be created by users
  class Div < NonControlElement
    TAG = 'DIV'
  end
  
  # this class is used to deal with Span tags in the html page. It would not normally be created by users
  class Span < NonControlElement
    TAG = 'SPAN'
  end
  
  # Accesses Label element on the html page - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
  class Label < NonControlElement
    TAG = 'LABEL'
    
    # this method is used to populate the properties in the to_s method
    def label_string_creator
      n = []
      n <<   "for:".ljust(TO_S_SIZE) + self.for
      n <<   "text:".ljust(TO_S_SIZE) + self.text
      return n
    end
    private :label_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    def to_s
      assert_exists
      r = string_creator
      r += label_string_creator
      return r.join("\n")
    end
  end
  
  class Li < NonControlElement
    TAG = 'LI'
  end  
  
  # This class is used for dealing with tables.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#table method
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class Table < Element
    include Container
    
    # Returns the table object containing anElement
    #   * container  - an instance of an IE object
    #   * anElement  - a Watir object (TextField, Button, etc.)
    def Table.create_from_element(container, anElement)
      anElement.locate if defined?(anElement.locate)
      o = anElement.ole_object.parentElement
      o = o.parentElement until o.tagName == 'TABLE'
      new container, :ole_object, o 
    end
    
    # Returns an initialized instance of a table object
    #   * container      - the container
    #   * how         - symbol - how we access the table
    #   * what         - what we use to access the table - id, name index etc
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
    end
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      elsif @how == :ole_object
        @o = @what
      else
        @o = @container.locate_tagged_element('TABLE', @how, @what)
      end
    end
    
    # override the highlight method, as if the tables rows are set to have a background color,
    # this will override the table background color, and the normal flash method won't work
    def highlight(set_or_clear)
      
      if set_or_clear == :set
        begin
          @original_border = @o.border.to_i
          if @o.border.to_i==1
            @o.border = 2
          else
            @o.border = 1
          end
        rescue
          @original_border = nil
        end
      else
        begin
          @o.border= @original_border unless @original_border == nil
          @original_border = nil
        rescue
          # we could be here for a number of reasons...
        ensure
          @original_border = nil
        end
      end
      super
    end
    
    # this method is used to populate the properties in the to_s method
    def table_string_creator
      n = []
      n <<   "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
      n <<   "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
      return n
    end
    private :table_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    def to_s
      assert_exists
      r = string_creator
      r += table_string_creator
      return r.join("\n")
    end
    
    # iterates through the rows in the table. Yields a TableRow object
    def each
      assert_exists
      1.upto(@o.getElementsByTagName("TR").length) { |i| yield TableRow.new(@container, :ole_object, row(i))    }
    end
    
    # Returns a row in the table
    #   * index         - the index of the row
    def [](index)
      assert_exists
      return TableRow.new(@container, :ole_object, row(index))
    end
    
    # This method returns the number of rows in the table.
    # Raises an UnknownObjectException if the table doesnt exist.
    def row_count
      assert_exists
      #return table_body.children.length
      return @o.getElementsByTagName("TR").length
    end
    
    # This method returns the number of columns in a row of the table.
    # Raises an UnknownObjectException if the table doesn't exist.
    #   * index         - the index of the row
    def column_count(index=1)
      assert_exists
      row(index).cells.length
    end
    
    # This method returns the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
    # Raises an UnknownObjectException if the table doesn't exist.
    # http://www.w3.org/TR/html4/struct/tables.html
    def to_a
      assert_exists
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
    
    def table_body(index=1)
      return @o.getElementsByTagName('TBODY')[index]
    end
    private :table_body
    
    # returns a watir object
    def body(how, what)
      return TableBody.new(@container, how, what, self)
    end
    
    # returns a watir object
    def bodies
      assert_exists
      return TableBodies.new(@container, @o)
    end
    
    # returns an ole object
    def row(index)
      return @o.invoke("rows")[(index-1).to_s]
    end
    private :row
    
    # Returns an array containing all the text values in the specified column
    # Raises an UnknownCellException if the specified column does not exist in every
    # Raises an UnknownObjectException if the table doesn't exist.
    # row of the table
    #   * columnnumber  - column index to extract values from
    def column_values(columnnumber)

      return(1..row_count).collect {|idx| self[idx][columnnumber].text}
    end
    
    # Returns an array containing all the text values in the specified row
    # Raises an UnknownObjectException if the table doesn't exist.
    #   * rownumber  - row index to extract values from
    def row_values(rownumber)
      return(1..column_count(rownumber)).collect {|idx| self[rownumber][idx].text}
    end
    
  end
  
  # this class is a collection of the table body objects that exist in the table
  # it wouldnt normally be created by a user, but gets returned by the bodies method of the Table object
  # many of the methods available to this object are inherited from the Element class
  #
  class TableBodies < Element
    def initialize(container, parent_table)
      set_container container
      @o = parent_table     # in this case, @o is the parent table
    end
    
    # returns the number of TableBodies that exist in the table
    def length
      assert_exists
      return @o.tBodies.length
    end
    
    # returns the n'th Body as a Watir TableBody object
    def []n
      assert_exists
      return TableBody.new(@container, :ole_object, ole_table_body_at_index(n))
    end
    
    # returns an ole table body
    def ole_table_body_at_index(n)
      return @o.tBodies[(n-1).to_s]
    end
    
    # iterates through each of the TableBodies in the Table. Yields a TableBody object
    def each
      1.upto(@o.tBodies.length) { |i| yield TableBody.new(@container, :ole_object, ole_table_body_at_index(i)) }
    end
    
  end
  
  # this class is a table body
  class TableBody < Element
    def locate
      @o = nil
      if @how == :ole_object
        @o = @what     # in this case, @o is the table body
      elsif @how == :index
        @o = @parent_table.bodies.ole_table_body_at_index(@what)
      end
      @rows = []
      if @o
        @o.rows.each do |oo|
          @rows << TableRow.new(@container, :ole_object, oo)
        end
      end
    end
    
    def initialize(container, how, what, parent_table=nil)
      set_container container
      @how = how
      @what = what
      @parent_table = parent_table
      super nil
    end
    
    # returns the specified row as a TableRow object
    def [](n)
      assert_exists
      return @rows[n - 1]
    end
    
    # iterates through all the rows in the table body
    def each
      locate
      0.upto(@rows.length - 1) { |i| yield @rows[i] }
    end
    
    # returns the number of rows in this table body.
    def length
      return @rows.length
    end
  end
  
  
  # this class is a table row
  class TableRow < Element
    
    def locate
      @o = nil
      if @how == :ole_object
        @o = @what
      elsif @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        @o = @container.locate_tagged_element("TR", @how, @what)
      end
      if @o # cant call the assert_exists here, as an exists? method call will fail
        @cells = []
        @o.cells.each do |oo|
          @cells << TableCell.new(@container, :ole_object, oo)
        end
      end
    end
    
    # Returns an initialized instance of a table row
    #   * o  - the object contained in the row
    #   * container  - an instance of an IE object
    #   * how          - symbol - how we access the row
    #   * what         - what we use to access the row - id, index etc. If how is :ole_object then what is a Internet Explorer Raw Row
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
    end
    
    # this method iterates through each of the cells in the row. Yields a TableCell object
    def each
      locate
      0.upto(@cells.length-1) { |i| yield @cells[i] }
    end
    
    # Returns an element from the row as a TableCell object
    def [](index)
      assert_exists
      raise UnknownCellException, "Unable to locate a cell at index #{index}" if @cells.length < index
      return @cells[(index - 1)]
    end
    
    # defaults all missing methods to the array of elements, to be able to
    # use the row as an array
    #        def method_missing(aSymbol, *args)
    #            return @o.send(aSymbol, *args)
    #        end
    
    def column_count
      locate
      @cells.length
    end
  end
  
  # this class is a table cell - when called via the Table object
  class TableCell < Element
    include Watir::Exception
    include Container
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      elsif @how == :ole_object
        @o = @what
      else
        @o = @container.locate_tagged_element("TD", @how, @what)
      end
    end
    
    # Returns an initialized instance of a table cell
    #   * container  - an  IE object
    #   * how        - symbol - how we access the cell
    #   * what       - what we use to access the cell - id, name index etc
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
    end
    
    def ole_inner_elements
      locate
      return @o.all
    end
    private :ole_inner_elements
    
    def document
      locate
      return @o
    end
    
    alias to_s text
    
    def colspan
      locate
      @o.colSpan
    end
    
  end
  
  # This class is the means of accessing an image on a page.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#image method
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class Image < Element
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
    end
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        @o = @container.locate_tagged_element('IMG', @how, @what)
      end
    end
    
    # this method produces the properties for an image as an array
    def image_string_creator
      n = []
      n <<   "src:".ljust(TO_S_SIZE) + self.src.to_s
      n <<   "file date:".ljust(TO_S_SIZE) + self.fileCreatedDate.to_s
      n <<   "file size:".ljust(TO_S_SIZE) + self.fileSize.to_s
      n <<   "width:".ljust(TO_S_SIZE) + self.width.to_s
      n <<   "height:".ljust(TO_S_SIZE) + self.height.to_s
      n <<   "alt:".ljust(TO_S_SIZE) + self.alt.to_s
      return n
    end
    private :image_string_creator
    
    # returns a string representation of the object
    def to_s
      assert_exists
      r = string_creator
      r += image_string_creator
      return r.join("\n")
    end
    
    # this method returns the file created date of the image
    def fileCreatedDate
      assert_exists
      return @o.invoke("fileCreatedDate")
    end
    
    # this method returns the filesize of the image
    def fileSize
      assert_exists
      return @o.invoke("fileSize").to_s
    end
    
    # returns the width in pixels of the image, as a string
    def width
      assert_exists
      return @o.invoke("width").to_s
    end
    
    # returns the height in pixels of the image, as a string
    def height
      assert_exists
      return @o.invoke("height").to_s
    end
    
    # This method attempts to find out if the image was actually loaded by the web browser.
    # If the image was not loaded, the browser is unable to determine some of the properties.
    # We look for these missing properties to see if the image is really there or not.
    # If the Disk cache is full (tools menu -> Internet options -> Temporary Internet Files), it may produce incorrect responses.
    def hasLoaded?
      locate
      raise UnknownObjectException, "Unable to locate image using #{@how} and #{@what}" if @o == nil
      return false if @o.fileCreatedDate == "" and @o.fileSize.to_i == -1
      return true
    end
    
    # this method highlights the image (in fact it adds or removes a border around the image)
    #  * set_or_clear   - symbol - :set to set the border, :clear to remove it
    def highlight(set_or_clear)
      if set_or_clear == :set
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
    private :highlight
    
    # This method saves the image to the file path that is given.  The
    # path must be in windows format (c:\\dirname\\somename.gif).  This method
    # will not overwrite a previously existing image.  If an image already
    # exists at the given path then a dialog will be displayed prompting
    # for overwrite.
    # Raises a WatirException if AutoIt is not correctly installed
    # path - directory path and file name of where image should be saved
    def save(path)
      require 'watir/windowhelper'
      WindowHelper.check_autoit_installed
      @container.goto(src)
      begin
        thrd = fill_save_image_dialog(path)
        @container.document.execCommand("SaveAs")
        thrd.join(5)
      ensure
        @container.back
      end
    end
    
    def fill_save_image_dialog(path)
      Thread.new do
        system("ruby -e \"require 'win32ole'; @autoit=WIN32OLE.new('AutoItX3.Control'); waitresult=@autoit.WinWait 'Save Picture', '', 15; if waitresult == 1\" -e \"@autoit.ControlSetText 'Save Picture', '', '1148', '#{path}'; @autoit.ControlSend 'Save Picture', '', '1', '{ENTER}';\" -e \"end\"")
      end
    end
    private :fill_save_image_dialog
  end
  
  
  # This class is the means of accessing a link on a page
  # Normally a user would not need to create this object as it is returned by the Watir::Container#link method
  # many of the methods available to this object are inherited from the Element class
  #
  class Link < Element
    # Returns an initialized instance of a link object
    #   * container  - an instance of a container
    #   * how         - symbol - how we access the link
    #   * what         - what we use to access the link, text, url, index etc
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super(nil)
    end
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        begin
          @o = @container.locate_tagged_element('A', @how, @what)
        rescue UnknownObjectException
          @o = nil
        end
      end
    end
    
    # if an image is used as part of the link, this will return true
    def link_has_image
      assert_exists
      return true if @o.getElementsByTagName("IMG").length > 0
      return false
    end
    
    # this method returns the src of an image, if an image is used as part of the link
    def src # BUG?
      assert_exists
      if @o.getElementsByTagName("IMG").length > 0
        return @o.getElementsByTagName("IMG")[0.to_s].src
      else
        return ""
      end
    end
    
    def link_string_creator
      n = []
      n <<   "href:".ljust(TO_S_SIZE) + self.href
      n <<   "inner text:".ljust(TO_S_SIZE) + self.text
      n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
      return n
    end
    
    # returns a textual description of the link
    def to_s
      assert_exists
      r = string_creator
      r = r + link_string_creator
      return r.join("\n")
    end
  end
  
  class InputElement < Element
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      elsif @how == :ole_object
        @o = @what
      else
        @o = @container.locate_input_element(@how, @what, self.class::INPUT_TYPES)
      end
    end
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super(nil)
    end
  end
  
  # This class is the way in which select boxes are manipulated.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_list method
  class SelectList < InputElement
    INPUT_TYPES = ["select-one", "select-multiple"]
    
    attr_accessor :o
    
    # This method clears the selected items in the select box
    def clearSelection
      assert_exists
      highlight(:set)
      wait = false
      @o.each do |selectBoxItem|
        if selectBoxItem.selected
          selectBoxItem.selected = false
          wait = true
        end
      end
      @container.wait if wait
      highlight(:clear)
    end
    #        private :clearSelection
    
    # This method selects an item, or items in a select box, by text.
    # Raises NoValueFoundException   if the specified value is not found.
    #  * item   - the thing to select, string or reg exp
    def select(item)
      select_item_in_select_list(:text, item)
    end
    alias :set :select 
       
    # Selects an item, or items in a select box, by value.
    # Raises NoValueFoundException   if the specified value is not found.
    #  * item   - the value of the thing to select, string, reg exp or an array of string and reg exps
    def select_value(item)
      select_item_in_select_list(:value, item)
    end
    
    # BUG: Should be private
    # Selects something from the select box
    #  * name  - symbol  :value or :text - how we find an item in the select box
    #  * item  - string or reg exp - what we are looking for
    def select_item_in_select_list(attribute, value)
      assert_exists
      highlight(:set)
      doBreak = false
      @container.log "Setting box #{@o.name} to #{attribute} #{value} "
      @o.each do |option| # items in the list
        if value.matches(option.invoke(attribute.to_s))
          if option.selected
            doBreak = true
            break
          else
            option.selected = true
            @o.fireEvent("onChange")
            @container.wait
            doBreak = true
            break
          end
        end
      end
      unless doBreak
        raise NoValueFoundException,
                        "No option with #{attribute.to_s} of #{value} in this select element"
      end
      highlight(:clear)
    end
    
    # Returns all the items in the select list as an array.
    # An empty array is returned if the select box has no contents.
    # Raises UnknownObjectException if the select box is not found
    def getAllContents # BUG: camel_case.rb
      assert_exists
      @container.log "There are #{@o.length} items"
      returnArray = []
      @o.each { |thisItem| returnArray << thisItem.text }
      return returnArray
    end
    
    # Returns the selected items as an array.
    # Raises UnknownObjectException if the select box is not found.
    def getSelectedItems
      assert_exists
      returnArray = []
      @container.log "There are #{@o.length} items"
      @o.each do |thisItem|
        if thisItem.selected
          @container.log "Item (#{thisItem.text}) is selected"
          returnArray << thisItem.text
        end
      end
      return returnArray
    end

    # Does the SelectList include the specified option (text)?
    def includes? text
      getAllContents.include? text
    end

    # Is the specified option (text) selected? Raises exception of option does not exist.
    def selected? text
      unless includes? text
        raise UnknownObjectException, "Option #{text} not found."
      end
      getSelectedItems.include? text
    end
    
    def option(attribute, value)
      assert_exists
      Option.new(self, attribute, value)
    end
  end
  
  module OptionAccess
    def text
      @option.text
    end
    def value
      @option.value
    end
    def selected
      @option.selected
    end
  end
  
  class OptionWrapper
    include OptionAccess
    def initialize(option)
      @option = option
    end
  end
  
  # An item in a select list
  class Option
    include OptionAccess
    include Watir::Exception
    def initialize(select_list, attribute, value)
      @select_list = select_list
      @how = attribute
      @what = value
      @option = nil
      
      unless [:text, :value].include? attribute
        raise MissingWayOfFindingObjectException,
                    "Option does not support attribute #{@how}"
      end
      @select_list.o.each do |option| # items in the list
        if value.matches(option.invoke(attribute.to_s))
          @option = option
          break
        end
      end
      
    end
    def assert_exists
      unless @option
        raise UnknownObjectException,
                    "Unable to locate an option using #{@how} and #{@what}"
      end
    end
    private :assert_exists
    def select
      assert_exists
      @select_list.select_item_in_select_list(@how, @what)
    end
  end
  
  # This is the main class for accessing buttons.
  # Normally a user would not need to create this object as it is
  # returned by the Watir::Container#button method
  class Button < InputElement
    INPUT_TYPES = ["button", "submit", "image", "reset"]
  end
  
  # This class is the main class for Text Fields
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_field method
  class TextField < InputElement
    INPUT_TYPES = ["text", "password", "textarea"]
    
    def_wrap_guard :size
    
    def maxlength
      assert_exists
      begin
        ole_object.invoke('maxlength').to_i
      rescue
        0
      end
    end
    
    
    # Returns true or false if the text field is read only.
    #   Raises UnknownObjectException if the object can't be found.
    def_wrap :readonly?, :readOnly
    
    def text_string_creator
      n = []
      n <<   "length:".ljust(TO_S_SIZE) + self.size.to_s
      n <<   "max length:".ljust(TO_S_SIZE) + self.maxlength.to_s
      n <<   "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s
      
      return n
    end
    private :text_string_creator
    
    def to_s
      assert_exists
      r = string_creator
      r += text_string_creator
      return r.join("\n")
    end
    
    def assert_not_readonly
      raise ObjectReadOnlyException, "Textfield #{@how} and #{@what} is read only." if self.readonly?
    end
    
    # This method returns true or false if the text field contents is either a string match
    # or a regular expression match to the supplied value.
    #   Raises UnknownObjectException if the object can't be found
    #   * containsThis - string or reg exp - the text to verify
    def verify_contains(containsThis) # FIXME: verify_contains should have same name and semantics as IE#contains_text (prolly make this work for all elements)
      assert_exists
      if containsThis.kind_of? String
        return true if self.value == containsThis
      elsif containsThis.kind_of? Regexp
        return true if self.value.match(containsThis) != nil
      end
      return false
    end
    
    # this method is used to drag the entire contents of the text field to another text field
    #  19 Jan 2005 - It is added as prototype functionality, and may change
    #   * destination_how   - symbol, :id, :name how we identify the drop target
    #   * destination_what  - string or regular expression, the name, id, etc of the text field that will be the drop target
    def dragContentsTo(destination_how, destination_what)
      assert_exists
      destination = @container.text_field(destination_how, destination_what)
      raise UnknownObjectException, "Unable to locate destination using #{destination_how } and #{destination_what } "   if destination.exists? == false
      
      @o.focus
      @o.select
      value = self.value
      
      @o.fireEvent("onSelect")
      @o.fireEvent("ondragstart")
      @o.fireEvent("ondrag")
      destination.fireEvent("onDragEnter")
      destination.fireEvent("onDragOver")
      destination.fireEvent("ondrop")
      
      @o.fireEvent("ondragend")
      destination.value = destination.value + value.to_s
      self.value = ""
    end
    
    # This method clears the contents of the text box.
    #   Raises UnknownObjectException if the object can't be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def clear
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      
      @o.scrollIntoView
      @o.focus
      @o.select
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      @o.fireEvent("onChange")
      @container.wait
      highlight(:clear)
    end
    
    # This method appens the supplied text to the contents of the text box.
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    #   * setThis  - string - the text to append
    def append(setThis)
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus
      doKeyPress(setThis)
      highlight(:clear)
    end
    
    # This method sets the contents of the text box to the supplied text
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    #   * setThis - string - the text to set
    def set(setThis)
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus
      @o.select
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      doKeyPress(setThis)
      highlight(:clear)
      @o.fireEvent("onChange")
      @o.fireEvent("onBlur")
    end
    
    # this method sets the value of the text field directly. It causes no events to be fired or exceptions to be raised, so generally shouldnt be used
    # it is preffered to use the set method.
    def value=(v)
      assert_exists
      @o.value = v.to_s
    end
    
    private
    
    # This method is used internally by setText and appendText
    # It should not be used externally.
    #   * value - string - The string to enter into the text field
    def doKeyPress(value)
      value = limit_to_maxlength(value)
      for i in 0 .. value.length - 1
        sleep @container.typingspeed
        c = value[i,1]
        @o.value = @o.value.to_s + c   
        @o.fireEvent("onKeyDown")
        @o.fireEvent("onKeyPress")
        @o.fireEvent("onKeyUp")
      end
    end
    
    # Return the value (a string), limited to the maxlength of the element.
    def limit_to_maxlength(value)
      return value if @o.invoke('type') =~ /textarea/i # text areas don't have maxlength
      if value.length > maxlength
        value = value[0 .. maxlength - 1]
        @container.log " Supplied string is #{value.length} chars, which exceeds the max length (#{maxlength}) of the field. Using value: #{value}"
      end
      value
    end
  end
  
  # this class can be used to access hidden field objects
  # Normally a user would not need to create this object as it is returned by the Watir::Container#hidden method
  class Hidden < TextField
    INPUT_TYPES = ["hidden"]
    
    # set is overriden in this class, as there is no way to set focus to a hidden field
    def set(n)
      self.value = n
    end
    
    # override the append method, so that focus isnt set to the hidden object
    def append(n)
      self.value = self.value.to_s + n.to_s
    end
    
    # override the clear method, so that focus isnt set to the hidden object
    def clear
      self.value = ""
    end
    
    # this method will do nothing, as you cant set focus to a hidden field
    def focus
    end
    
  end
  
  # This class is the class for fields that accept file uploads
  # Windows dialog is opened and handled in this case by autoit 
  # launching into a new process. 
  class FileField < InputElement
    INPUT_TYPES = ["file"]
    
    # set the file location in the Choose file dialog in a new process
    # will raise a Watir Exception if AutoIt is not correctly installed
    def set(setPath)
      assert_exists
      require 'watir/windowhelper'
      WindowHelper.check_autoit_installed
      begin
        thrd = Thread.new do
          system("rubyw -e \"require 'win32ole'; @autoit=WIN32OLE.new('AutoItX3.Control'); waitresult=@autoit.WinWait 'Choose file', '', 15; if waitresult == 1\" -e \"@autoit.ControlSetText 'Choose file', '', 'Edit1', '#{setPath}'; @autoit.ControlSend 'Choose file', '', 'Button2', '{ENTER}';\" -e \"end\"")
        end
      thrd.join(1)
      rescue
        raise Watir::Exception::WatirException, "Problem accessing Choose file dialog"
      end
      click
    end
  end
  
  # This class is the class for radio buttons and check boxes.
  # It contains methods common to both.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkbox or Watir::Container#radio methods
  #
  # most of the methods available to this element are inherited from the Element class
  #
  class RadioCheckCommon < Element
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        @o = @container.locate_input_element(@how, @what, @type, @value)
      end
    end
    def initialize(container, how, what, type, value=nil)
      set_container container
      @how = how
      @what = what
      @type = type
      @value = value
      super(nil)
    end
    
    # BUG: rename me
    # This method determines if a radio button or check box is set.
    # Returns true is set/checked or false if not set/checked.
    # Raises UnknownObjectException if its unable to locate an object.
    def isSet?
      assert_exists
      return @o.checked
    end
    alias getState isSet?
    alias checked? isSet?
    
    # This method clears a radio button or check box. Note, with radio buttons one of them will almost always be set.
    # Returns true if set or false if not set.
    #   Raises UnknownObjectException if its unable to locate an object
    #         ObjectDisabledException IF THE OBJECT IS DISABLED
    def clear
      assert_enabled
      highlight(:set)
      set_clear_item(false)
      highlight(:clear)
    end
    
    # This method sets the radio list item or check box.
    #   Raises UnknownObjectException  if it's unable to locate an object
    #         ObjectDisabledException  if the object is disabled
    def set
      assert_enabled
      highlight(:set)
      set_clear_item(true)
      highlight(:clear)
    end
    
    # This method is the common code for setting or clearing checkboxes and radio.
    def set_clear_item(set)
      @o.checked = set
      @o.fireEvent("onClick")
      @container.wait
    end
    private :set_clear_item
    
  end
  
  #--
  #  this class makes the docs better
  #++
  # This class is the watir representation of a radio button.
  class Radio < RadioCheckCommon
  end
  
  # This class is the watir representation of a check box.
  class CheckBox < RadioCheckCommon
    
    # With no arguments supplied, sets the check box.
    # If the optional value is supplied, the checkbox is set, when its true and 
    # cleared when its false
    #   Raises UnknownObjectException if it's unable to locate an object
    #         ObjectDisabledException if the object is disabled
    def set(value=true)
      assert_enabled
      highlight :set
      unless @o.checked == value
        set_clear_item value
      end
      highlight :clear
    end
    
    # Clears a check box.
    #   Raises UnknownObjectException if its unable to locate an object
    #         ObjectDisabledException if the object is disabled
    def clear
      set false
    end
        
  end
  
  #--
  #   These classes are not for public consumption, so we switch off rdoc
  
  
  # presumes element_class or element_tag is defined
  # for subclasses of ElementCollections
  module CommonCollection
    def element_tag
      element_class::TAG
    end
    def length
      @container.document.getElementsByTagName(element_tag).length
    end
  end
  
  # This class is used as part of the .show method of the iterators class
  # it would not normally be used by a user
  class AttributeLengthPairs
    
    # This class is used as part of the .show method of the iterators class
    # it would not normally be used by a user
    class AttributeLengthHolder
      attr_accessor :attribute
      attr_accessor :length
      
      def initialize(attrib, length)
        @attribute = attrib
        @length = length
      end
    end
    
    def initialize(attrib=nil, length=nil)
      @attr=[]
      add(attrib, length) if attrib
      @index_counter = 0
    end
    
    # BUG: Untested. (Null implementation passes all tests.)
    def add(attrib, length)
      @attr << AttributeLengthHolder.new(attrib, length)
    end
    
    def delete(attrib)
      item_to_delete = nil
      @attr.each_with_index do |e,i|
        item_to_delete = i if e.attribute == attrib
      end
      @attr.delete_at(item_to_delete) unless item_to_delete == nil
    end
    
    def next
      temp = @attr[@index_counter]
      @index_counter += 1
      return temp
    end
    
    def each
      0.upto(@attr.length-1) { |i | yield @attr[i]   }
    end
  end
  
  #    resume rdoc
  #++
  
  # this class accesses the buttons in the document as a collection
  # it would normally only be accessed by the Watir::Container#buttons method
  class Buttons < ElementCollections
    def element_class; Button; end
    def length
      get_length_of_input_objects(["button", "submit", "image"])
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("disabled", 9)
      @show_attributes.add("value", 20)
    end
  end
  
  # this class accesses the file fields in the document as a collection
  # normal access is via the Container#file_fields method
  class FileFields < ElementCollections
    def element_class; FileField; end
    def length
      get_length_of_input_objects(["file"])
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("disabled", 9)
      @show_attributes.add("value", 20)
    end
  end
  
  # this class accesses the check boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkboxes method
  class CheckBoxes < ElementCollections
    def element_class; CheckBox; end
    def length
      get_length_of_input_objects("checkbox")
    end
    
    private
    def iterator_object(i)
      @container.checkbox(:index, i + 1)
    end
  end
  
  # this class accesses the radio buttons in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#radios method
  class Radios < ElementCollections
    def element_class; Radio; end
    def length
      get_length_of_input_objects("radio")
    end
    
    private
    def iterator_object(i)
      @container.radio(:index, i + 1)
    end
  end
    
  # this class accesses the select boxes in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_lists method
  class SelectLists < ElementCollections
    include CommonCollection
    def element_class; SelectList; end
    def element_tag; 'SELECT'; end
  end
  
  # this class accesses the links in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#links method
  class Links < ElementCollections
    include CommonCollection
    def element_class; Link; end
    def element_tag; 'A'; end
    
    private
    def set_show_items
      super
      @show_attributes.add("href", 60)
      @show_attributes.add("innerText", 60)
    end
  end
  
  class Lis  < ElementCollections
    include Watir::CommonCollection
    def element_class; Li; end
    
    def set_show_items
      super
      @show_attributes.delete( "name")
      @show_attributes.add( "className" , 20)
    end
  end
  
  class Map < NonControlElement
    TAG = 'MAP'
  end

  class Area < NonControlElement
    TAG = 'AREA'
  end
  
  # this class accesses the maps in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#maps method
  class Maps < ElementCollections
    include CommonCollection
    def element_class; Map; end
    def element_tag; 'MAP'; end
  end


  # this class accesses the areas in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#areas method
  class Areas < ElementCollections
    include CommonCollection
    def element_class; Area; end
    def element_tag; 'AREA'; end
  end
  
  # this class accesses the imnages in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#images method
  class Images < ElementCollections
    def element_class; Image; end
    def length
      @container.document.images.length
    end
    
    private
    def set_show_items
      super
      @show_attributes.add("src", 60)
      @show_attributes.add("alt", 30)
    end
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_fields method
  class TextFields < ElementCollections
    def element_class; TextField; end
    def length
      # text areas are also included in the TextFields, but we need to get them seperately
      get_length_of_input_objects(["text", "password"]) +
      @container.document.getElementsByTagName("textarea").length
    end
  end
  
  # this class accesses the hidden fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#hiddens method
  class Hiddens < ElementCollections
    def element_class; Hidden; end
    def length
      get_length_of_input_objects("hidden")
    end
  end
  
  # this class accesses the text fields in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#tables method
  class Tables < ElementCollections
    include CommonCollection
    def element_class; Table; end
    def element_tag; 'TABLE'; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
    end
  end
  # this class accesses the table rows in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#rows method
  class TableRows < ElementCollections
    include CommonCollection
    def element_class; TableRow; end
    def element_tag; 'TR'; end
  end
  # this class accesses the table cells in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#cells method
  class TableCells < ElementCollections
    include CommonCollection
    def element_class; TableCell; end
    def element_tag; 'TD'; end
  end
  # this class accesses the labels in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#labels method
  class Labels < ElementCollections
    include CommonCollection
    def element_class; Label; end
    def element_tag; 'LABEL'; end
    
    private
    def set_show_items
      super
      @show_attributes.add("htmlFor", 20)
    end
  end
  
  # this class accesses the pre tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#pres method
  class Pres < ElementCollections
    include CommonCollection
    def element_class; Pre; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end
  
  # this class accesses the p tags in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#ps method
  class Ps < ElementCollections
    include CommonCollection
    def element_class; P; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
    
  end
  # this class accesses the spans in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#spans method
  class Spans < ElementCollections
    include CommonCollection
    def element_class; Span; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end
  
  # this class accesses the divs in the document as a collection
  # Normally a user would not need to create this object as it is returned by the Watir::Container#divs method
  class Divs < ElementCollections
    include CommonCollection
    def element_class; Div; end
    
    private
    def set_show_items
      super
      @show_attributes.delete("name")
      @show_attributes.add("className", 20)
    end
  end

  # Move to Watir::Utils
  
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
require 'watir/bonus-elements'

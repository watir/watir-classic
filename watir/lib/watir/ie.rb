module Watir
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

    # BUG: this interface invites misunderstanding/misuse such as IE.defaults[:speed] = :zippy]
		def self.defaults 	
			{:speed => self.speed, :visible => self.visible}
	  end
    # Not a great interface either, since IE.defaults = {} does not erase.
		def self.defaults= options
			options.each do |name, value|
				send "#{name}=", value
			end
		end
		# The globals $FAST_SPEED and $HIDE_IE are checked both at initialization 
		# and later, because they
		# might be set after initialization. Setting them beforehand (e.g. from
		# the command line) will affect the class, otherwise it is only a temporary
		# effect
		@@speed = $FAST_SPEED ? :fast : :slow
		def self.speed
			return :fast if $FAST_SPEED
			@@speed
		end
		def self.speed= x
			$FAST_SPEED = nil
			@@speed = x
		end
		@@visible = $HIDE_IE ? false : true
		def self.visible
			return false if $HIDE_IE
			@@visible
		end
		def self.visible= x
			$HIDE_IE = nil
			@@visible = x
		end
		    
    # The revision number (according to Subversion)
    REVISION_STRING = '$Revision: 1263 $'
    REVISION_STRING.scan(/Revision: (\d*)/)
    REVISION = $1 or 'unknown'
    
    # The Release number
    VERSION_SHORT = '1.5.6'
    VERSION = VERSION_SHORT + '.' + REVISION
    
    # Used internally to determine when IE has finished loading a page
    READYSTATE_COMPLETE = 4
       
    # The default color for highlighting objects as they are accessed.
    HIGHLIGHT_COLOR = 'yellow'
    
    # IE inserts some element whose tagName is empty and just acts as block level element
    # Probably some IE method of cleaning things
    # To pass the same to REXML we need to give some name to empty tagName
    EMPTY_TAG_NAME = "DUMMY"
    
    # The time, in seconds, it took for the new page to load after executing the
    # the last command
    attr_reader :down_load_time
    
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
      initialize_options
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
      initialize_options
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
      initialize_options
      wait
    end

    # Return an IE object that wraps the given window, typically obtained from
    # Shell.Application.windows.
    def self.bind window
      ie = new true
      ie.ie = window
      ie.initialize_options
      ie
    end
  
    def create_browser_window
      @ie = WIN32OLE.new('InternetExplorer.Application')
    end
    private :create_browser_window
    
    def initialize_options
      self.visible = IE.visible
      self.speed = IE.speed

      @ole_object = nil
      @page_container = self
      @error_checkers = []
      @activeObjectHighLightColor = HIGHLIGHT_COLOR

      
      @logger = DefaultLogger.new
      @url_list = []
    end

    # Specifies the speed that commands will be executed at. Choices are:
    # * :slow (default)
    # * :fast 
    # * :zippy
    # With IE#speed=  :zippy, text fields will be entered at once, instead of
    # character by character (default).
    def speed= how_fast
      case how_fast
      when :zippy :
	      @typingspeed = 0
	      @pause_after_wait = 0.01
	      @type_keys = false
	      @speed = :fast
      when :fast : 
	      @typingspeed = 0
	      @pause_after_wait = 0.01
	      @type_keys = true
	      @speed = :fast
      when :slow :
	      @typingspeed = 0.08
	      @pause_after_wait = 0.1
	      @type_keys = true
	      @speed = :slow
      else
        raise ArgumentError, "Invalid speed: #{how_fast}"
      end
    end
    
    def speed
      return @speed if @speed == :slow
      return @type_keys ? :fast : :zippy
    end
    
    # deprecated: use speed = :fast instead
    def set_fast_speed
    	self.speed = :fast
    end

    # deprecated: use speed = :slow instead    
    def set_slow_speed
    	self.speed = :slow
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
        sleep @pause_after_wait unless no_sleep
        return @down_load_time
      end
            
      while doc = documents_to_wait_for.shift
        begin
          until doc.readyState == "complete" do
            sleep a_moment
          end
          @url_list << doc.location.href unless @url_list.include?(doc.location.href)
          doc.frames.length.times do |n|
            begin
              documents_to_wait_for << doc.frames[n.to_s].document
            rescue WIN32OLERuntimeError, NoMethodError
            end
          end
        rescue WIN32OLERuntimeError
        end
      end

      @down_load_time = Time.now - start_load_time
      run_error_checks
      sleep @pause_after_wait unless no_sleep
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
end
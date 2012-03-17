module Watir
  class IE
    include WaitHelper
    include Exception
    include Container
    include PageContainer

    # Maximum number of seconds to wait when attaching to a window
    @@attach_timeout = 2.0 # default value
    def self.attach_timeout
      @@attach_timeout
    end
    def self.attach_timeout=(timeout)
      @@attach_timeout = timeout
    end

    # Return the options used when creating new instances of IE.
    # BUG: this interface invites misunderstanding/misuse such as IE.options[:speed] = :zippy]
    def self.options
      {:speed => self.speed, :visible => self.visible, :attach_timeout => self.attach_timeout, :zero_based_indexing => self.zero_based_indexing}
    end
    # set values for options used when creating new instances of IE.
    def self.set_options options
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

    @@zero_based_indexing = true
    def self.zero_based_indexing= enabled
      @@zero_based_indexing = enabled
    end

    def self.zero_based_indexing
      @@zero_based_indexing
    end

    def self.base_index
      self.zero_based_indexing ? 0 : 1
    end  

    # Used internally to determine when IE has finished loading a page
    READYSTATES = {:complete => 4}

    # The default color for highlighting objects as they are accessed.
    HIGHLIGHT_COLOR = 'yellow'

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
      when :zippy then
        @typingspeed = 0
        @pause_after_wait = 0.01
        @type_keys = false
        @speed = :fast
      when :fast then
        @typingspeed = 0
        @pause_after_wait = 0.01
        @type_keys = true
        @speed = :fast
      when :slow then
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
      ie_browsers = []
      shell.Windows.each do |window|
        next unless (window.path =~ /Internet Explorer/ rescue false)
        next unless (hwnd = window.hwnd rescue false)
        ie = IE.bind(window)
        ie.hwnd = hwnd
        ie_browsers << ie
      end
      ie_browsers.each do |ie|
        yield ie
      end
    end

    def self.version
      @ie_version ||= begin
                        require 'win32/registry'
                        ::Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Microsoft\\Internet Explorer") do |ie_key|
                          ie_key.read('Version').last
                        end
                        # OR: ::WIN32OLE.new("WScript.Shell").RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Internet Explorer\\Version")
                      end
    end

    def self.version_parts
      version.split('.')
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
      self._find_all(how, what).first
    end

    def self._find_all(how, what)
      ies = []
      count = -1
      IE.each do |ie|
        window = ie.ie

        case how
        when :url
          ies << window if (what.matches(window.locationURL))
        when :title
          # normal windows explorer shells do not have document
          # note window.document will fail for "new" browsers
          begin
            title = window.locationname
            title = window.document.title
          rescue WIN32OLERuntimeError
          end
          ies << window if what.matches(title)
        when :hwnd
          begin
            ies << window if what == window.HWND
          rescue WIN32OLERuntimeError
          end
        when :index
          count += 1
          if count == what
            ies << window
            break
          end
        when nil
          ies << window
        else
          raise ArgumentError
        end
      end      

      ies
    end

    # Return the current window handle
    def hwnd
      raise "Not attached to a browser" if @ie.nil?
      @hwnd ||= @ie.hwnd
    end
    attr_writer :hwnd

    # Are we attached to an open browser?
    def exists?
      begin
        !!(@ie.name =~ /Internet Explorer/)
      rescue WIN32OLERuntimeError, NoMethodError
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
      return @ie.statusText
    end

    #
    # Navigation
    #

    # Navigate to the specified URL.
    #  * url - string - the URL to navigate to
    def goto(url)
      url = "http://" + url unless url =~ %r{://} || url == "about:blank"
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

    def inspect
      '#<%s:0x%x url=%s title=%s>' % [self.class, hash*2, url.inspect, title.inspect]
    end

    # clear the list of urls that we have visited
    def clear_url_list
      @url_list.clear
    end

    # Closes the Browser
    def close
      return unless exists?
      @ie.stop
      wait rescue nil
      chwnd = @ie.hwnd.to_i
      @ie.quit
      t = ::Time.now
      while exists?
        # just in case to avoid possible endless loop if failing to close some
        # window or tab
        break if ::Time.now - t > 10
        sleep 0.3
      end
    end

    # Maximize the window (expands to fill the screen)
    def maximize
      rautomation.maximize
    end

    # Minimize the window (appears as icon on taskbar)
    def minimize
      rautomation.minimize
    end

    def minimized?
      rautomation.minimized?
    end

    # Restore the window (after minimizing or maximizing)
    def restore
      rautomation.restore
    end

    # Make the window come to the front
    def activate
      rautomation.activate
    end
    alias :bring_to_front :activate

    def active?
      rautomation.active?
    end
    alias :front? :active?

    def rautomation
      @rautomation ||= ::RAutomation::Window.new(:hwnd => hwnd)
      @rautomation
    end

    def autoit
      Kernel.warn "Usage of Watir::IE#autoit method is DEPRECATED! Use Watir::IE#rautomation method instead. Refer to https://github.com/jarmo/RAutomation for updating your scripts."
      @autoit ||= ::RAutomation::Window.new(:hwnd => hwnd, :adapter => :autoit)
      @autoit
    end

    # Activates the window and sends keys to it.
    #
    # Example:
    #   browser.send_keys("Hello World{enter}")
    #
    # Refer to RAutomation::Adapter::WinFfi::KeystrokeConverter.convert_special_characters for
    # special characters conversion.
    # @see RAutomation::Window#send_keys
    def send_keys(*keys)
      rautomation.send_keys *keys
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

    def window(specifiers={}, &blk)
      win = Window.new(self, specifiers, &blk)
      win.use &blk if blk
      win
    end

    def windows(specifiers={}, &blk)
      self.class._find_all(specifiers.keys.first, specifiers.values.first).map {|ie| Window.new(self, specifiers, IE.bind(ie), &blk)}
    end

    def cookies
      Cookies.new(self)
    end

    #
    # Synchronization
    #

    # Block execution until the page has loaded.
    #
    # Will raise Timeout::Error if page hasn't been loaded within 5 minutes.
    # =nodoc
    # Note: This code needs to be prepared for the ie object to be closed at 
    # any moment!
    def wait(no_sleep=false)
      @xml_parser_doc = nil
      @down_load_time = 0.0
      interval = 0.05
      start_load_time = ::Time.now

      Timeout::timeout(5*60) do
        begin
          while @ie.busy
            sleep interval
          end

          until READYSTATES.has_value?(@ie.readyState)
            sleep interval
          end

          until @ie.document
            sleep interval
          end

          documents_to_wait_for = [@ie.document]
        rescue WIN32OLERuntimeError # IE window must have been closed
          @down_load_time = ::Time.now - start_load_time
          return @down_load_time
        end

        while doc = documents_to_wait_for.shift
          begin
            until READYSTATES.has_key?(doc.readyState.to_sym)
              sleep interval
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
      end

      @down_load_time = ::Time.now - start_load_time
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
      if all_forms = self.forms
        count = all_forms.length
        puts "There are #{count} forms"
        all_forms.each do |form|
          puts "Form name: #{form.name}"
          puts "       id: #{form.id}"
          puts "   method: #{form.method}"
          puts "   action: #{form.action}"
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
          s += " / " + n.getElementsByTagName("IMG").item(0).src
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
      active_element = document.activeElement
      active_element.blur unless active_element.tagName == "BODY"
      document.focus
    end

    def attach_command
      "Watir::IE.attach(:hwnd, #{hwnd})"
    end

    private

    def create_browser_window
      @ie = WIN32OLE.new('InternetExplorer.Application')
    end

    def attach_browser_window how, what
      log "Seeking Window with #{how}: #{what}"
      ieTemp = nil
      begin
        Watir::until_with_timeout do
          ieTemp = IE._find how, what
        end
      rescue Watir::Wait::TimeoutError
        raise NoMatchingWindowFoundException,
        "Unable to locate a window with #{how} of #{what}"
      end
      @ie = ieTemp
    end

  end # class IE
end

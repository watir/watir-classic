module Watir
  # Main browser class.
  class IE
    include WaitHelper
    include Exception
    include Container
    include PageContainer

    class << self
      # Maximum number of seconds to wait when attaching to a window
      attr_writer :attach_timeout

      def attach_timeout
        @attach_timeout ||= 2
      end

      # Return the options used when creating new instances of IE.
      # BUG: this interface invites misunderstanding/misuse such as IE.options[:speed] = :zippy]
      def options
        {:speed => self.speed, :visible => self.visible, :attach_timeout => self.attach_timeout}
      end

      # set values for options used when creating new instances of IE.
      def set_options options
        options.each do |name, value|
          send "#{name}=", value
        end
      end

      # The speed in which browser will type keys etc. Possible values are
      # :slow (default), :fast and :zippy.
      attr_writer :speed

      def speed
        @speed ||= :slow
      end

      # Set browser window to visible or hidden. Defaults to true.
      attr_writer :visible

      def visible
        @visible ||= true
      end

      # Create a new IE window.
      def new_window
        ie = new true
        ie._new_window_init
        ie
      end

      # Create a new IE, starting at the specified url.
      # @param [String] url url to navigate to.
      def start(url=nil)
        start_window url
      end

      # Create a new IE window, starting at the specified url.
      # @param [String] url url to navigate to.
      def start_window(url=nil)
        ie = new_window
        ie.goto url if url
        ie
      end

      # Create a new IE window in a new process. 
      # @note This method will not work when
      #   Watir/Ruby is run under a service (instead of a user).
      def new_process
        ie = new true
        ie._new_process_init
        ie
      end

      # Create a new IE window in a new process, starting at the specified URL. 
      # @param [String] url url to navigate to.
      def start_process(url=nil)
        ie = new_process
        ie.goto url if url
        ie
      end

      # Attach to an existing IE {Browser}.
      #
      # @example Attach with full title:
      #   Watir::Browser.attach(:title, "Full title of IE")
      #
      # @example Attach with part of the title using {Regexp}:
      #   Watir::Browser.attach(:title, /part of the title of IE/)
      #
      # @example Attach with part of the url:
      #   Watir::Browser.attach(:url, /google/)
      #
      # @example Attach with window handle:
      #   Watir::Browser.attach(:hwnd, 123456)
      #
      # @param [Symbol] how type of the locator. Can be :title, :url or :hwnd.
      # @param [Symbol] what value of the locator. Can be {String}, {Regexp} or {Fixnum}
      #   depending of the type parameter.
      #
      # @note This method will not work when
      #   Watir/Ruby is run under a service (instead of a user).
      def attach(how, what)
        ie = new true # don't create window
        ie._attach_init(how, what)
        ie
      end

      # Yields successively to each IE window on the current desktop. Takes a block.
      # @note This method will not work when
      #   Watir/Ruby is run under a service (instead of a user).
      # @yieldparam [IE] ie instances of IE found.
      def each
        shell = WIN32OLE.new('Shell.Application')
        ie_browsers = []
        shell.Windows.each do |window|
          next unless (window.path =~ /Internet Explorer/ rescue false)
          next unless (hwnd = window.hwnd rescue false)
          ie = bind(window)
          ie.hwnd = hwnd
          ie_browsers << ie
        end
        ie_browsers.each do |ie|
          yield ie
        end
      end

      # @return [String] the IE browser version number as a string.
      def version
        @ie_version ||= begin
                          require 'win32/registry'
                          ::Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Microsoft\\Internet Explorer") do |ie_key|
                            ie_key.read('Version').last
                          end
                          # OR: ::WIN32OLE.new("WScript.Shell").RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Internet Explorer\\Version")
                        end
      end

      # @return [Array<String>] the IE browser version numbers split by "." in an Array.
      def version_parts
        version.split('.')
      end

      # Find existing IE window with locators.
      # @see .attach
      def find(how, what)
        ie_ole = _find(how, what)
        bind ie_ole if ie_ole
      end

      # Return an IE object that wraps the given window, typically obtained from
      # Shell.Application.windows.
      # @private
      def bind(window)
        ie = new true
        ie.ie = window
        ie.initialize_options
        ie
      end

      # @private
      def _find(how, what)
        _find_all(how, what).first
      end

      # @private
      def _find_all(how, what)
        ies = []
        count = -1
        each do |ie|
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

    end

    # Used internally to determine when IE has finished loading a page.
    # @private
    READYSTATES = {:complete => 4}

    # The default color for highlighting objects as they are accessed.
    # @private
    HIGHLIGHT_COLOR = 'yellow'

    # The time, in seconds, it took for the new page to load after executing
    # the last command.
    attr_reader :down_load_time

    # The OLE Internet Explorer object.
    attr_accessor :ie

    # The list of unique urls that have been visited.
    attr_reader :url_list

    # @private
    attr_writer :hwnd

    # Create an IE browser instance.
    # @param [Boolean] suppress_new_window set to true for not creating a IE
    #   window.
    def initialize(suppress_new_window=nil)
      _new_window_init unless suppress_new_window
    end

    # Specifies the speed that commands will be executed at.
    # Possible choices are:
    # * :slow (default)
    # * :fast 
    # * :zippy
    # 
    # With :zippy, text fields will be entered at once, instead of
    # character by character.
    #
    # @note :zippy speed does not trigger JavaScript events like onChange etc.
    #
    # @param [Symbol] how_fast possible choices are :slow (default), :fast and
    #   :zippy
    # @raise [ArgumentError] when invalid speed is specified.
    def speed=(how_fast)
      case how_fast
      when :zippy
        @typingspeed = 0
        @pause_after_wait = 0.01
        @type_keys = false
        @speed = :fast
      when :fast
        @typingspeed = 0
        @pause_after_wait = 0.01
        @type_keys = true
        @speed = :fast
      when :slow
        @typingspeed = 0.08
        @pause_after_wait = 0.1
        @type_keys = true
        @speed = :slow
      else
        raise ArgumentError, "Invalid speed: #{how_fast}. Possible choices are :slow, :fast and :zippy."
      end
    end

    # @return [Symbol] current speed setting. May be :slow, :fast or :zippy.
    def speed
      return @speed if @speed == :slow
      return @type_keys ? :fast : :zippy
    end

    # @deprecated Use {#speed=} with :fast argument instead.
    def set_fast_speed
      Kernel.warn "Deprecated(IE.set_fast_speed) - use Browser#speed = :fast instead."
      self.speed = :fast
    end

    # @deprecated Use {#speed=} with :slow argument instead.
    def set_slow_speed
      Kernel.warn "Deprecated(IE.set_slow_speed) - use Browser#speed = :slow instead."
      self.speed = :slow
    end

    # @return [Boolean] true when window is visible, false otherwise.
    def visible
      @ie.visible
    end
    
    # Set the visibility of IE window.
    # @param [Boolean] boolean set to true if IE window should be visible, false
    #   otherwise.
    def visible=(boolean)
      @ie.visible = boolean if boolean != @ie.visible
    end

    # @return [Fixnum] current IE window handle.
    # @raise [RuntimeError] when not attached to a browser.
    def hwnd
      raise "Not attached to a browser" if @ie.nil?
      @hwnd ||= @ie.hwnd
    end

    # @return [Symbol] the name of the browser. Is always :ie.
    def name
      :ie
    end

    # @return [Boolean] true when IE is window exists, false otherwise.
    def exists?
      !!(@ie.name =~ /Internet Explorer/)
    rescue WIN32OLERuntimeError, NoMethodError
      false
    end

    alias :exist? :exists?

    # @return [String] the title of the document.
    def title
      @ie.document.title
    end

    # @return [String] the status text of the window, typically from the status bar at the bottom.
    #   Will be empty if there's no status or when there are problems accessing status text.
    def status
      @ie.statusText
    rescue WIN32OLERuntimeError
      ""
    end

    #
    # Navigation
    #

    # Navigate to the specified URL.
    # @param [String] url url to navigate to.
    # @return [Fixnum] time in seconds the page took to load.
    def goto(url)
      url = "http://" + url unless url =~ %r{://} || url == "about:blank"
      @ie.navigate(url)
      wait
      return @down_load_time
    end

    # Go to the previous page - the same as clicking the browsers back button.
    # @raise [WIN32OLERuntimeError] when the browser can't go back.
    def back
      @ie.GoBack
      wait
    end

    # Go to the next page - the same as clicking the browsers forward button.
    # @raise [WIN32OLERuntimeError] when the browser can't go forward.
    def forward
      @ie.GoForward
      wait
    end

    # Refresh the current page - the same as clicking the browsers refresh button.
    # @raise [WIN32OLERuntimeError] when the browser can't refresh.
    def refresh
      @ie.refresh2(3)
      wait
    end

    def inspect
      '#<%s:0x%x url=%s title=%s>' % [self.class, hash*2, url.inspect, title.inspect]
    end

    # Clear the list of urls that have been visited.
    def clear_url_list
      @url_list.clear
    end

    # Close the {Browser}.
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

    # Maximize the window (expands to fill the screen).
    def maximize
      rautomation.maximize
    end

    # Minimize the window (appears as icon on taskbar).
    def minimize
      rautomation.minimize
    end

    # @return [Boolean] true when window is minimized, false otherwise.
    def minimized?
      rautomation.minimized?
    end

    # Restore the window (after minimizing or maximizing).
    def restore
      rautomation.restore
    end

    # Make the window come to the front.
    def activate
      rautomation.activate
    end

    alias :bring_to_front :activate

    # @return [Boolean] true when window is in front e.g. in focus, false otherwise.
    def active?
      rautomation.active?
    end

    alias :front? :active?

    # @return [RAutomation::Window] the RAutomation instance for this IE window.
    # @see https://github.com/jarmo/rautomation
    def rautomation
      @rautomation ||= ::RAutomation::Window.new(:hwnd => hwnd)
    end

    # @deprecated use {#rautomation} instead.
    def autoit
      Kernel.warn "Deprecated(IE#autoit) - use IE#rautomation instead. Refer to https://github.com/jarmo/RAutomation for updating your scripts."
      @autoit ||= ::RAutomation::Window.new(:hwnd => hwnd, :adapter => :autoit)
    end

    # Activates the window and sends keys to it.
    #
    # @example
    #   browser.send_keys("Hello World", :enter)
    #
    # @see https://github.com/jarmo/RAutomation/blob/master/lib/rautomation/adapter/win_32/window.rb RAutomation::Window#send_keys documentation.
    def send_keys(*keys)
      rautomation.send_keys *keys
    end

    #
    # Document and Document Data
    #

    # @return [WIN32OLE] current IE document.
    def document
      @ie.document
    end

    # @return [String] current url, as displayed in the address bar of the browser.
    def url
      @ie.LocationURL
    end

    # Create a {Screenshot} instance.
    def screenshot
      Screenshot.new(hwnd)
    end

    # Retrieve a {Window} instance.
    # 
    # @example Retrieve a different window without block.
    #   browser.window(:title => /other window title/).use
    #   browser.title # => "other window title"
    #
    # @example Use different window with block.
    #   browser.window(:title => /other window title/) do
    #     browser.title # => "other window title"
    #   end
    #   browser.title # => "current window title"
    #
    # @param [Hash] specifiers options for finding window.
    # @option specifiers [String,Regexp] :title Title of the window.
    # @option specifiers [String,Regexp] :url Url of the window.
    # @option specifiers [Fixnum] :index The index of the window.
    # @yield yield optionally to the found window.
    # @return [Window] found window instance.
    def window(specifiers={}, &blk)
      win = Window.new(self, specifiers, &blk)
      win.use &blk if blk
      win
    end

    # @see #window
    # @return [Array<Window>] array of found windows.
    def windows(specifiers={})
      self.class._find_all(specifiers.keys.first, specifiers.values.first).map {|ie| Window.new(self, specifiers, IE.bind(ie))}
    end

    # Retrieve {Cookies} instance.
    def cookies
      Cookies.new(self)
    end

    # Add an error checker that gets executed after every page load, click etc.
    #
    # @example
    #   browser.add_checker lambda { |browser| raise "Error!" if browser.text.include? "Error" }
    #
    # @param [Proc] checker Proc object which gets yielded with {IE} instance.
    def add_checker(checker)
      @error_checkers << checker
    end

    # Disable an error checker added via {#add_checker}.
    #
    # @param [Proc] checker Proc object to be removed from error checkers.
    def disable_checker(checker)
      @error_checkers.delete(checker)
    end

    # Gives focus to the window frame.
    def focus
      active_element = document.activeElement
      active_element.blur unless active_element.tagName == "BODY"
      document.focus
    end

    # @private
    def attach_command
      "Watir::IE.attach(:hwnd, #{hwnd})"
    end

    # @private
    def _new_window_init
      create_browser_window
      initialize_options
      goto 'about:blank' # this avoids numerous problems caused by lack of a document
    end

    # @private
    def _new_process_init
      iep = Process.start
      @ie = iep.window
      @process_id = iep.process_id
      initialize_options
      goto 'about:blank'
    end

    # this method is used internally to attach to an existing window
    # @private
    def _attach_init how, what
      attach_browser_window how, what
      initialize_options
      wait
    end

    # @private
    def initialize_options
      self.visible = IE.visible
      self.speed = IE.speed

      @ole_object = nil
      @page_container = self
      @error_checkers = []
      @active_object_highlight_color = HIGHLIGHT_COLOR
      @url_list = []
    end

    #
    # Synchronization
    #

    # Block execution until the page has loaded.
    #
    # Will raise Timeout::Error if page hasn't been loaded within 5 minutes.
    # Note: This code needs to be prepared for the ie object to be closed at 
    # any moment!
    #
    # @private
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

    # Run the predefined error checks.
    #
    # @private
    def run_error_checks
      @error_checkers.each { |e| e.call(self) }
    end

    private

    def create_browser_window
      @ie = WIN32OLE.new('InternetExplorer.Application')
    end

    def attach_browser_window how, what
      ieTemp = nil
      begin
        Wait.until(IE.attach_timeout) do
          ieTemp = IE._find how, what
        end
      rescue Wait::TimeoutError
        raise NoMatchingWindowFoundException,
        "Unable to locate a window with #{how} of #{what}"
      end
      @ie = ieTemp
    end


  end # class IE
end

module Watir
  # Base class for html elements.
  # This is not a class that users would normally access.
  class Element # Wrapper
    include Comparable
    include ElementExtensions
    include Exception
    include Container # presumes @container is defined
    include DragAndDropHelper

    attr_accessor :container

    class << self

      private

      # @!macro attr_ole
      #   @!method $1
      #   Retrieve element's $1 from the $2 OLE method.
      #   @see http://msdn.microsoft.com/en-us/library/hh773183(v=vs.85).aspx MSDN Documentation
      #   @return [String, Boolean, Fixnum] element's "$1" attribute value.
      #     Return type depends of the attribute type.
      #   @return [String] an empty String if the "$1" attribute does not exist.
      #   @macro exists
      def attr_ole(method_name, ole_method_name=nil)
        class_eval %Q[
          def #{method_name}
            assert_exists
            ole_method_name = '#{ole_method_name || method_name.to_s.gsub(/\?$/, '')}'
            ole_object.invoke(ole_method_name) rescue attribute_value(ole_method_name) || '' rescue ''
          end]
      end
    end

    attr_ole :id
    attr_ole :title
    attr_ole :class_name, :className
    attr_ole :unique_number, :uniqueNumber
    attr_ole :html, :outerHTML

    # number of spaces that separate the property from the value in the to_s method
    # @private
    TO_S_SIZE = 14

    def initialize(container, specifiers)
      set_container container
      raise ArgumentError, "#{specifiers.inspect} has to be Hash" unless specifiers.is_a?(Hash)

      @o = specifiers[:ole_object]
      @specifiers = specifiers
    end

    def <=> other
      assert_exists
      other.assert_exists
      ole_object.sourceindex <=> other.ole_object.sourceindex
    end

    alias_method :eql?, :==

      # @return [WIN32OLE] OLE object of the element, allowing any methods of the DOM
      #   that Watir doesn't support to be used.
      def ole_object
        @o
      end

    def inspect
      '#<%s:0x%x located=%s specifiers=%s>' % [self.class, hash*2, !!ole_object, @specifiers.inspect]
    end

    def to_s
      assert_exists
      string_creator.join("\n")
    end

    # @return [String] element's html tag name in downcase.
    # @macro exists
    def tag_name
      assert_exists
      @o.tagName.downcase
    end

    # Cast {Element} into specific subclass.
    # @example Convert div element to {Div} class:
    #   browser.element(:tag_name => "div").to_subtype # => Watir::Div
    # @return {Element} element casted into specific sub-class of Element.
    # @macro exists
    def to_subtype
      assert_exists

      tag = tag_name
      if tag == "html"
        element(:ole_object => ole_object)
      elsif tag == "input"
        send(ole_object.invoke('type'), :ole_object => ole_object)
      elsif tag == "select"
        select_list(:ole_object => ole_object)
      elsif respond_to?(tag.downcase)
        send(tag.downcase, :ole_object => ole_object)
      else
        self
      end
    end

    # Send keys to the element
    # @example
    #   browser.text_field.send_keys "hello", [:control, "a"], :backspace
    # @param [String, Array<Symbol, String>, Symbol] keys Keys to send to the element.
    # @see https://github.com/jarmo/RAutomation/blob/master/lib/rautomation/adapter/win_32/window.rb RAutomation::Window#send_keys documentation.
    def send_keys(*keys)
      focus
      page_container.send_keys *keys
    end

    # Retrieve element's css style.
    # @param [String] property When property is specified then only css for that property is returned. 
    # @return [String] css style as a one long String.
    # @return [String] css style for specified property if property parameter is specified.
    # @macro exists
    def style(property=nil)
      assert_exists
      css = ole_object.style.cssText

      if property
        properties = Hash[css.downcase.split(";").map { |p| p.split(":").map(&:strip) }]
        properties[property]
      else
        css
      end
    end

    # The text value of the element between html tags.
    # @return [String] element's text.
    # @return [String] empty String when element is not visible.
    # @macro exists
    def text
      assert_exists
      visible? ? ole_object.innerText.strip : ""
    end

    # Retrieve the element immediately containing self.
    # @return [Element] parent element of self.
    # @return [Element] self when parent element does not exist.
    # @macro exists
    def parent
      assert_exists
      parent_element = ole_object.parentelement
      return unless parent_element
      Element.new(self, :ole_object => parent_element).to_subtype
    end

    # Performs a left click on the element.
    # Will wait automatically until browser is ready after the click if page load was triggered for example.
    # @macro exists
    # @macro enabled
    def click
      click!
      @container.wait
    end

    # Performs a right click on the element.
    # Will wait automatically until browser is ready after the click if page load was triggered for example.
    # @macro enabled
    # @macro exists
    def right_click
      perform_action {fire_event("oncontextmenu"); @container.wait}
    end

    # Performs a double click on the element.
    # Will wait automatically until browser is ready after the click if page load was triggered for example.
    # @macro exists
    # @macro enabled
    def double_click
      perform_action {fire_event("ondblclick"); @container.wait}
    end

    # Flash the element the specified number of times for troubleshooting purposes.
    # @param [Fixnum] number Number times to flash the element.
    # @macro exists
    def flash(number=10)
      assert_exists
      number.times do
        highlight(:set)
        sleep 0.05
        highlight(:clear)
        sleep 0.05
      end
      self
    end

    # Executes a user defined "fireEvent" for element with JavaScript events.
    #
    # @example Fire a onchange event on select_list:
    #   browser.select_list.fire_event "onchange"
    #
    # @macro exists
    def fire_event(event)
      perform_action {dispatch_event(event); @container.wait}
    end

    # Set focus on the element.
    # @macro exists
    # @macro enabled
    def focus
      assert_exists
      assert_enabled
      @container.focus
      ole_object.focus(0)
    end

    # @return [Boolean] true when element is in focus, false otherwise.
    # @macro exists
    # @macro enabled
    def focused?
      assert_exists
      assert_enabled
      @page_container.document.activeElement.uniqueNumber == unique_number
    end

    # @return [Boolean] true when element exists, false otherwise.
    def exists?
      begin
        locate
      rescue WIN32OLERuntimeError, UnknownObjectException
        @o = nil
      end
      !!@o
    end

    alias :exist? :exists?

    # @return [Boolean] true if the element is enabled, false otherwise.
    # @macro exists
    def enabled?
      assert_exists
      !disabled?
    end

    # @return [Boolean] true if the element is disabled, false otherwise.
    # @macro exists
    def disabled?
      assert_exists
      false
    end

    # Retrieve the status of element's visibility.
    # When any parent element is not also visible then the current element is determined as not visible too.
    # @return [Boolean] true if element is visible, false otherwise.
    # @macro exists
    def visible?
      # Now iterate up the DOM element tree and return false if any
      # parent element isn't visible 
      assert_exists
      object = @o
      while object
        begin
          if object.currentstyle.invoke('visibility') =~ /^hidden$/i
            return false
          end
          if object.currentstyle.invoke('display') =~ /^none$/i
            return false
          end
        rescue WIN32OLERuntimeError
        end
        object = object.parentElement
      end
      true
    end

    # Get attribute value for any attribute of the element.
    # @return [String] the value of the attribute.
    # @return [Object] nil if the attribute does not exist.
    # @macro exists
    def attribute_value(attribute_name)
      assert_exists
      ole_object.getAttribute(attribute_name)
    end

    # Make it possible to use *_no_wait commands and retrieve element html5 data-attribute
    # values.
    #
    # @example Use click without waiting:
    #   browser.button.click_no_wait
    #
    # @example Retrieve html5 data attribute value:
    #   browser.div.data_model # => value of data-model="foo" html attribute
    def method_missing(method_name, *args, &block)
      meth = method_name.to_s
      if meth =~ /(.*)_no_wait/ && self.respond_to?($1)
        perform_action do
          ruby_code = generate_ruby_code(self, $1, *args)
          system(spawned_no_wait_command(ruby_code))
        end
      elsif meth =~ /^data_(.*)/
        self.send(:attribute_value, meth.gsub("_", "-")) || ''
      else
        super
      end
    end

    # @private
    def locate
      @o = @container.locator_for(TaggedElementLocator, @specifiers, self.class).locate
    end  

    # @private
    def __ole_inner_elements
      assert_exists
      ole_object.all
    end

    # @private
    def document
      assert_exists
      ole_object
    end

    # @private
    def assert_exists
      locate
      unless ole_object
        exception_class = self.is_a?(Frame) ? UnknownFrameException : UnknownObjectException
        raise exception_class.new(Watir::Exception.message_for_unable_to_locate(@specifiers))
      end
    end

    # @private
    def assert_enabled
      raise ObjectDisabledException, "object #{@specifiers.inspect} is disabled" unless enabled?
    end

    # @private
    def typingspeed
      @container.typingspeed
    end

    # @private
    def type_keys
      @type_keys || @container.type_keys
    end

    # @private
    def active_object_highlight_color
      @container.active_object_highlight_color
    end

    # @private
    def click!
      perform_action do
        # Not sure why but in IE9 Document mode, passing a parameter
        # to click seems to work. Firing the onClick event breaks other tests
        # so this seems to be the safest change and also works fine in IE8
        ole_object.click(0)
      end
    end

    # @private
    def dispatch_event(event)
      if IE.version_parts.first.to_i >= 9 && container.page_container.document.documentMode.to_i >= 9
        ole_object.dispatchEvent(create_event(event))
      else
        ole_object.fireEvent(event)
      end
    end

    private

    def create_event(event)
      event =~ /on(.*)/i
      event = $1 if $1
      event.downcase!
      # See http://www.howtocreate.co.uk/tutorials/javascript/domevents
      case event
      when 'abort', 'blur', 'change', 'error', 'focus', 'load',
        'reset', 'resize', 'scroll', 'select', 'submit', 'unload'
        event_name = :initEvent
        event_type = 'HTMLEvents'
        event_args = [event, true, true]
      when 'select'
        event_name = :initUIEvent
        event_type = 'UIEvent'
        event_args = [event, true, true, @container.page_container.document.parentWindow.window,0]
      when 'keydown', 'keypress', 'keyup'
        event_name = :initKeyboardEvent
        event_type = 'KeyboardEvent'
        # 'type', bubbles, cancelable, windowObject, ctrlKey, altKey, shiftKey, metaKey, keyCode, charCode
        event_args = [event, true, true, @container.page_container.document.parentWindow.window, false, false, false, false, 0, 0]
      when 'click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover', 'mouseup',
        'contextmenu', 'drag', 'dragstart', 'dragenter', 'dragover', 'dragleave', 'dragend', 'drop', 'selectstart'
        event_name = :initMouseEvent
        event_type = 'MouseEvents'
        # 'type', bubbles, cancelable, windowObject, detail, screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey, metaKey, button, relatedTarget
        event_args = [event, true, true, @container.page_container.document.parentWindow.window, 1, 0, 0, 0, 0, false, false, false, false, 0, @container.page_container.document]
      else
        raise UnhandledEventException, "Don't know how to trigger event '#{event}'"
      end
      event = @container.page_container.document.createEvent(event_type)
      event.send event_name, *event_args
      event
    end

    # Return an array with many of the properties, in a format to be used by the to_s method
    def string_creator
      n = []
      n <<   "id:".ljust(TO_S_SIZE) +         self.id.to_s
      n
    end

    # This method is responsible for setting and clearing the colored highlighting on the currently active element.
    # use :set   to set the highlight
    #   :clear  to clear the highlight
    # @todo Make this two methods: set_highlight & clear_highlight
    def highlight(set_or_clear)
      if set_or_clear == :set
        @original_color ||= ole_object.style.backgroundColor
        ole_object.style.backgroundColor = @container.active_object_highlight_color
      else
        ole_object.style.backgroundColor = @original_color if @original_color
      end
    rescue
      # we could be here for a number of reasons...
      # e.g. page may have reloaded and the reference is no longer valid
    ensure
      @original_color = nil
    end

    def replace_method(method)
      method == 'click' ? 'click!' : method
    end

    def build_method(method_name, *args)
      arguments = args.map do |argument|
        if argument.is_a?(String)
          argument = "'#{argument}'"  
        else
          argument = argument.inspect
        end
      end
      "#{replace_method(method_name)}(#{arguments.join(',')})"
    end

    def generate_ruby_code(element, method_name, *args)
      # needs to be done like this to avoid segfault on ruby 1.9.3
      tag_name = @specifiers[:tag_name].join("' << '")
      element = "#{self.class}.new(#{@page_container.attach_command}, :tag_name => Array.new << '#{tag_name}', :unique_number => #{unique_number})"
      method = build_method(method_name, *args)
      ruby_code = "$:.unshift(#{$LOAD_PATH.map {|p| "'#{p}'" }.join(").unshift(")});" <<
                    "require '#{File.expand_path(File.dirname(__FILE__))}/core';#{element}.#{method};"
      ruby_code
    end

    def spawned_no_wait_command(command)
      command = "-e #{command.inspect}"
      unless $DEBUG
        "start rubyw #{command}"
      else
        puts "#no_wait command:"
        command = "ruby #{command}"
        puts command
        command
      end
    end

    def perform_action
      assert_exists
      assert_enabled
      highlight(:set)
      yield
    ensure
      highlight(:clear)
    end

  end
end  

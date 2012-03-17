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

    # number of spaces that separate the property from the value in the to_s method
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

    def locate
      @o = @container.locator_for(TaggedElementLocator, @specifiers, self.class).locate
    end  

    # Return the ole object, allowing any methods of the DOM that Watir doesn't support to be used.
    def ole_object
      @o
    end

    def ole_object=(o)
      @o = o
    end

    def inspect
      '#<%s:0x%x located=%s specifiers=%s>' % [self.class, hash*2, !!ole_object, @specifiers.inspect]
    end

    private

    def self.attr_ole(method_name, ole_method_name=nil)
      class_eval %Q[
        def #{method_name}
          assert_exists
          ole_method_name = '#{ole_method_name || method_name.to_s.gsub(/\?$/, '')}'
          ole_object.invoke(ole_method_name) rescue attribute_value(ole_method_name) || '' rescue ''
        end]
    end

    public

    def assert_exists
      locate
      unless ole_object
        exception_class = self.is_a?(Frame) ? UnknownFrameException : UnknownObjectException
        raise exception_class.new(Watir::Exception.message_for_unable_to_locate(@specifiers))
      end
    end

    def assert_enabled
      raise ObjectDisabledException, "object #{@specifiers.inspect} is disabled" unless enabled?
    end

    # return the id of the element
    attr_ole :id
    # return the title of the element
    attr_ole :title
    # return the class name of the element
    # raise an ObjectNotFound exception if the object cannot be found
    attr_ole :class_name, :className
    # return the unique COM number for the element
    attr_ole :unique_number, :uniqueNumber
    # Return the outer html of the object - see http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/outerhtml.asp?frame=true
    attr_ole :html, :outerHTML

    def tag_name
      assert_exists
      @o.tagName.downcase
    end

    # returns specific Element subclass for current Element
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

    # send keys to element
    def send_keys(*keys)
      focus
      page_container.send_keys *keys
    end

    # return the css style as a string
    def style
      assert_exists
      # this works for IE9
      ole_object.currentStyle.cssText
    rescue WIN32OLERuntimeError
      ole_object.style.cssText
    end

    # Return the innerText of the object or an empty string if the object is
    # not visible
    # Raise an ObjectNotFound exception if the object cannot be found
    def text
      assert_exists
      visible? ? ole_object.innerText.strip : ""
    end

    def __ole_inner_elements
      assert_exists
      ole_object.all
    end

    def document
      assert_exists
      ole_object
    end

    # Return the element immediately containing self. 
    def parent
      assert_exists
      parent_element = ole_object.parentelement
      return unless parent_element
      Element.new(self, :ole_object => parent_element).to_subtype
    end

    def typingspeed
      @container.typingspeed
    end

    def type_keys
      @type_keys || @container.type_keys
    end

    def activeObjectHighLightColor
      @container.activeObjectHighLightColor
    end

    # Return an array with many of the properties, in a format to be used by the to_s method
    def string_creator
      n = []
      n <<   "id:".ljust(TO_S_SIZE) +         self.id.to_s
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
          @original_color ||= ole_object.style.backgroundColor
          ole_object.style.backgroundColor = @container.activeObjectHighLightColor
        rescue
          @original_color = nil
        end
      else
        begin
          ole_object.style.backgroundColor = @original_color if @original_color
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

    def right_click
      perform_action {fire_event("oncontextmenu"); @container.wait}
    end

    def double_click
      perform_action {fire_event("ondblclick"); @container.wait}
    end

    def replace_method(method)
      method == 'click' ? 'click!' : method
    end

    private :replace_method

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

    private :build_method

    def generate_ruby_code(element, method_name, *args)
      # needs to be done like this to avoid segfault on ruby 1.9.3
      tag_name = @specifiers[:tag_name].join("' << '")
      element = "#{self.class}.new(#{@page_container.attach_command}, :tag_name => Array.new << '#{tag_name}', :unique_number => #{unique_number})"
      method = build_method(method_name, *args)
      ruby_code = "$:.unshift(#{$LOAD_PATH.map {|p| "'#{p}'" }.join(").unshift(")});" <<
                    "require '#{File.expand_path(File.dirname(__FILE__))}/core';#{element}.#{method};"
      ruby_code
    end

    private :generate_ruby_code

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

    private :spawned_no_wait_command

    def click!
      perform_action do
        # Not sure why but in IE9 Document mode, passing a parameter
        # to click seems to work. Firing the onClick event breaks other tests
        # so this seems to be the safest change and also works fine in IE8
        ole_object.click(0)
      end
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
      perform_action {dispatch_event(event); @container.wait}
    end

    def dispatch_event(event)
      assert_exists

      if IE.version_parts.first.to_i >= 9 && container.page_container.document.documentMode.to_i >= 9
        ole_object.dispatchEvent(create_event(event))
      else
        ole_object.fireEvent(event)
      end
    end

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

    # This method sets focus on the active element.
    #   raises: UnknownObjectException  if the object is not found
    #           ObjectDisabledException if the object is currently disabled
    def focus
      assert_exists
      assert_enabled
      @page_container.focus
      ole_object.focus(0)
    end

    def focused?
      assert_exists
      assert_enabled
      @page_container.document.activeElement.uniqueNumber == unique_number
    end

    # Returns whether this element actually exists.
    def exists?
      begin
        locate
      rescue WIN32OLERuntimeError, UnknownObjectException
        @o = nil
      end
      !!@o
    end

    alias :exist? :exists?

    # Returns true if the element is enabled, false if it isn't.
    #   raises: UnknownObjectException  if the object is not found
    def enabled?
      assert_exists
      !disabled?
    end

    def disabled?
      assert_exists
      false
    end

    # If any parent element isn't visible then we cannot write to the
    # element. The only realiable way to determine this is to iterate
    # up the DOM element tree checking every element to make sure it's
    # visible.
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
    # Returns null if attribute doesn't exist.
    def attribute_value(attribute_name)
      assert_exists
      ole_object.getAttribute(attribute_name)
    end

    def perform_action
      assert_exists
      assert_enabled
      highlight(:set)
      yield
      highlight(:clear)
    end

    private :perform_action

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
      
  end
end  

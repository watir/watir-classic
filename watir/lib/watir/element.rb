module Watir
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
        raise UnknownObjectException.new(
          Watir::Exception.message_for_unable_to_locate(@how, @what))
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
		def type_keys
			return @container.type_keys if @type_keys.nil? 
			@type_keys
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
end  

module Watir
  
  class InputElement < Element #:nodoc:all
    def locate
      @o = @container.locator_for(InputElementLocator, @how, self.class).locate
    end

    def initialize(container, how)
      set_container container
      @how = how
      super nil
    end
  end

  #
  # Input: Select
  #
  
  # This class is the way in which select boxes are manipulated.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_list method
  class SelectList < InputElement
    #:stopdoc:
    INPUT_TYPES = ["select-one", "select-multiple"]
    #:startdoc:

    def_wrap :multiple?, :multiple

    # This method clears the selected items in the select box
    def clear
      perform_action do
        options.each {|option| option.clear}
      end
    end

    # This method selects an item, or items in a select box, by text.
    # Raises NoValueFoundException   if the specified value is not found.
    #  * item   - the thing to select, string or reg exp
    def select(item)
      matching_options = []
      perform_action do
        matching_options = matching_items_in_select_list(:text, item) + 
          matching_items_in_select_list(:label, item) + 
          matching_items_in_select_list(:value, item)
        raise NoValueFoundException, "No option with :text, :label or :value of #{item.inspect} in this select element" if matching_options.empty?
        matching_options.each(&:select)
      end
      matching_options.first.text
    end
       
    # Selects an item, or items in a select box, by value.
    # Raises NoValueFoundException if the specified value is not found.
    #  * item   - the value of the thing to select, string or reg exp
    def select_value(item)
      matching_options = matching_items_in_select_list(:value, item)
      raise NoValueFoundException, "No option with :value of #{item.inspect} in this select element" if matching_options.empty?
      matching_options.each(&:select)
      matching_options.first.value
    end
    
    # Returns array of the selected text items in a select box
    # Raises UnknownObjectException if the select box is not found.
    def selected_options
      options.select(&:selected?)
    end

    # Does the SelectList include the specified option (text)?
    def include? text_or_regexp
      !options.map(&:text).grep(text_or_regexp).empty?
    end

    # Is the specified option (text) selected? Raises exception of option does not exist.
    def selected? text_or_regexp
      raise UnknownObjectException, "Option #{text_or_regexp.inspect} not found." unless include? text_or_regexp
      !selected_options.map(&:text).grep(text_or_regexp).empty?
    end

    private

    def matching_items_in_select_list(attribute, value)
      options.select do |opt|
        if value.is_a?(Regexp)
          opt.send(attribute) =~ value
        elsif value.is_a?(String) || value.is_a?(Numeric)
          opt.send(attribute) == value
        else
          raise TypeError, "#{value.inspect} can be only String, Regexp or Numeric!"
        end
      end
    end
  end
  
  class Option < NonControlElement

    def select
      perform_action do
        unless selected?
          ole_object.selected = true
          select_list.dispatch_event("onChange")
          @container.wait
        end
      end
    end

    def clear
      raise TypeError, "you can only clear multi-selects" unless select_list.multiple?

      perform_action do
        if selected?
          ole_object.selected = false
          select_list.dispatch_event("onChange")
          @container.wait
        end
      end
    end

    def selected?
      assert_exists
      ole_object.selected
    end

    def text
      l = label
      l.empty? ? super : l rescue ''
    end

    private

    def select_list
      return @select_list if @select_list
      el = parent
      el = el.parent until el.is_a?(SelectList)

      raise "SELECT element was not found for #{self}!" unless el
      @select_list = el
    end
  end

  # 
  # Input: Button
  #
  
  # Returned by the Watir::Container#button method
  class Button < InputElement
    #:stopdoc:
    INPUT_TYPES = ["button", "submit", "image", "reset"]
    #:startdoc:
    
    alias_method :__value, :value

    def text
      val = __value
      val.empty? ? super : val
    end

    alias_method :value, :text

  end

  #
  # Input: Text
  #
  
  # This class is the main class for Text Fields
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_field method
  class TextField < InputElement
    #:stopdoc:
    INPUT_TYPES = ["text", "password", "textarea"]
    
    def_wrap_guard :size

    # Returns true or false if the text field is read only.
    #   Raises UnknownObjectException if the object can't be found.
    def_wrap :readonly?, :readOnly

    alias_method :text, :value

    #:startdoc:
    
    # return number of maxlength attribute
    def maxlength
      assert_exists unless @o
      begin
        ole_object.invoke('maxlength').to_i
      rescue WIN32OLERuntimeError
        0
      end
    end
        
    def text_string_creator
      n = []
      n << "length:".ljust(TO_S_SIZE) + self.size.to_s
      n << "max length:".ljust(TO_S_SIZE) + self.maxlength.to_s
      n << "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s
      n
    end
    private :text_string_creator
    
    def to_s
      assert_exists
      r = string_creator
      r += text_string_creator
      r.join("\n")
    end
    
    def assert_not_readonly #:nodoc:
      if self.readonly?
        raise ObjectReadOnlyException, 
          "Textfield #{@how} and #{@what} is read only."
      end
    end
    
    # Returns true if the text field contents is matches the specified target,
    # which can be either a string or a regular expression.
    #   Raises UnknownObjectException if the object can't be found
    #--
    # I vote for deprecating this
    # we should use text_field().text.include?(some) or text.match(/some/) instead of this method
    def verify_contains(target) #:nodoc:
      assert_exists
      if target.kind_of? String
        return true if self.value == target
      elsif target.kind_of? Regexp
        return true if self.value.match(target) != nil
      end
      return false
    end
    
    # Drag the entire contents of the text field to another text field
    #  19 Jan 2005 - It is added as prototype functionality, and may change
    #   * destination_how   - symbol, :id, :name how we identify the drop target
    #   * destination_what  - string or regular expression, the name, id, etc of the text field that will be the drop target
    def drag_contents_to(destination_how, destination_what)
      assert_exists
      destination = @container.text_field(destination_how, destination_what)
      unless destination.exists?
        raise UnknownObjectException, "Unable to locate destination using #{destination_how } and #{destination_what } "
      end
      
      @o.focus(0)
      @o.select(0)
      value = self.value
      
      dispatch_event("onSelect")
      dispatch_event("ondragstart")
      dispatch_event("ondrag")
      destination.dispatch_event("onDragEnter")
      destination.dispatch_event("onDragOver")
      destination.dispatch_event("ondrop")
      
      dispatch_event("ondragend")
      destination.value = destination.value + value.to_s
      self.value = ""
    end
    
    # Clears the contents of the text box.
    #   Raises UnknownObjectException if the object can't be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def clear
      assert_exists
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      
      @o.scrollIntoView
      @o.focus(0)
      @o.select(0)
      dispatch_event("onSelect")
      @o.value = ""
      dispatch_event("onKeyPress")
      dispatch_event("onChange")
      @container.wait
      highlight(:clear)
    end
    
    # Appends the specified string value to the contents of the text box.
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def append(value)
      assert_exists
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus(0)
      type_by_character(value)
      highlight(:clear)
    end
    
    # Sets the contents of the text box to the specified text value
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def set(value)
      assert_exists
      assert_enabled
      assert_not_readonly

      highlight(:set)
      @o.scrollIntoView
      if type_keys
	      @o.focus(0)
	      @o.select(0)
	      dispatch_event("onSelect")
	      dispatch_event("onKeyPress")
	      @o.value = ""
	      type_by_character(value)
	      dispatch_event("onChange")
	      dispatch_event("onBlur")
	    else
				@o.value = limit_to_maxlength(value)
	    end
      highlight(:clear)
    end

    # Sets the value of the text field directly.
    # It causes no events to be fired or exceptions to be raised,
    # so generally shouldn't be used.
    # It is preffered to use the set method.
    def value=(v)
      assert_exists
      @o.value = v.to_s
    end

    def requires_typing #:nodoc:
    	@type_keys = true
    	self
    end
    def abhors_typing #:nodoc:
    	@type_keys = false
    	self
    end

    def label
      @container.label(:for => name).text
    end

    private

    # Type the characters in the specified string (value) one by one.
    # It should not be used externally.
    #   * value - string - The string to enter into the text field
    def type_by_character(value)
      value = limit_to_maxlength(value)
      characters_in(value) do |c|
        sleep @container.typingspeed
        @o.value = @o.value.to_s + c
        dispatch_event("onKeyDown")
        dispatch_event("onKeyPress")
        dispatch_event("onKeyUp")
      end
    end
    
    # Supports double-byte characters
    def characters_in(value, &blk) 
      if RUBY_VERSION =~ /^1\.8/
        index = 0
        while index < value.length 
          len = value[index] > 128 ? 2 : 1
          yield value[index, len]
          index += len
        end 
      else
        value.each_char(&blk)
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

  class TextArea < TextField
    INPUT_TYPES = ["textarea"]

    Watir::Container.module_eval do
      def textareas(how={}, what=nil)
        TextAreas.new(self, how, what)
      end

      def textarea(how={}, what=nil)
        TextArea.new(self, how, what)
      end
    end
  end
  
  # this class can be used to access hidden field objects
  # Normally a user would not need to create this object as it is returned by the Watir::Container#hidden method
  class Hidden < TextField
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
    
    # Hidden element is never visible - returns false.
    def visible?
      assert_exists
      false
    end
  end

  # This class contains common methods to both radio buttons and check boxes.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkbox or by Watir::Container#radio methods
  #--
  # most of the methods available to this element are inherited from the Element class
  class RadioCheckCommon < InputElement
    def inspect
      '#<%s:0x%x located=%s how=%s what=%s value=%s>' % [self.class, hash*2, !!ole_object, @how.inspect, @what.inspect, @value.inspect]
    end
    
    # This method determines if a radio button or check box is set.
    # Returns true if set/checked; false if not set/checked.
    # Raises UnknownObjectException if its unable to locate an object.
    def set? 
      assert_exists
      return @o.checked
    end
    alias checked? set?
    
   end
  
  #--
  #  this class makes the docs better
  #++
  # This class is the watir representation of a radio button.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#radio method
  class Radio < RadioCheckCommon
    INPUT_TYPES = ["radio"]
    # This method clears a radio button. One of them will almost always be set.
    # Returns true if set or false if not set.
    #   Raises UnknownObjectException if its unable to locate an object
    #         ObjectDisabledException IF THE OBJECT IS DISABLED
    def clear
      assert_exists
      assert_enabled
      highlight(:set)
      @o.checked = false
      highlight(:clear)
      highlight(:clear)
    end
    
    # This method sets the radio list item.
    #   Raises UnknownObjectException  if it's unable to locate an object
    #         ObjectDisabledException  if the object is disabled
    def set
      assert_exists
      assert_enabled
      highlight(:set)
      @o.scrollIntoView
      @o.checked = true
      click
      highlight(:clear)
    end

  end

  # This class is the watir representation of a check box.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#checkbox method
  class CheckBox < RadioCheckCommon
    INPUT_TYPES = ["checkbox"]
    # This method checks or unchecks the checkbox.
    # With no arguments supplied it sets the checkbox.
    # Setting false argument unchecks/clears the checkbox.
    #   Raises UnknownObjectException if it's unable to locate an object
    #         ObjectDisabledException if the object is disabled
    def set(value=true)
      assert_exists
      assert_enabled
      highlight :set
      current_value = @o.checked
      unless value == current_value
        click
      end
      highlight :clear
    end
    
    # Clears a check box.
    #   Raises UnknownObjectException if its unable to locate an object
    #         ObjectDisabledException if the object is disabled
    def clear
      set false
    end

    Watir::Container.module_eval do
      remove_method :check_boxs

      def checkboxes(how={}, what=nil)
        CheckBoxes.new(self, how, what)
      end

      remove_method :check_box

      def checkbox(how={}, what=nil)
        CheckBox.new(self, how, what)
      end
    end
  end

end

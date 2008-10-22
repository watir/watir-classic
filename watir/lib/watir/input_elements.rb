module Watir
  
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

  #
  # Input: Select
  #
  
  # This class is the way in which select boxes are manipulated.
  # Normally a user would not need to create this object as it is returned by the Watir::Container#select_list method
  class SelectList < InputElement
    INPUT_TYPES = ["select-one", "select-multiple"]
    
    attr_accessor :o
    
    # This method clears the selected items in the select box
    # TODO: fix Camel case
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
    def getSelectedItems     # TODO: fix camel case
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
    def includes? text_or_regexp
      getAllContents.grep(text_or_regexp).size > 0
    end

    # Is the specified option (text) selected? Raises exception of option does not exist.
    def selected? text_or_regexp
      unless includes? text_or_regexp
        raise UnknownObjectException, "Option #{text_or_regexp.inspect} not found."
      end

      getSelectedItems.grep(text_or_regexp).size > 0
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
  
  # 
  # Input: Button
  #
  
  # Returned by the Watir::Container#button method
  class Button < InputElement
    INPUT_TYPES = ["button", "submit", "image", "reset"]
  end

  #
  # Input: Text
  #
  
  # This class is the main class for Text Fields
  # Normally a user would not need to create this object as it is returned by the Watir::Container#text_field method
  class TextField < InputElement
    INPUT_TYPES = ["text", "password", "textarea"]
    
    def_wrap_guard :size
    
    def maxlength
      assert_exists
      begin
        ole_object.invoke('maxlength').to_i
      rescue WIN32OLERuntimeError
        0
      end
    end
        
    # Returns true or false if the text field is read only.
    #   Raises UnknownObjectException if the object can't be found.
    def_wrap :readonly?, :readOnly
    
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
    
    def assert_not_readonly
      if self.readonly?
        raise ObjectReadOnlyException, 
          "Textfield #{@how} and #{@what} is read only."
      end
    end
    
    # Returns true if the text field contents is matches the specified target,
    # which can be either a string or a regular expression.
    #   Raises UnknownObjectException if the object can't be found
    def verify_contains(target) # FIXME: verify_contains should have same name and semantics as IE#contains_text (prolly make this work for all elements)
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
    
    # Clears the contents of the text box.
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
    
    # Appends the specified string value to the contents of the text box.
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def append(value)
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus
      type_by_character(value)
      highlight(:clear)
    end
    
    # Sets the contents of the text box to the specified text value
    #   Raises UnknownObjectException if the object cant be found
    #   Raises ObjectDisabledException if the object is disabled
    #   Raises ObjectReadOnlyException if the object is read only
    def set(value)
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      if type_keys
	      @o.focus
	      @o.select
	      @o.fireEvent("onSelect")
	      @o.fireEvent("onKeyPress")
	      @o.value = ""
	      type_by_character(value)
	      @o.fireEvent("onChange")
	      @o.fireEvent("onBlur")
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
    
    def requires_typing
    	@type_keys = true
    	self
    end
    def abhors_typing
    	@type_keys = false
    	self
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
        @o.fireEvent("onKeyDown")
        @o.fireEvent("onKeyPress")
        @o.fireEvent("onKeyUp")
      end
    end
    
    # Supports double-byte characters
    def characters_in(value) 
      index = 0
      while index < value.length 
        len = value[index] > 128 ? 2 : 1
        yield value[index, len]
        index += len
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
  
  # For fields that accept file uploads
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
          system("rubyw -e \"require 'win32ole'; @autoit=WIN32OLE.new('AutoItX3.Control'); waitresult=@autoit.WinWait 'Choose file', '', 15; sleep 1; if waitresult == 1\" -e \"@autoit.ControlSetText 'Choose file', '', 'Edit1', '#{setPath}'; @autoit.ControlSend 'Choose file', '', 'Button2', '{ENTER}';\" -e \"end\"")
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
    # This method clears a radio button. One of them will almost always be set.
    # Returns true if set or false if not set.
    #   Raises UnknownObjectException if its unable to locate an object
    #         ObjectDisabledException IF THE OBJECT IS DISABLED
    def clear
      assert_enabled
      highlight(:set)
      set_clear_item(false)
      highlight(:clear)
    end
    
    # This method sets the radio list item.
    #   Raises UnknownObjectException  if it's unable to locate an object
    #         ObjectDisabledException  if the object is disabled
    def set
      assert_enabled
      highlight(:set)
      @o.scrollIntoView
      set_clear_item(true)
      highlight(:clear)
    end
    
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
  
end
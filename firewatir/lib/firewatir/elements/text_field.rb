module FireWatir
  #
  # Description:
  # Class for Text Field element.
  #
  class TextField < InputElement
    INPUT_TYPES = ["text", "password", "textarea"]

    # Gets the size of the text field element.
    def_wrap :size
    # Gets max length of the text field element.
    def_wrap :maxlength_string, :maxlength
    def maxlength
      maxlength_string.to_i
    end
    # Returns true if the text field is read only, false otherwise.
    def_wrap :readonly?, :readOnly

    #
    # Description:
    #   Used to populate the properties in to_s method
    #
    #def text_string_creator
    #    n = []
    #    n <<   "length:".ljust(TO_S_SIZE) + self.size.to_s
    #    n <<   "max length:".ljust(TO_S_SIZE) + self.maxlength.to_s
    #    n <<   "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s
    #
    #    return n
    #end
    #private :text_string_creator

    # TODO: Impelement the to_s method.
    def to_s
      assert_exists
      super({"length" => "size","max length" => "maxlength","read only" => "readOnly" })
    end

    #
    # Description:
    #   Checks if object is read-only or not.
    #
    def assert_not_readonly
      raise ObjectReadOnlyException, "Textfield #{@how} and #{@what} is read only." if self.readonly?
    end

    #
    # Description:
    #   Checks if the provided text matches with the contents of text field. Text can be a string or regular expression.
    #
    # Input:
    #   - containsThis - Text to verify.
    #
    # Output:
    #   True if provided text matches with the contents of text field, false otherwise.
    #
    def verify_contains( containsThis )
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
    # TODO: Can we have support for this in Firefox.
    #def drag_contents_to( destination_how , destination_what)
    #    assert_exists
    #    destination = element.text_field(destination_how, destination_what)
    #    raise UnknownObjectException ,  "Unable to locate destination using #{destination_how } and #{destination_what } "   if destination.exists? == false

    #    @o.focus
    #    @o.select()
    #    value = self.value

    #   @o.fireEvent("onSelect")
    #    @o.fireEvent("ondragstart")
    #    @o.fireEvent("ondrag")
    #    destination.fireEvent("onDragEnter")
    #    destination.fireEvent("onDragOver")
    #    destination.fireEvent("ondrop")

    #    @o.fireEvent("ondragend")
    #    destination.value= ( destination.value + value.to_s  )
    #    self.value = ""
    #end
    # alias dragContentsTo drag_contents_to

    #
    # Description:
    #   Clears the contents of the text field.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    def clear
      assert_exists
      assert_enabled
      assert_not_readonly

      highlight(:set)

      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      @o.fireEvent("onChange")
      @container.wait()
      highlight(:clear)
    end

    #
    # Description:
    #   Append the provided text to the contents of the text field.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    # Input:
    #   - setThis - Text to be appended.
    #
    def append( setThis)
      assert_exists
      assert_enabled
      assert_not_readonly

      highlight(:set)
      @o.scrollIntoView
      @o.focus
      doKeyPress( setThis )
      highlight(:clear)
    end

    #
    # Description:
    #   Sets the contents of the text field to the provided text. Overwrite the existing contents.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    # Input:
    #   - setThis - Text to be set.
    #
    def set( setThis )
      assert_exists
      assert_enabled
      assert_not_readonly

      highlight(:set)
      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      doKeyPress( setThis )
      highlight(:clear)
      @o.fireEvent("onChange")
      @o.fireEvent("onBlur")
    end

    #
    # Description:
    #   Sets the text of the text field withoud firing the events like onKeyPress, onKeyDown etc. This should not be used generally, but it
    #   is useful in situations where you need to set large text to the text field and you know that you don't have any event to be
    #   fired.
    #
    # Input:
    #   - v - Text to be set.
    #
    #def value=(v)
    #    assert_exists
    #    @o.value = v.to_s
    #end

    #
    # Description:
    #   Used to set the value of text box and fires the event onKeyPress, onKeyDown, onKeyUp after each character.
    #   Shouldnot be used externally. Used internally by set and append methods.
    #
    # Input:
    #   - value - The string to enter into the text field
    #
    def doKeyPress( value )
      if RUBY_VERSION =~ /^1\.8/
        # before iterating over each character, we'll convert value to utf-8
        require "encoding/character/utf-8"
        value = u"" + value
      end

      begin
        max = maxlength
        if (max > 0 && value.length > max)
          original_value = value
          value = original_value[0...max]
          element.log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{max}) of the field. Using value: #{value}"
        end
      rescue
        # probably a text area - so it doesnt have a max Length
      end
      for i in 0..value.length-1
        #sleep element.typingspeed   # typing speed
        c = value[i,1]
        #element.log  " adding c.chr " + c  #.chr.to_s
        @o.value = "#{(@o.value.to_s + c)}"   #c.chr
        @o.fireEvent("onKeyDown")
        @o.fireEvent("onKeyPress")
        @o.fireEvent("onKeyUp")
      end

    end
    private :doKeyPress

    alias readOnly? :readonly?
    alias getContents value
    alias maxLength maxlength

  end # TextField
end # FireWatir


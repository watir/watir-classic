module FireWatir
  #
  # Description:
  #   Base class for checkbox and radio button elements.
  #
  class RadioCheckCommon < Element
    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of element object. Element can be checkbox or radio button.
    #
    # Input:
    #   - how - Attribute to identify the element.
    #   - what - Value of that attribute.
    #   - value - value of the element.
    #
    def initialize(container, how, what, value = nil)
      @how = how
      @what = what
      @value = value
      @container = container
    end

    #
    # Description:
    #   Locate the element on the page. Element can be a checkbox or radio button.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("input", @how, @what, @type, @value)
      end
      @o = self
    end

    #
    # Description:
    #   Checks if element i.e. radio button or check box is checked or not.
    #
    # Output:
    #   True if element is checked, false otherwise.
    #
    def set?
      assert_exists
      return @o.checked
    end
    alias getState set?
    alias checked? set?
    alias isSet?   set?

    #
    # Description:
    #   Unchecks the radio button or check box element.
    #   Raises ObjectDisabledException exception if element is disabled.
    #
    def clear
      assert_exists
      assert_enabled
      #highlight(:set)
      set_clear_item(false)
      #highlight(:clear)
    end

    #
    # Description:
    #   Checks the radio button or check box element.
    #   Raises ObjectDisabledException exception if element is disabled.
    #
    def set
      assert_exists
      assert_enabled
      #highlight(:set)
      set_clear_item(true)
      #highlight(:clear)
    end

    #
    # Description:
    #   Used by clear and set method to uncheck and check radio button and checkbox element respectively.
    #
    def set_clear_item(set)
      @o.fire_event("onclick")
      @container.wait
    end
    private :set_clear_item

  end # RadioCheckCommon

  #
  # Description:
  #   Class for RadioButton element.
  #
  class Radio < RadioCheckCommon
    def initialize *args
      super
      @type = ["radio"]
    end

    def clear
      assert_exists
      assert_enabled
      #higlight(:set)
      @o.checked = false
      #highlight(:clear)
    end

  end # Radio

  #
  # Description:
  # Class for Checkbox element.
  #
  class CheckBox < RadioCheckCommon
    def initialize *args
      super
      @type = ["checkbox"]
    end

    #
    # Description:
    #   Checks or unchecks the checkbox. If no value is supplied it will check the checkbox.
    #   Raises ObjectDisabledException exception if the object is disabled
    #
    # Input:
    #   - set_or_clear - Parameter indicated whether to check or uncheck the checkbox.
    #                    True to check the check box, false for unchecking the checkbox.
    #
    def set( set_or_clear=true )
      assert_exists
      assert_enabled
      highlight(:set)

      if set_or_clear == true
        if @o.checked == false
          set_clear_item( true )
        end
      else
        self.clear
      end
      highlight(:clear )
    end

    #
    # Description:
    #   Unchecks the checkbox.
    #   Raises ObjectDisabledException exception if the object is disabled
    #
    def clear
      assert_exists
      assert_enabled
      highlight( :set)
      if @o.checked == true
        set_clear_item( false )
      end
      highlight( :clear)
    end

  end # CheckBox
end # FireWatir

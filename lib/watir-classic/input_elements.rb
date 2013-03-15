module Watir

  # Super-class for input elements like {SelectList}, {Button} etc.
  class InputElement < Element
    attr_ole :disabled?
    attr_ole :name
    attr_ole :value
    attr_ole :alt
    attr_ole :src
    attr_ole :type

    # @private
    def locate
      @o = @container.locator_for(InputElementLocator, @specifiers, self.class).locate
    end

  end

  # Returned by {Container#select_list}.
  class SelectList < InputElement
    attr_ole :multiple?

    # Clear the selected options in the select list.
    #
    # @macro exists
    # @macro enabled
    def clear
      perform_action do
        options.each(&:clear)
      end
    end

    # Select an item or items in a select box.
    #
    # @param [String,Regexp] item option to select by text, label or value.
    # @raise [NoValueFoundException] when no options found.
    # @macro exists
    # @macro enabled
    def select(item)
      matching_options = []
      perform_action do
        matching_options = matching_items_in_select_list(:text, item) + 
          matching_items_in_select_list(:label, item) + 
          matching_items_in_select_list(:value, item)
        raise NoValueFoundException, "No option with :text, :label or :value of #{item.inspect} in this select element" if matching_options.empty?
        matching_options.each(&:select)
      end
      first_present_option_value matching_options, :text
    end

    # Select an item or items in a select box by option's value.
    #
    # @param [String,Regexp] item option to select by value.
    # @raise [NoValueFoundException] when no options found.
    # @macro exists
    # @macro enabled
    def select_value(item)
      matching_options = matching_items_in_select_list(:value, item)
      raise NoValueFoundException, "No option with :value of #{item.inspect} in this select element" if matching_options.empty?
      matching_options.each(&:select)
      first_present_option_value matching_options, :value
    end

    # @example Retrieve selected options as a text:
    #   browser.select_list.selected_options.map(&:text)
    #
    # @return [Array<OptionCollection>] array of selected options.
    # @macro exists
    def selected_options
      options.select(&:selected?)
    end

    # @param [String,Regexp] text_or_regexp option with text to search for.
    # @return [Boolean] true when option with text includes in select list,
    #   false otherwise.
    # @macro exists
    def include?(text_or_regexp)
      !options.map(&:text).grep(text_or_regexp).empty?
    end

    # @param [String,Regexp] text_or_regexp option with text to search for.
    # @return [Boolean] true when option with text is selected in select list,
    #   false otherwise.
    # @macro exists
    def selected?(text_or_regexp)
      raise UnknownObjectException, "Option #{text_or_regexp.inspect} not found." unless include? text_or_regexp
      !selected_options.map(&:text).grep(text_or_regexp).empty?
    end

    private

    def matching_items_in_select_list(attribute, value)
      options.select do |opt|
        if value.is_a?(Regexp)
          opt.send(attribute) =~ value
        elsif value.is_a?(String) || value.is_a?(Numeric)
          opt.send(attribute) == value.to_s
        else
          raise TypeError, "#{value.inspect} can be only String, Regexp or Numeric!"
        end
      end
    end

    def first_present_option_value(matching_options, field_to_return)
      first_matching_option = matching_options.first
      first_matching_option.present? ? first_matching_option.send(field_to_return) : ""
    end
  end

  # Returned by {Container#option}.
  class Option < Element
    attr_ole :disabled?
    attr_ole :name
    attr_ole :value
    attr_ole :label

    # Select the option in its select list.
    #
    # @macro exists
    # @macro enabled
    def select
      perform_action do
        change_selected true unless selected?
      end
    end

    # Clear option in multi-select list.
    #
    # @raise [TypeError] when select list is not multi-select.
    # @macro exists
    # @macro enabled
    def clear
      raise TypeError, "you can only clear multi-selects" unless select_list.multiple?

      perform_action do
        change_selected false if selected?
      end
    end

    # @return [Boolean] true when option is selected, false otherwise.
    # @macro exists
    def selected?
      assert_exists
      ole_object.selected
    end

    # Text of the option.
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

    def change_selected(value)
      select_list.focus
      ole_object.selected = value
      select_list.dispatch_event("onChange")
      @container.wait
    end
  end

  # Returned by the {Container#button} method.
  class Button < InputElement
    alias_method :__value, :value

    # @return [String] button contents of value attribute or inner text if there's no value.
    # @see Element#text
    def text
      val = __value
      val.empty? ? super : val
    end

    alias_method :value, :text
  end

  # Returned be {Container#text_field}.
  class TextField < InputElement
    attr_ole :size
    attr_ole :readonly?
    alias_method :text, :value

    # @return [Fixnum] value of maxlength attribute.
    # @macro exists
    def maxlength
      assert_exists
      begin
        ole_object.invoke('maxlength').to_i
      rescue WIN32OLERuntimeError
        0
      end
    end

    # @return [String] text field label's text.
    def label
      @container.label(:for => name).text
    end

    # Clear the contents of the text field.
    #
    # @macro exists
    # @macro enabled
    # @raise [ObjectReadOnlyException] if the text field is read only.
    def clear
      perform_action do
        assert_not_readonly
        @o.scrollIntoView
        @o.focus(0)
        @o.select(0)
        dispatch_event("onSelect")
        @o.value = ""
        dispatch_event("onKeyPress")
        dispatch_event("onChange")
        @container.wait
      end
    end

    # Append the specified text value to the contents of the text field.
    #
    # @param [String] value text to append to current text field's value.
    # @macro exists
    # @macro enabled
    # @raise [ObjectReadOnlyException] if the text field is read only.
    def append(value)
      perform_action do
        assert_not_readonly
        @o.scrollIntoView
        @o.focus(0)
        type_by_character(value)
      end
    end

    # Sets the contents of the text field to the specified value.
    #
    # @param [String] value text to set as value.
    # @macro exists
    # @macro enabled
    # @raise [ObjectReadOnlyException] if the text field is read only.
    def set(value)
      perform_action do
        assert_not_readonly
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
      end
    end

    # Sets the value of the text field directly.
    #
    # @note it does not cause any JavaScript events to be fired or exceptions
    #   to be raised. Using {#set} is recommended.
    #
    # @param [String] value value to be set.
    # @macro exists
    def value=(value)
      assert_exists
      @o.value = value.to_s
    end

    # @deprecated Use "browser.text_field.value.include?(target)" or
    #   "browser.text_field.value.match(target) instead."
    def verify_contains(target)
      Kernel.warn "Deprecated(TextField#verify_contains) - use \"browser.text_field.value.include?(target)\" or \"browser.text_field.value.match(target)\" instead."
      assert_exists
      if target.kind_of? String
        return true if self.value == target
      elsif target.kind_of? Regexp
        return true if self.value.match(target) != nil
      end
      return false
    end

    # @deprecated Not part of the WatirSpec API.
    def drag_contents_to(destination_how, destination_what)
      Kernel.warn "Deprecated(TextField#drag_contents_to) - is not parf ot the WatirSpec API and might be deleted in the future."
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
      destination.assert_exists
      destination.dispatch_event("onDragEnter")
      destination.dispatch_event("onDragOver")
      destination.dispatch_event("ondrop")

      dispatch_event("ondragend")
      destination.value = destination.value + value.to_s
      self.value = ""
    end

    def to_s
      assert_exists
      r = string_creator
      r += text_string_creator
      r.join("\n")
    end

    # @private
    def requires_typing
      @type_keys = true
      self
    end

    # @private
    def abhors_typing
      @type_keys = false
      self
    end

    # @private
    def assert_not_readonly
      if self.readonly?
        raise ObjectReadOnlyException, 
          "Textfield #{@specifiers.inspect} is read only."
      end
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
      end
      value
    end

    def text_string_creator
      n = []
      n << "length:".ljust(TO_S_SIZE) + self.size.to_s
      n << "max length:".ljust(TO_S_SIZE) + self.maxlength.to_s
      n << "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s
      n
    end

  end

  # Returned by the {Container#hidden}.
  class Hidden < TextField
    # @see TextField#set
    def set(value)
      self.value = value
    end

    # @see TextField#append
    def append(value)
      self.value = self.value.to_s + value.to_s
    end

    # @see TextField#clear
    def clear
      self.value = ""
    end

    # This method will do nothing since it is impossible to set focus to
    # a hidden field.
    def focus
    end

    # @return [Boolean] always false, since hidden element is never visible.
    # @macro exists
    def visible?
      assert_exists
      false
    end
  end

  # This module contains common methods to both radio buttons and check boxes.
  # Normally a user would not need to create this object as it is returned by the {Container#checkbox} or by {Container#radio} methods.
  module RadioCheckCommon
    def self.included(base)
      base.instance_eval do
        attr_ole :set?, :checked
        alias_method :checked?, :set?
      end
    end

    def inspect
      '#<%s:0x%x located=%s specifiers=%s value=%s>' % [self.class, hash*2, !!ole_object, @specifiers.inspect, @value.inspect]
    end
  end

  # Returned by {Container#radio}.
  class Radio < InputElement
    include RadioCheckCommon

    # Clear a radio button.
    #
    # @macro exists
    # @macro enabled
    def clear
      perform_action { @o.checked = false }
    end

    # Check a radio button.
    #
    # @macro exists
    # @macro enabled
    def set
      perform_action do
        @o.scrollIntoView
        @o.checked = true
        click
      end
    end

  end

  # Returned by the {Watir::Container#checkbox} method.
  class CheckBox < InputElement
    include RadioCheckCommon

    # Check or clear the checkbox.
    # @param [Boolean] value If set to true (default) then checkbox is set, cleared otherwise.
    # @macro exists
    # @macro enabled
    def set(value=true)
      perform_action do
        current_value = @o.checked
        click unless value == current_value
      end
    end

    # Clear the checkbox.
    # @macro exists
    # @macro enabled
    def clear
      set false
    end

  end

end

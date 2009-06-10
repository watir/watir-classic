module FireWatir
  #
  # Description:
  #   Class for SelectList element.
  #
  class SelectList < InputElement
    INPUT_TYPES = ["select-one", "select-multiple"]

    attr_accessor :o

    #
    # Description:
    #   Clears the selected items in the select box.
    #
    def clear
      assert_exists
      #highlight( :set)
      wait = false
      each do |selectBoxItem|
        if selectBoxItem.selected
          selectBoxItem.selected = false
          wait = true
        end
      end
      self.wait if wait
      #highlight( :clear)
    end
    alias clearSelection clear

    def each
      assert_exists
      arr_options = js_options
      #puts arr_options[0]#.length
      for i in 0..arr_options.length - 1 do
        yield Option.new(self, :jssh_name, arr_options[i])
      end
    end

    #
    # Description:
    #   Get option element at specified index in select list.
    #
    # Input:
    #   key - option index
    #
    # Output:
    #   Option element at specified index
    #
    def [] (key)
      assert_exists
      arr_options = js_options
      return Option.new(self, :jssh_name, arr_options[key - 1])
    end

    #
    # Description:
    #   Selects an item by text. If you need to select multiple items you need to call this function for each item.
    #
    # Input:
    #   - item - Text of item to be selected.
    #
    def select( item )
      select_items_in_select_list(:text, item)
    end
    alias :set :select

    #
    # Description:
    #   Selects an item by value. If you need to select multiple items you need to call this function for each item.
    #
    # Input:
    # - item - Value of the item to be selected.
    #
    def select_value( item )
      select_items_in_select_list(:value, item)
    end

    #
    # Description:
    #   Gets all the items in the select list as an array.
    #   An empty array is returned if the select box has no contents.
    #
    # Output:
    #   Array containing the items of the select list.
    #
    def options
      assert_exists
      #element.log "There are #{@o.length} items"
      returnArray = []
      each { |thisItem| returnArray << thisItem.text }
      return returnArray
    end

    alias getAllContents options

    #
    # Description:
    #   Gets all the selected items in the select list as an array.
    #   An empty array is returned if the select box has no selected item.
    #
    # Output:
    #   Array containing the selected items of the select list.
    #
    def selected_options
      assert_exists
      returnArray = []
      #element.log "There are #{@o.length} items"
      each do |thisItem|
        #puts "#{thisItem.selected}"
        if thisItem.selected
          #element.log "Item ( #{thisItem.text} ) is selected"
          returnArray << thisItem.text
        end
      end
      return returnArray
    end

    alias getSelectedItems selected_options

    #
    # Description:
    #   Get the option using attribute and its value.
    #
    # Input:
    #   - attribute - Attribute used to find the option.
    #   - value - value of that attribute.
    #
    def option (attribute, value)
      assert_exists
      Option.new(self, attribute, value)
    end
    
    private
    
    # Description:
    #   Selects items from the select box.
    #
    # Input:
    #   - name  - :value or :text - how we find an item in the select box
    #   - item  - value of either item text or item value.
    #
    def select_items_in_select_list(attribute, value)
      assert_exists
      
      attribute = attribute.to_s
      found     = false
      
      value = value.to_s unless [Regexp, String].any? { |e| value.kind_of? e }

      highlight( :set )
      each do |option|
        next unless value.matches(option.invoke(attribute))
        found = true  
        next if option.selected
        
        option.selected = true
        fireEvent("onChange")
        wait
      end
      highlight( :clear )

      unless found
        raise NoValueFoundException, "No option with #{attribute} of #{value.inspect} in this select element"
      end
      
      value
    end

    #
    # Description:
    #   Gets all the options of the select list element.
    #
    # Output:
    #   Array of option elements.
    #
    def js_options
      jssh_socket.send("#{element_object}.options.length;\n", 0)
      length = read_socket().to_i
      # puts "options length is : #{length}"
      arr_options = Array.new(length)
      for i in 0..length - 1
        arr_options[i] = "#{element_object}.options[#{i}]"
      end
      return arr_options
    end
  
  end # Selects
end # FireWatir

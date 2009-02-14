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
      @o.each do |selectBoxItem|
        if selectBoxItem.selected
          selectBoxItem.selected = false
          wait = true
        end
      end
      @o.wait if wait
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
      select_item_in_select_list(:text, item)
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
      select_item_in_select_list(:value, item)
    end

    # Description:
    #   Selects item from the select box.
    #
    # Input:
    #   - name  - :value or :text - how we find an item in the select box
    #   - item  - value of either item text or item value.
    #
    def select_item_in_select_list(attribute, value)
      assert_exists
      highlight( :set )
      doBreak = false
      #element.log "Setting box #{@o.name} to #{attribute} #{value} "
      @o.each do |option| # items in the list
        if value.matches( option.invoke(attribute.to_s))
          if option.selected
            doBreak = true
            break
          else
            option.selected = true
            @o.fireEvent("onChange")
            @o.wait
            doBreak = true
            break
          end
        end
      end
      unless doBreak
        raise NoValueFoundException,
        "No option with #{attribute.to_s} of #{value} in this select element"
      end
      highlight( :clear )
    end
    private :select_item_in_select_list

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
      @o.each { |thisItem| returnArray << thisItem.text }
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
      @o.each do |thisItem|
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

  end # Selects
end # FireWatir

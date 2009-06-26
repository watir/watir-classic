module FireWatir
  #
  # Description:
  #   Class for Option element.
  #
  class Option < InputElement
    #
    # Description:
    #   Initializes the instance of option object.
    #
    # Input:
    #   - select_list - instance of select list element.
    #   - attribute - Attribute to identify the option.
    #   - value - Value of that attribute.
    #
    def initialize (select_list, attribute, value)
      @select_list = @container = select_list
      @how = attribute
      @what = value
      @option = nil
      @element_name = ""
      
      unless [:text, :value, :jssh_name].include? attribute 
        raise MissingWayOfFindingObjectException,
                "Option does not support attribute #{@how}"
      end
      #puts @select_list.o.length
      #puts "what is : #{@what}, how is #{@how}, list name is : #{@select_list.element_name}"
      if(attribute == :jssh_name)
        @element_name = @what
        @option = self
      else    
        @select_list.o.each do |option| # items in the list
          #puts "option is : #{option}"
          if(attribute == :value)
            match_value = option.value
          else    
            match_value = option.text
          end    
          #puts "value is #{match_value}"
          if value.matches( match_value) #option.invoke(attribute))
            @option = option
            @element_name = option.element_name
            break
          end
        end
      end    
    end
    
    #
    # Description:
    #   Checks if option exists or not.
    #
    def assert_exists
      unless @option
        raise UnknownObjectException,  
                "Unable to locate an option using #{@how} and #{@what}"
      end
    end
    private :assert_exists
    
    #
    # Description:
    #   Selects the option.
    #
    def select
      assert_exists
      if(@how == :text)
        @select_list.select(@what)
      elsif(@how == :value)
        @select_list.select_value(@what)
      end    
    end
    
    #
    # Description:
    #   Gets the class name of the option.
    #
    # Output:
    #   Class name of the option.
    #
    def class_name
      assert_exists
      jssh_socket.send("#{element_object}.className;\n", 0)
      return read_socket()
    end
    
    #
    # Description:
    #   Gets the text of the option.
    #
    # Output:
    #   Text of the option.
    #
    def text
      assert_exists
      jssh_socket.send("#{element_object}.text;\n", 0)
      return read_socket()
    end
    
    #
    # Description:
    #   Gets the value of the option.
    #
    # Output:
    #   Value of the option.
    #
    def value
      assert_exists
      jssh_socket.send("#{element_object}.value;\n", 0)
      return read_socket()
    end
    
    #
    # Description:
    #   Gets the status of the option; whether it is selected or not.
    #
    # Output:
    #   True if option is selected, false otherwise.
    #
    def selected
      assert_exists
      jssh_socket.send("#{element_object}.selected;\n", 0)
      value = read_socket()
      return true if value == "true"
      return false if value == "false"
    end
    
    
  end # Option
end # FireWatir
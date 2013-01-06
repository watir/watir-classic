module Watir

  # Returned by {Container#form}.
  class Form < Element

    attr_ole :action

    def initialize(container, specifiers)
      super
      copy_test_config container
    end

    # @return [String] form name attribute value. Will be empty string if does not
    #   exist.
    # @macro exists
    def name
      assert_exists
      name = ole_object.getAttributeNode('name')
      name ? name.value : ''
    end

    # @return [String] form method attribute value.
    # @macro exists
    def form_method
      assert_exists
      ole_object.invoke('method')
    end
    
    # @param [Object] arg when argument is nil, {#form_method} will be called.
    #   Otherwise Ruby's {Kernel#method} will be called.
    def method(arg = nil)
      if arg.nil?
        form_method
      else
        super
      end
    end    

    # Submit the form.
    # @note Will not submit the form if its onSubmit JavaScript callback
    #   returns false.
    # @macro exists
    def submit 
      assert_exists
      @o.submit(0) if dispatch_event "onSubmit"
      @container.wait
    end
   
    # Flash the element the specified number of times for troubleshooting purposes.
    # @param [Fixnum] number number of times to flash the element.
    # @macro exists
    def flash(number=10)
      assert_exists
      @original_element_colors = {}
      number.times do
        set_highlight
        sleep 0.05
        clear_highlight
        sleep 0.05
      end
    end

    # @private
    def locate
      @o = @container.locator_for(FormLocator, @specifiers, self.class).locate
    end

    # @private
    def __ole_inner_elements
      assert_exists
      @o.elements
    end

    private

    # This method is responsible for setting the colored highlighting on the specified form.
    def set_highlight
      @o.elements.each do |element|
        perform_highlight do
          original_color = element.style.backgroundColor
          element.style.backgroundColor = active_object_highlight_color        
          @original_element_colors[element] = original_color
        end
      end
    end

    # This method is responsible for clearing the colored highlighting on the specified form.
    def clear_highlight
      @original_element_colors.each_pair do |element, color|
        perform_highlight do
          element.style.backgroundColor = color
        end
      end
      @original_element_colors.clear
    end
    
  end # class Form
  
end

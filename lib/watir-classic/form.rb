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
    # @param [Fixnum] number Number of times to flash the element.
    # @macro exists
    def flash(number=10)
      assert_exists
      @original_styles = {}
      number.times do
        count = 0
        @o.elements.each do |element|
          highlight(:set, element, count)
          count += 1
        end
        sleep 0.05
        count = 0
        @o.elements.each do |element|
          highlight(:clear, element, count)
          count += 1
        end
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

    # This method is responsible for setting and clearing the colored highlighting on the specified form.
    # use :set  to set the highlight
    #   :clear  to clear the highlight
    # @todo clean this method up and extract two methods
    #   from here similarly to the plan of Element#highlight
    def highlight(set_or_clear, element, count)
      if set_or_clear == :set
        begin
          original_color = element.style.backgroundColor
          original_color = "" if original_color==nil
          element.style.backgroundColor = active_object_highlight_color
        rescue => e
          puts e
          puts e.backtrace.join("\n")
          original_color = ""
        end
        @original_styles[count] = original_color
      else
        begin
          element.style.backgroundColor = @original_styles[ count]
        rescue => e
          puts e
          # we could be here for a number of reasons...
        ensure
        end
      end
    end
    
  end # class Form
  
end

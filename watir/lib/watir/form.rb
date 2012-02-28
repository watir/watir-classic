module Watir

  class Form < Element
    def initialize(container, specifiers)
      super
      copy_test_config container
    end

    attr_ole :action
    attr_ole :name

    def form_method
      assert_exists
      @o.invoke('method')
    end

    def method(arg = nil)
      if arg.nil?
        form_method
      else
        super
      end
    end    

    def locate
      @o = @container.locator_for(FormLocator, @specifiers, self.class).locate
    end

    # Submit the data -- equivalent to pressing Enter or Return to submit a form.
    def submit 
      assert_exists
      @o.submit(0) if dispatch_event "onSubmit"
      @container.wait
    end
    
    def __ole_inner_elements
      assert_exists
      @o.elements
    end

    # This method is responsible for setting and clearing the colored highlighting on the specified form.
    # use :set  to set the highlight
    #   :clear  to clear the highlight
    def highlight(set_or_clear, element, count)
      if set_or_clear == :set
        begin
          original_color = element.style.backgroundColor
          original_color = "" if original_color==nil
          element.style.backgroundColor = activeObjectHighLightColor
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
    private :highlight
    
    # causes the object to flash. Normally used in IRB when creating scripts
    # Default is 10
    def flash number=10
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
    
  end # class Form
  
end

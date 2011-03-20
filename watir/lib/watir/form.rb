module Watir

  # Forms

  class FormElement < Element
    def_wrap_guard :action

    def name
      assert_exists
      @o.getAttributeNode('name').value
    end

    def form_method
      assert_exists
      @o.invoke('method')
    end

    def method(arg = nil)
      if arg.nil?
        form_method
      else
        super(arg)
      end
    end
  end
  
  #   Form Factory object
  class Form < FormElement
    include Container
    
    attr_accessor :form

    #   * container   - the containing object, normally an instance of IE
    #   * how         - symbol - how we access the form (:name, :id, :index, :action, :method)
    #   * what        - what we use to access the form
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      copy_test_config container
    end

    def locate
      log "Get form how is #{@how}  what is #{@what} "

      # Get form using xpath.
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      elsif @how == :css
        @o = @container.element_by_css(@what)
      else
        locator = FormLocator.new(@container, 'FORM')
        locator.set_specifier(@how, @what)
        @o = locator.locate
      end
    end

    # Submit the data -- equivalent to pressing Enter or Return to submit a form.
    def submit 
      assert_exists
      @o.invoke('submit')
      @container.wait
    end
    
    def ole_inner_elements
      assert_exists
      @o.elements
    end
    private :ole_inner_elements

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
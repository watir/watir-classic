module FireWatir
  class Form < Element

    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of form object.
    #
    # Input:
    #   - how - Attribute to identify the form element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end

    def locate
      # Get form using xpath.
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("form", @how, @what)
      end
      @o = self
    end

    # Submit the form. Equivalent to pressing Enter or Return to submit a form.
    def submit
      assert_exists
      submit_form
      @o.wait
    end

  end # Form
end # FireWatir

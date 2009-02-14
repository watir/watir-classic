module FireWatir
  #
  # Description:
  #   Base class containing items that are common between select list, text field, button, hidden, file field classes.
  #
  class InputElement < Element
    attr_accessor :element_name
    #
    # Description:
    #   Locate the element on the page. Element can be a select list, text field, button, hidden, file field.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        if(self.class::INPUT_TYPES.include?("select-one"))
          @element_name = locate_tagged_element("select", @how, @what, self.class::INPUT_TYPES)
        else
          @element_name = locate_tagged_element("input", @how, @what, self.class::INPUT_TYPES)
        end
      end
      @o = self
    end
    #
    # Description:
    #   Initializes the instance of element.
    #
    # Input:
    #   - how - Attribute to identify the element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
      @element_name = ""
      #super(nil)
    end

  end # FireWatir
end # InputElement

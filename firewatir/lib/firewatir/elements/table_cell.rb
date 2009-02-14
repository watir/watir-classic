module FireWatir
  #
  # Description:
  # Class for Table Cell.
  #
  class TableCell < Element
    attr_accessor :element_name

    # Description:
    #   Locate the table cell element on the page.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("TD", @how, @what)
      end
      @o = self
    end

    #
    # Description:
    #   Initializes the instance of table cell object.
    #
    # Input:
    #   - how - Attribute to identify the table cell element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
      #super nil
    end

    alias to_s text

    #
    # Description:
    #   Gets the col span of table cell.
    #
    # Output:
    #   Colspan of table cell.
    #
    def colspan
      assert_exists
      @o.colSpan
    end

  end # TableCell
end # FireWatir

module FireWatir
  #
  # Description:
  #   Class for Link element.
  #
  class Link < Element
    attr_accessor :element_name
    TAG = 'A'
    #
    # Description:
    #   Initializes the instance of link element.
    #
    # Input:
    #   - how - Attribute to identify the link element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end

    #
    # Description:
    #   Locate the link element on the page.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('A', @how, @what)
      end
      @o = self
    end

    #TODO: if an image is used as part of the link, this will return true
    #def link_has_image
    #    assert_exists
    #    return true  if @o.getElementsByTagName("IMG").length > 0
    #    return false
    #end

    #TODO: this method returns the src of an image, if an image is used as part of the link
    #def src # BUG?
    #    assert_exists
    #    if @o.getElementsByTagName("IMG").length > 0
    #        return  @o.getElementsByTagName("IMG")[0.to_s].src
    #    else
    #        return ""
    #    end
    #end

    #
    # Description:
    #   Used to populate the properties in to_s method.
    #
    #def link_string_creator
    #    n = []
    #    n <<   "href:".ljust(TO_S_SIZE) + self.href
    #    n <<   "inner text:".ljust(TO_S_SIZE) + self.text
    #    n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
    #    return n
    #    end

    # returns a textual description of the link

    def to_s
      assert_exists
      super({"href" => "href","inner text" => "text"})
    end

  end # Link
end # FireWatir

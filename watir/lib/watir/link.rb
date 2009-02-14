module Watir  
  
  # This class is the means of accessing a link on a page
  # Normally a user would not need to create this object as it is returned by the Watir::Container#link method
  # many of the methods available to this object are inherited from the Element class
  #
  class Link < Element
    # Returns an initialized instance of a link object
    #   * container  - an instance of a container
    #   * how         - symbol - how we access the link
    #   * what         - what we use to access the link, text, url, index etc
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super(nil)
    end
    
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        begin
          @o = @container.locate_tagged_element('A', @how, @what)
        rescue UnknownObjectException
          @o = nil
        end
      end
    end
    
    # if an image is used as part of the link, this will return true
    def link_has_image
      assert_exists
      return true if @o.getElementsByTagName("IMG").length > 0
      return false
    end
    
    # this method returns the src of an image, if an image is used as part of the link
    def src # BUG?
      assert_exists
      if @o.getElementsByTagName("IMG").length > 0
        return @o.getElementsByTagName("IMG")[0.to_s].src
      else
        return ""
      end
    end
    
    def link_string_creator
      n = []
      n <<   "href:".ljust(TO_S_SIZE) + self.href
      n <<   "inner text:".ljust(TO_S_SIZE) + self.text
      n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
      return n
    end
    
    # returns a textual description of the link
    def to_s
      assert_exists
      r = string_creator
      r = r + link_string_creator
      return r.join("\n")
    end
  end
  
end
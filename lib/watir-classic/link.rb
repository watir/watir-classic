module Watir  
  
  # Returned by {Container#link}.
  class Link < Element
    attr_ole :type
    attr_ole :href
    attr_ole :name

    # @deprecated Use "browser.link.imgs.length > 0" instead.
    def link_has_image
      assert_exists
      @o.getElementsByTagName("IMG").length > 0
    end
    
    # @deprecated Use "browser.link.imgs.first.src rescue ''" instead.
    def src
      assert_exists
      if @o.getElementsByTagName("IMG").length > 0
        return @o.getElementsByTagName("IMG")[0.to_s].src
      else
        return ""
      end
    end

    def to_s
      assert_exists
      r = string_creator
      r = r + link_string_creator
      return r.join("\n")
    end
    
    # @private
    def link_string_creator
      n = []
      n <<   "href:".ljust(TO_S_SIZE) + self.href
      n <<   "inner text:".ljust(TO_S_SIZE) + self.text
      n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
      return n
    end
    
  end
  
end

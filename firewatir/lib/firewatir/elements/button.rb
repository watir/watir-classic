module FireWatir
  #
  # Description:
  #   Class for Button element.
  #
  class Button < InputElement
    INPUT_TYPES = ["button", "submit", "image", "reset"]

    def locate
      super
      @o = @element.locate_tagged_element("button", @how, @what, self.class::INPUT_TYPES) unless @o
    end

  end # Button
end # FireWatir

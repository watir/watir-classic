module FireWatir
  class Frame < Element

    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of frame or iframe object.
    #
    # Input:
    #   - how - Attribute to identify the frame element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end

    def locate
      if(@how == :jssh_name)
        @element_name = @what
      else
        @element_name = locate_frame(@how, @what)
      end
      #puts @element_name
      @o = self

      unless @element_name
        raise UnknownFrameException, "Unable to locate a frame using #{@how} and #{@what}. "
      end
    end

    def html
      assert_exists
      get_frame_html
    end

    def document_var # unfinished
      "document"
    end

    def body_var # unfinished
      "body"
    end

    def window_var
      "window"
    end

    def browser_var
      "browser"
    end

  end # Frame
end # FireWatir

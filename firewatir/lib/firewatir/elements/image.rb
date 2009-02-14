module FireWatir
  #
  # Description:
  #   Class for Image element.
  #
  class Image < Element
    attr_accessor :element_name
    TAG = 'IMG'
    #
    # Description:
    #   Initializes the instance of image object.
    #
    # Input:
    #   - how - Attribute to identify the image element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end

    # Description:
    #   Locate the image element on the page.
    #
    def locate
      case @how
      when:jssh_name
        @element_name = @what
      when :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('IMG', @how, @what)
      end
      @o = self
    end

    #
    # Description:
    #   Used to populate the properties in to_s method. Not used anymore
    #
    def image_string_creator
      n = []
      n <<   "src:".ljust(TO_S_SIZE) + self.src.to_s
      n <<   "file date:".ljust(TO_S_SIZE) + self.fileCreatedDate.to_s
      n <<   "file size:".ljust(TO_S_SIZE) + self.fileSize.to_s
      n <<   "width:".ljust(TO_S_SIZE) + self.width.to_s
      n <<   "height:".ljust(TO_S_SIZE) + self.height.to_s
      n <<   "alt:".ljust(TO_S_SIZE) + self.alt.to_s
      return n
    end
    private :image_string_creator

    # returns a string representation of the object
    def to_s
      assert_exists
      super({"src" => "src","width" => "width","height" => "height","alt" => "alt"})
    end

    # this method returns the file created date of the image
    #def file_created_date
    #    assert_exists
    #    return @o.invoke("fileCreatedDate")
    #end
    # alias fileCreatedDate file_created_date

    # this method returns the filesize of the image
    #def file_size
    #    assert_exists
    #    return @o.invoke("fileSize").to_s
    #end
    # alias fileSize file_size

    #
    # Description:
    #   Gets the width of the image in pixels, as a string.
    #
    # Output:
    #   Width of image (in pixels).
    #
    def width
      assert_exists
      return @o.invoke("width").to_s
    end

    #
    # Description:
    #   Gets the height of the image in pixels, as a string.
    #
    # Output:
    #   Height of image (in pixels).
    #
    def height
      assert_exists
      return @o.invoke("height").to_s
    end

    # This method attempts to find out if the image was actually loaded by the web browser.
    # If the image was not loaded, the browser is unable to determine some of the properties.
    # We look for these missing properties to see if the image is really there or not.
    # If the Disk cache is full ( tools menu -> Internet options -> Temporary Internet Files) , it may produce incorrect responses.
    #def has_loaded
    #    locate
    #    raise UnknownObjectException, "Unable to locate image using #{@how} and #{@what}" if @o == nil
    #    return false if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
    #    return true
    #end
    # alias hasLoaded? loaded?

    #
    # Description:
    #   Highlights the image ( in fact it adds or removes a border around the image)
    #
    # Input:
    #   - set_or_clear - :set to set the border, :clear to remove it
    #
    def highlight( set_or_clear )
      if set_or_clear == :set
        begin
          @original_border = @o.border
          @o.border = 1
        rescue
          @original_border = nil
        end
      else
        begin
          @o.border = @original_border
          @original_border = nil
        rescue
          # we could be here for a number of reasons...
        ensure
          @original_border = nil
        end
      end
    end
    private :highlight

  end # Image
end # FireWatir

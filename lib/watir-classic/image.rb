module Watir
  
  # Returned by {Container#image}
  class Image < Element
    attr_ole :alt
    attr_ole :src

    # this method produces the properties for an image as an array
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
    
    def to_s
      assert_exists
      r = string_creator
      r += image_string_creator
      return r.join("\n")
    end
    
    # @return [Fixnum] file size of the image in bytes.
    # @macro exists
    def file_size
      assert_exists
      @o.invoke("fileSize").to_i
    end
    
    # @return [Fixnum] width of the image in pixels.
    # @macro exists
    def width
      assert_exists
      @o.invoke("width").to_i
    end
    
    # @return [Fixnum] height of the image in pixels.
    # @macro exists
    def height
      assert_exists
      @o.invoke("height").to_i
    end
    
    # @return [Boolean] true if image is loaded by the browser, false otherwise.
    # @macro exists
    def loaded?
      assert_exists
      file_size != -1
    end
    
    # this method highlights the image (in fact it adds or removes a border around the image)
    #  * set_or_clear   - symbol - :set to set the border, :clear to remove it
    # @todo improve this method like there's a plan for Element#highlight
    def highlight(set_or_clear)
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
    
    # Save the image to the file.
    #
    # @example
    #   browser.image.save("c:/foo/bar.jpg")
    #
    # @param [String] path path to the file.
    #
    # @note This method will not overwrite a previously existing image.
    #   If an image already exists at the given path then a dialog
    #   will be displayed prompting for overwrite.
    #
    # @todo it should raise an Exception if image already exists.
    def save(path)
      @container.goto(src)
      begin
        fill_save_image_dialog(path)
        @container.document.execCommand("SaveAs")
      ensure
        @container.back
      end
    end
    
    def fill_save_image_dialog(path)
      command = "require 'rubygems';require 'rautomation';" <<
                "window=::RAutomation::Window.new(:title => 'Save Picture');" <<
                "window.text_field(:class => 'Edit', :index => 0).set('#{path.gsub(File::SEPARATOR, File::ALT_SEPARATOR)}');" <<
                "window.button(:value => '&Save').click"
      IO.popen("ruby -e \"#{command}\"")
    end
    private :fill_save_image_dialog

  end
  
end

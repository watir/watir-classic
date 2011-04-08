module Watir
  class Frame < Element
    include PageContainer

    # Find the frame denoted by how and what in the container and return its ole_object
    def locate
      @o = nil
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      elsif @how == :css
        @o = @container.element_by_css(@what)
      else      
        locator = FrameLocator.new(@container)
        locator.set_specifier(@how, @what)
        ['FRAME', 'IFRAME'].each do |frame_tag|
          locator.tag = frame_tag
          located_frame, document = locator.locate
          unless (located_frame.nil? && document.nil?)
            @o = located_frame
            @document = document.document
            break
          end
        end
      end
    end

    def ole_inner_elements
      document.body.all
    end
    private :ole_inner_elements

    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      copy_test_config container
    end
    
    def document
      assert_exists
      @document
    end

    def attach_command
      @container.page_container.attach_command + ".frame(#{@how.inspect}, #{@what.inspect})".gsub('"','\'')
    end
    
  end
end
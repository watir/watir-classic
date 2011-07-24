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
            begin
              @document = document.document
            rescue WIN32OLERuntimeError => e
              if e.message =~ /Access is denied/
                # This frame's content is not directly accessible but let the
                # user continue so they can access the frame properties
              else
                raise e
              end
            end
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
      if @document
        @document
      else
        raise FrameAccessDeniedException, "IE will not allow access to this frame for security reasons. You can work around this with ie.goto(frame.src)"
      end
    end

    def attach_command
      @container.page_container.attach_command + ".frame(#{@how.inspect}, #{@what.inspect})".gsub('"','\'')
    end
    
  end
end
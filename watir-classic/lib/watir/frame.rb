module Watir
  class Frame < Element
    include PageContainer
    attr_accessor :document

    attr_ole :name
    attr_ole :src

    def initialize(container, specifiers)
      super
      copy_test_config container
    end
    
    # Find the frame denoted by specifiers in the container and return its ole_object
    def locate
      frame, document = @container.locator_for(FrameLocator, @specifiers, self.class).locate
      if frame && document
        @o = frame
        begin
          @document = document.document
        rescue WIN32OLERuntimeError => e
          # This frame's content is not directly accessible but let the
          # user continue so they can access the frame properties            
          raise e unless e.message =~ /Access is denied/
        end        
      end
    end

    def __ole_inner_elements
      document.body.all
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
      @container.page_container.attach_command + ".frame(#{@specifiers.inspect})".gsub('"','\'')
    end

  end
end

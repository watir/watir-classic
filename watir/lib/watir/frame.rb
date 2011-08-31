module Watir
  class Frame < Element
    include PageContainer
    TAG = ['FRAME', 'IFRAME']

    attr_accessor :document

    # Find the frame denoted by how and what in the container and return its ole_object
    def locate
      frame, document = @container.locator_for(FrameLocator, @how, @what).locate
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

    def document_mode
      document.documentMode
    end

    def attach_command
      @container.page_container.attach_command + ".frame(#{@how.inspect}, #{@what.inspect})".gsub('"','\'')
    end
    
  end
end

module Watir
  class Frame < Element
    include PageContainer
    attr_accessor :document

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

    def execute_script(source)
      document.parentWindow.eval(source.to_s)
    rescue WIN32OLERuntimeError, NoMethodError #if eval fails we need to use execScript(source.to_s) which does not return a value, hence the workaround
      escaped_src = source.to_s.gsub(/[\r\n']/) {|m| "\\#{m}"}
      wrapper = "_watir_helper_div_#{Time.now.to_i}"
      cmd = "var e = document.createElement('DIV'); e.style.display = 'none'; e.id='#{wrapper}'; e.innerHTML = eval('#{escaped_src}'); document.body.appendChild(e);"
      document.parentWindow.execScript(cmd)
      document.getElementById(wrapper).wrapper_obj.innerHTML
    end

  end
end

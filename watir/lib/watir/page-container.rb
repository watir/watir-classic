module Watir    
  # A PageContainer contains an HTML Document. In other words, it is a 
  # what JavaScript calls a Window.
  module PageContainer
    include Watir::Exception

    # This method checks the currently displayed page for http errors, 404, 500 etc
    # It gets called internally by the wait method, so a user does not need to call it explicitly

    def check_for_http_error
      # check for IE7
      n = self.document.invoke('parentWindow').navigator.appVersion
      m=/MSIE\s(.*?);/.match( n )
      if m and m[1] =='7.0'
        if m = /HTTP (\d\d\d.*)/.match( self.title )
          raise NavigationException, m[1]
        end
      else
        # assume its IE6
        url = self.document.location.href
        if /shdoclc.dll/.match(url)
          m = /id=IEText.*?>(.*?)</i.match(self.html)
          raise NavigationException, m[1] if m
        end
      end
      false
    end 
    
    # The HTML Page
    def page
      document.documentelement
    end
    private :page
        
    # The HTML of the current page
    def html
      page.outerhtml
    end
    
    # The url of the page object. 
    def url
      page.document.location.href
    end
    
    # The text of the current page
    def text
      page.innertext.strip
    end

    def eval_in_spawned_process(command)
      command.strip!
      load_path_code = _code_that_copies_readonly_array($LOAD_PATH, '$LOAD_PATH')
      ruby_code = "require 'watir/ie'; "
#      ruby_code = "$HIDE_IE = #{$HIDE_IE};" # This prevents attaching to a window from setting it visible. However modal dialogs cannot be attached to when not visible.
      ruby_code << "pc = #{attach_command}; " # pc = page container
      # IDEA: consider changing this to not use instance_eval (it makes the code hard to understand)
      ruby_code << "pc.instance_eval(#{command.inspect})"
      exec_string = "start rubyw -e #{(load_path_code + '; ' + ruby_code).inspect}"
      system(exec_string)
    end
    
    def set_container container
      @container = container
      @page_container = self
    end
    
    # This method is used to display the available html frames that Internet Explorer currently has loaded.
    # This method is usually only used for debugging test scripts.
    def show_frames
      if allFrames = document.frames
        count = allFrames.length
        puts "there are #{count} frames"
        for i in 0..count-1 do
          begin
            fname = allFrames[i.to_s].name.to_s
            puts "frame  index: #{i + 1} name: #{fname}"
          rescue => e
            puts "frame  index: #{i + 1} Access Denied, see http://wiki.openqa.org/display/WTR/FAQ#access-denied" if e.to_s.match(/Access is denied/)
          end
        end
      else
        puts "no frames"
      end
    end

    # Search the current page for specified text or regexp.
    # Returns the index if the specified text was found.
    # Returns matchdata object if the specified regexp was found.
    # 
    # *Deprecated* 
    # Instead use 
    #   IE#text.include? target 
    # or
    #   IE#text.match target
    def contains_text(target)
        if target.kind_of? Regexp
          self.text.match(target)
        elsif target.kind_of? String
          self.text.index(target)
        else
          raise ArgumentError, "Argument #{target} should be a string or regexp."
        end
    end

  end # module
end
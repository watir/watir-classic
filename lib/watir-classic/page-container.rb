module Watir
  # A PageContainer contains an HTML Document. In other words, it is a
  # what JavaScript calls a Window.
  module PageContainer
    include Watir::Exception

    # This method checks the currently displayed page for http errors, 404, 500 etc
    # It gets called internally by the wait method, so a user does not need to call it explicitly
    # @private
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

    # Execute the given JavaScript string in the context of the current page.
    #
    # @example
    #   browser.execute_script "var a=1; var b=a+1; return b"
    #
    # @example
    #   browser.execute_script("return {a: 1, b: 2}")["b"] # => 1
    #
    # @note It is needed to call return inside of the JavaScript if the value
    #   is needed at Ruby side.
    #
    # @return [Object] appropriate type of the object, which is returned from the
    #   JavaScript via "return" keyword or nil when "return" is omitted.
    def execute_script(source)
      result = nil
      begin
        source = with_json2_if_needed source
        result = document.parentWindow.eval(source)
      rescue WIN32OLERuntimeError, NoMethodError #if eval fails we need to use execScript(source.to_s) which does not return a value, hence the workaround
        escaped_src = source.gsub(/\r?\n/, "\\n").gsub("'", "\\\\'")
        wrapper = "_watir_helper_div_#{::Time.now.to_i + ::Time.now.usec}"
        cmd = "var e = document.createElement('DIV'); e.style.display='none'; e.id='#{wrapper}'; e.innerHTML = eval('#{escaped_src}'); document.body.appendChild(e);"
        document.parentWindow.execScript(cmd)
        result = document.getElementById(wrapper).innerHTML
      end

      MultiJson.load(result)["value"] rescue nil
    end

    # @return [String] html of the current page.
    def html
      page.outerhtml
    end

    # @return [String] url of the page.
    def url
      page.document.location.href
    end

    # @return [String] text of the page.
    def text
      page.innertext.strip
    end

    # @private
    def set_container container
      @container = container
      @page_container = self
    end

    # @deprecated Use "browser.text.include?(target)" or "browser.text.match(target)"
    def contains_text(target)
      if target.kind_of? Regexp
        self.text.match(target)
      elsif target.kind_of? String
        self.text.index(target)
      else
        raise ArgumentError, "Argument #{target} should be a string or regexp."
      end
    end

    def with_json2_if_needed source
      %Q[
      (function() {
        if (!window.JSON || !window.JSON.stringify) {
          var json2=document.createElement('script');
          json2.type='text/javascript';
          json2.src='file:///#{File.expand_path(File.dirname(__FILE__) + "/ext/json2.js")}'; 
          document.getElementsByTagName('head')[0].appendChild(json2)
        } 

        return JSON.stringify({value: (function() {#{source}})()});
      })()
      ]
    end

    private :with_json2_if_needed

  end # module
end



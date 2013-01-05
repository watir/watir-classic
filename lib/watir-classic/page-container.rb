module Watir
  # A PageContainer contains an HTML Document. In other words, it is a
  # what JavaScript calls a Window.
  module PageContainer
    include Watir::Exception

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

    # @private
    def set_container container
      @container = container
      @page_container = self
    end

    private

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

    # The HTML Page
    def page
      document.documentelement
    end

  end # module
end



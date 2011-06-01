require 'json'

module FireWatir
  # Base class for html elements.
  # This is not a class that users would normally access.
  class Element
    include Watir::ElementExtensions
    include FireWatir::Container
    # Number of spaces that separate the property from the value in the to_s method
    TO_S_SIZE = 14

    # How to get the nodes using XPath in mozilla.
    ORDERED_NODE_ITERATOR_TYPE = 5
    # To get the number of nodes returned by the xpath expression
    NUMBER_TYPE = 1
    # To get single node value
    FIRST_ORDERED_NODE_TYPE = 9
    # This stores the level to which we have gone finding element inside another element.
    # This is just to make sure that every element has unique name in JSSH.
    @@current_level = 0
    # This stores the name of the element that is about to trigger an Javascript pop up.
    #@@current_js_object = nil

    attr_accessor :element_name
    #
    # Description:
    #    Creates new instance of element. If argument is not nil and is of type string this
    #    sets the element_name and element_type property of the object. These properties can
    #    be accessed using element_object and element_type methods respectively.
    #
    #    Used internally by FireWatir.
    #
    # Input:
    #   element - Name of the variable with which the element is referenced in JSSh.
    #
    def initialize(element, container=nil)
      @container = container
      @element_name = element
      @element_type = element_type
      #puts "in initialize "
      #puts caller(0)
      #if(element != nil && element.class == String)
      #@element_name = element
      #elsif(element != nil && element.class == Element)
      #    @o = element
      #end

      #puts "@element_name is #{@element_name}"
      #puts "@element_type is #{@element_type}"
    end

    private
    def self.def_wrap(ruby_method_name, ole_method_name = nil)
      ole_method_name = ruby_method_name unless ole_method_name
      class_eval "def #{ruby_method_name}
                          assert_exists
                          # Every element has its name starting from element. If yes then
                          # use element_name to send the command to jssh. Else its a number
                          # and we are still searching for element, in this case use doc.all
                          # array with element_name as index to send command to jssh
                          #puts element_object.to_s
                          #if(@element_type == 'HTMLDivElement')
                          #    ole_method_name = 'innerHTML'
                          #end
                          jssh_socket.send('typeof(' + element_object + '.#{ole_method_name});\n', 0)
                          return_type = read_socket()

                          return_value = get_attribute_value(\"#{ole_method_name}\")

                          #if(return_value == '' || return_value == \"null\")
                          #    return_value = \"\"
                          #end

                          if(return_type == \"boolean\")
                              return_value = false if return_value == \"false\"
                              return_value = true if return_value == \"true\"
                          end
                          #puts return_value
                          @@current_level = 0
                          return return_value
                      end"
    end

    def get_attribute_value(attribute_name)
      #if the attribut name is columnLength get number of cells in first row if rows exist.
      case attribute_name
      when "columnLength"
        rowsLength = js_eval_method "columns"
        if (rowsLength != 0 || rowsLength != "")
          return js_eval_method("rows[0].cells.length")
        end
      when "text"
        return text
      when "url", "href", "src", "action", "name"
        return_value = js_eval_method("getAttribute(\"#{attribute_name}\")")
      else
        if valid_js_identifier? attribute_name
          jssh_command = "var attribute = '';
             if(#{element_object}.#{attribute_name} != undefined)
                 attribute = #{element_object}.#{attribute_name};
             else
                 attribute = #{element_object}.getAttribute(\"#{attribute_name}\");
             attribute;"
        else
          jssh_command = "var attribute = ''; attribute = #{element_object}.getAttribute(\"#{attribute_name}\"); attribute;"
        end
        return_value = js_eval(jssh_command)
      end
      if attribute_name == "value"
        tagName = js_eval_method("tagName").downcase
        type = js_eval_method("type").downcase

        if tagName == "button" || ["image", "submit", "reset", "button"].include?(type)
          if return_value == "" || return_value == "null"
            return_value = js_eval_method "innerHTML"
          end
        end
      end

      if return_value == "null" || return_value =~ /\[object\s.*\]/
        return_value = ""
      end
      return return_value
    end
    private :get_attribute_value


    #
    # Description:
    #   Returns an array of the properties of an element, in a format to be used by the to_s method.
    #   additional attributes are returned based on the supplied atributes hash.
    #   name, type, id, value and disabled attributes are common to all the elements.
    #   This method is used internally by to_s method.
    #
    # Output:
    #   Array with values of the following properties:
    #   name, type, id, value disabled and the supplied attribues list.
    #
    def string_creator(attributes = nil)
      n = []
      n << "name:".ljust(TO_S_SIZE) + get_attribute_value("name")
      n << "type:".ljust(TO_S_SIZE) + get_attribute_value("type")
      n << "id:".ljust(TO_S_SIZE) + get_attribute_value("id")
      n << "value:".ljust(TO_S_SIZE) + get_attribute_value("value")
      n << "disabled:".ljust(TO_S_SIZE) + get_attribute_value("disabled")
      #n << "style:".ljust(TO_S_SIZE) + get_attribute_value("style")
      #n << "class:".ljust(TO_S_SIZE) + get_attribute_value("className")

      if(attributes != nil)
        attributes.each do |key,value|
          n << "#{key}:".ljust(TO_S_SIZE) + get_attribute_value(value)
        end
      end
      return n
    end

    #
    # Description:
    #   Sets and clears the colored highlighting on the currently active element.
    #
    # Input:
    #   set_or_clear - this can have following two values
    #   :set - To set the color of the element.
    #   :clear - To clear the color of the element.
    #
    def highlight(set_or_clear)
      if set_or_clear == :set
        #puts "element_name is : #{element_object}"
        jssh_command = " var original_color = #{element_object}.style.background;"
        jssh_command << " #{element_object}.style.background = \"#{DEFAULT_HIGHLIGHT_COLOR}\"; original_color;"

        # TODO: Need to change this so that it would work if user sets any other color.
        #puts "color is : #{DEFAULT_HIGHLIGHT_COLOR}"
        jssh_socket.send("#{jssh_command}\n", 0)
        @original_color = read_socket()

      else # BUG: assumes is :clear, but could actually be anything
        begin
          jssh_socket.send("#{element_object}.style.background = \"#{@original_color}\";\n", 0)
          read_socket()
        rescue
          # we could be here for a number of reasons...
          # e.g. page may have reloaded and the reference is no longer valid
        ensure
          @original_color = nil
        end
      end
    end
    protected :highlight

    #
    # Description:
    #   Returns array of rows for a given table. Returns nil if calling element is not of table type.
    #
    # Output:
    #   Array of row elements in an table or nil
    #
    def get_rows()
      #puts "#{element_object} and #{element_type}"
      if(element_type == "HTMLTableElement")
        jssh_socket.send("#{element_object}.rows.length;\n", 0)
        length = read_socket().to_i
        #puts "The number of rows in the table are : #{no_of_rows}"
        return_array = Array.new(length)
        for i in 0..length - 1 do
          return_array[i] = "#{element_object}.rows[#{i}]"
        end
        return return_array
      else
        puts "Trying to access rows for Element of type #{element_type}. Element must be of table type to execute this function."
        return nil
      end
    end
    private :get_rows

    def set_specifier(how, what)
      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end

      @specifiers = {:index => 1} # default if not specified

      specifiers.each do |how, what|
        what = what.to_i if how == :index
        how = :href if how == :url
        how = :value if how == :caption
        how = :class if how == :class_name

        @specifiers[how] = what
      end
    end

    #
    # Description:
    #   Locates the element on the page depending upon the parameters passed. Logic for locating the element is written
    #   in JavaScript and then send to JSSh; so that we don't make small round-trips via socket to JSSh. This is done to
    #   improve the performance for locating the element.
    #
    # Input:
    #   tag - Tag name of the element to be located like "input", "a" etc. This is case insensitive.
    #   how - The attribute by which you want to locate the element like id, name etc. You can use any attribute-value pair
    #         that uniquely identifies that element on the page. If there are more that one element that have identical
    #         attribute-value pair then first element that is found while traversing the DOM will be returned.
    #   what - The value of the attribute specified by how.
    #   types - Used if that HTML element to be located has different type like input can be of type image, button etc.
    #           Default value is nil
    #   value - This is used only in case of radio buttons where they have same name but different value.
    #
    # Output:
    #   Returns nil if unable to locate the element, else return the element.
    #
    def locate_tagged_element(tag, how, what, types = nil, value = nil)
      #puts caller(0)
      #             how = :value if how == :caption
      #             how = :href if how == :url
      set_specifier(how, what)
      #puts "(locate_tagged_element)current element is : #{@container.class} and tag is #{tag}"
      # If there is no current element i.e. element in current context we are searching the whole DOM tree.
      # So get all the elements.

      if(types != nil and types.include?("button"))
        jssh_command = "var isButtonElement = true;"
      else
        jssh_command = "var isButtonElement = false;"
      end

      # In HTML, getElementsByTagName is case insensitive. However, in XHTML, it needs to be lowercase.
      tag = tag.downcase

      # Because in both the below cases we need to get element with respect to document.
      # when we locate a frame document is automatically adjusted to point to HTML inside the frame
      if(@container.class == FireWatir::Firefox || @container.class == Frame)
        #end
        #if(@@current_element_object == "")
        jssh_command << "var elements_#{tag} = null; elements_#{tag} = #{@container.document_var}.getElementsByTagName(\"#{tag}\");"
        if(types != nil and (types.include?("textarea") or types.include?("button")) )
          jssh_command << "elements_#{tag} = #{@container.document_var}.body.getElementsByTagName(\"*\");"
        end
        #    @@has_changed = true
      else
        #puts "container name is: " + @container.element_name
        #locate if defined? locate
        #@container.locate

	# We cannot assume that the container exists at this point, because code like:
	# b.div(:id, "something_that_does_not_exist").h2(:text, /foobar/).exists? would return true
	if (!@container.exists?)
	  return nil
	end

        jssh_command << "var elements_#{@@current_level}_#{tag} = #{@container.element_name}.getElementsByTagName(\"#{tag}\");"
        if(types != nil and (types.include?("textarea") or types.include?("button") ) )
          jssh_command << "elements_#{@@current_level}_#{tag} = #{@container.element_name}.getElementsByTagName(\"*\");"
        end
        #    @@has_changed = false
      end


      if(types != nil)
        jssh_command << "var types = new Array("
        count = 0
        types.each do |type|
          if count == 0
            jssh_command << "\"#{type}\""
            count += 1
          else
            jssh_command << ",\"#{type}\""
          end
        end
        jssh_command << ");"
      else
        jssh_command << "var types = null;"
      end
      #jssh_command << "var elements = #{element_object}.getElementsByTagName('*');"
      jssh_command << "var object_index = 1; var o = null; var element_name = \"\";"

      case value
      when Regexp
        jssh_command << "var value = #{ rb_regexp_to_js(value) };"
      when nil
        jssh_command << "var value = null;"
      else
        jssh_command << "var value = \"#{value}\";"
      end

      #add hash arrays
      sKey = "var hashKeys = new Array("
      sVal = "var hashValues = new Array("
      @specifiers.each do |k,v|
        sKey += "\"#{k}\","
        if v.is_a?(Regexp)
          sVal += "#{rb_regexp_to_js(v)},"
        else
          sVal += "\"#{v}\","
        end
      end
      sKey = sKey[0..sKey.length-2]
      sVal = sVal[0..sVal.length-2]
      jssh_command << sKey + ");"
      jssh_command << sVal + ");"

      #index
      jssh_command << "var target_index = 1;
                               for(var k=0; k<hashKeys.length; k++)
                               {
                                 if(hashKeys[k] == \"index\")
                                 {
                                   target_index = parseInt(hashValues[k]);
                                   break;
                                 }
                               }"

      #jssh_command << "elements.length;"
      if(@container.class == FireWatir::Firefox || @container.class == Frame)

        jssh_command << "for(var i=0; i<elements_#{tag}.length; i++)
                                   {
                                      if(element_name != \"\") break;
                                      var element = elements_#{tag}[i];"
      else
        jssh_command << "for(var i=0; i<elements_#{@@current_level}_#{tag}.length; i++)
                                   {
                                      if(element_name != \"\") break;
                                      var element = elements_#{@@current_level}_#{tag}[i];"
      end

      # Because in IE for button the value of "value" attribute also corresponds to the innerHTML if value attribute
      # is not supplied. For e.g.: <button>Sign In</button>, in this case value of "value" attribute is "Sign In"
      # though value attribute is not supplied. But for Firefox value of "value" attribute is null. So to make sure
      # script runs on both IE and Watir we are also considering innerHTML if element is of button type.
      jssh_command << "   var attribute = \"\";
                                  var same_type = false;
                                  if(types)
                                  {
                                      for(var j=0; j<types.length; j++)
                                      {
                                          if(types[j] == element.type || types[j] == element.tagName)
                                          {
                                              same_type = true;
                                              break;
                                          }
                                      }
                                  }
                                  else
                                  {
                                      same_type = true;
                                  }
                                  if(same_type == true)
                                  {
                                      var how = \"\";
                                      var what = null;
                                      attribute = \"\";
                                      for(var k=0; k<hashKeys.length; k++)
                                      {
                                         how = hashKeys[k];
                                         what = hashValues[k];

                                         if(how == \"index\")
                                         {
                                            attribute = parseInt(what);
                                            what = parseInt(what);
                                         }
                                         else
                                         {
                                            if(how == \"text\")
                                            {
                                               attribute = element.textContent.replace(/\\xA0/g,' ').replace(/^\\s+|\\s+$/g, '').replace(/\\s+/g, ' ')
                                            }
                                            else
                                            {
                                               if(how == \"href\" || how == \"src\" || how == \"action\" || how == \"name\")
                                               {
                                                  attribute = element.getAttribute(how);
                                               }
                                               else
                                               {
                                                  if(eval(\"element.\"+how) != undefined)
                                                      attribute = eval(\"element.\"+how);
                                                  else
                                                      attribute = element.getAttribute(how);
                                               }
                                            }
                                            if(\"value\" == how && isButtonElement && (attribute == null || attribute == \"\"))
                                            {
                                               attribute = element.innerHTML;
                                            }
                                         }
                                         if(attribute == \"\") o = 'NoMethodError';
                                         var found = false;
                                         if (typeof what == \"object\" || typeof what == \"function\")
  			               {
                                            var regExp = new RegExp(what);
                                            found = regExp.test(attribute);
                                         }
                                         else
                                         {
                                            found = (attribute == what);
                                         }"

      if(@container.class == FireWatir::Firefox || @container.class == Frame)
        jssh_command << "   if(found)
                                      {
                                          if(value)
                                          {
                                              if(element.value == value || (value.test && value.test(element.value)))
                                              {
                                                  o = element;
                                                  element_name = \"elements_#{tag}[\" + i + \"]\";
                                              }
                                              else
                                                break;
                                          }
                                          else
                                          {
                                              o = element;
                                              element_name = \"elements_#{tag}[\" + i + \"]\";
                                          }
                                      }"
      else
        jssh_command << "   if(found)
                                      {
                                          if(value)
                                          {
                                              if(element.value == value || (value.test && value.test(element.value)))
                                              {
                                                  o = element;
                                                  element_name = \"elements_#{@@current_level}_#{tag}[\" + i + \"]\";
                                              }
                                              else
                                                break;
                                          }
                                          else
                                          {
                                              o = element;
                                              element_name = \"elements_#{@@current_level}_#{tag}[\" + i + \"]\";
                                          }
                                      }"
      end

      jssh_command << "
                                      else {
                                          o = null;
                                          element_name = \"\";
                                          break;
                                      }
                                   }
                                   if(element_name != \"\")
                                   {
                                     if(target_index == object_index)
                                     {
                                       break;
                                     }
                                     else if(target_index < object_index)
                                     {
                                       element_name = \"\";
                                       o = null;
                                       break;
                                     }
                                     else
                                     {
                                       object_index += 1;
                                       element_name = \"\";
                                       o = null;
                                     }
                                   }
                                 }
                               }
                              element_name;"

      # Remove \n that are there in the string as a result of pressing enter while formatting.
      jssh_command.gsub!(/\n/, "")
      #puts jssh_command
      #out = File.new("c:\\result.log", "w")
      #out << jssh_command
      #out.close
      jssh_socket.send("#{jssh_command};\n", 0)
      element_name = read_socket();
      #puts "element name in find control is : #{element_name}"
      @@current_level = @@current_level + 1
      #puts @container
      #puts element_name
      if(element_name != "")
        return element_name #Element.new(element_name, @container)
      else
        return nil
      end
    end

    def rb_regexp_to_js(regexp)
      old_exp = regexp.to_s
      new_exp = regexp.inspect.sub(/\w*$/, '')
      flags = old_exp.slice(2, old_exp.index(':') - 2)

      for i in 0..flags.length do
        flag = flags[i, 1]
        if(flag == '-')
          break;
        else
          new_exp << flag
        end
      end

      new_exp
    end

    #
    # Description:
    #   Locates frame element. Logic for locating the frame is written in JavaScript so that we don't make small
    #   round trips to JSSh using socket. This is done to improve the performance for locating the element.
    #
    # Input:
    #   how - The attribute for locating the frame. You can use any attribute-value pair that uniquely identifies
    #         the frame on the page. If there are more than one frames that have identical attribute-value pair
    #         then first frame that is found while traversing the DOM will be returned.
    #   what - Value of the attribute specified by how
    #
    # Output:
    #   Nil if unable to locate frame, else return the Frame element.
    #
    # TODO/FIX: If multiple tabs are open on the current window, will count frames from every tab, not just the current tab.
    #
    def locate_frame(how, what)
      # Get all the frames the are there on the page.
      #puts "how is #{how} and what is #{what}"
      jssh_command = ""
      if(@container.class == FireWatir::Firefox)
        # In firefox 3 if you write Frame Name then it will not show anything. So we add .toString function to every element.
        jssh_command = "var frameset = #{@container.window_var}.frames;
                                  var elements_frames = new Array();
                                  for(var i = 0; i < frameset.length; i++)
                                  {
                                      var frames = frameset[i].frames;
                                      for(var j = 0; j < frames.length; j++)
                                      {
                                          frames[j].frameElement.toString = function() { return '[object HTMLFrameElement]'; };
                                          elements_frames.push(frames[j].frameElement);

                                      }
                                  }"
      else
        jssh_command = "var frames = #{@container.element_name}.contentWindow.frames;
                                  var elements_frames_#{@@current_level} = new Array();
                                  for(var i = 0; i < frames.length; i++)
                                  {
                                      elements_frames_#{@@current_level}.push(frames[i].frameElement);
                                  }"
      end

      jssh_command << "    var element_name = ''; var object_index = 1;var attribute = '';
                                  var element = '';"
      if(@container.class == FireWatir::Firefox)
        jssh_command << "for(var i = 0; i < elements_frames.length; i++)
                                   {
                                      element = elements_frames[i];"
      else
        jssh_command << "for(var i = 0; i < elements_frames_#{@@current_level}.length; i++)
                                   {
                                      element = elements_frames_#{@@current_level}[i];"
      end
      jssh_command << "       if(\"index\" == \"#{how}\")
                                      {
                                          attribute = object_index; object_index += 1;
                                      }
                                      else
                                      {
                                          attribute = element.getAttribute(\"#{how}\");
                                          if(attribute == \"\" || attribute == null)
                                          {
                                              attribute = element.#{how};
                                          }
                                      }
                                      var found = false;"
      if(what.class == Regexp)
        oldRegExp = what.to_s
        newRegExp = "/" + what.source + "/"
        flags = oldRegExp.slice(2, oldRegExp.index(':') - 2)

        for i in 0..flags.length do
          flag = flags[i, 1]
          if(flag == '-')
            break;
          else
            newRegExp << flag
          end
        end
        #puts "old reg ex is #{what} new reg ex is #{newRegExp}"
        jssh_command << "   var regExp = new RegExp(#{newRegExp});
                                      found = regExp.test(attribute);"
      elsif(how == :index)
        jssh_command << "   found = (attribute == #{what});"
      else
        jssh_command << "   found = (attribute == \"#{what}\");"
      end

      jssh_command <<     "   if(found)
                                      {"
      if(@container.class == FireWatir::Firefox)
        jssh_command << "       element_name = \"elements_frames[\" + i + \"]\";
                                          #{@container.document_var} = elements_frames[i].contentDocument;
                                          #{@container.body_var} = #{@container.document_var}.body;"
      else
        jssh_command << "       element_name = \"elements_frames_#{@@current_level}[\" + i + \"]\";
                                          #{@container.document_var} = elements_frames_#{@@current_level}[i].contentDocument;
                                          #{@container.body_var} = #{@container.document_var}.body;"
      end
      jssh_command << "           break;
                                      }
                                  }
                                  element_name;"

      jssh_command.gsub!("\n", "")
      #puts "jssh_command for finding frame is : #{jssh_command}"

      jssh_socket.send("#{jssh_command};\n", 0)
      element_name = read_socket()
      @@current_level = @@current_level + 1
      #puts "element_name for frame is : #{element_name}"

      if(element_name != "")
        return element_name
      else
        return nil
      end
    end

    def get_frame_html
      jssh_socket.send("var htmlelem = #{@container.document_var}.getElementsByTagName('html')[0]; htmlelem.innerHTML;\n", 0)
      #jssh_socket.send("body.innerHTML;\n", 0)
      result = read_socket()
      return "<html>" + result + "</html>"
    end

    def submit_form
      #puts "form name is : #{element_object}"
      jssh_socket.send("#{element_object}.submit();\n" , 0)
      read_socket()
    end

    public

    #
    #
    # Description:
    #   Matches the given text with the current text shown in the browser for that particular element.
    #
    # Input:
    #   target - Text to match. Can be a string or regex
    #
    # Output:
    #   Returns the index if the specified text was found.
    #   Returns matchdata object if the specified regexp was found.
    #
    def contains_text(target)
      #puts "Text to match is : #{match_text}"
      #puts "Html is : #{self.text}"
      if target.kind_of? Regexp
        self.text.match(target)
      elsif target.kind_of? String
        self.text.index(target)
      else
        raise TypeError, "Argument #{target} should be a string or regexp."
      end
    end


    def inspect
      '#<%s:0x%x located=%s how=%s what=%s>' % [self.class, hash*2, !!@o, @how.inspect, @what.inspect]
    end

    #
    # Description:
    #   Returns array of elements that matches a given XPath query.
    #   Mozilla browser directly supports XPath query on its DOM. So no need to create the DOM tree as WATiR does for IE.
    #   Refer: http://developer.mozilla.org/en/docs/DOM:document.evaluate
    #   Used internally by Firewatir use ff.elements_by_xpath instead.
    #
    # Input:
    #   xpath - The xpath expression or query.
    #
    # Output:
    #   Array of elements that matched the xpath expression provided as parameter.
    #
    def elements_by_xpath(container, xpath)
      rand_no = rand(1000)
      #jssh_command = "var xpathResult = document.evaluate(\"count(#{xpath})\", document, null, #{NUMBER_TYPE}, null); xpathResult.numberValue;"
      #jssh_socket.send("#{jssh_command}\n", 0);
      #node_count = read_socket()
      xpath.gsub!("\"", "\\\"")
      jssh_command = "var element_xpath_#{rand_no} = new Array();"

      jssh_command << "var result = #{@container.document_var}.evaluate(\"#{xpath}\", #{@container.document_var}, null, #{ORDERED_NODE_ITERATOR_TYPE}, null);
                               var iterate = result.iterateNext();
                               while(iterate)
                               {
                                  element_xpath_#{rand_no}.push(iterate);
                                  iterate = result.iterateNext();
                               }
                               element_xpath_#{rand_no}.length;
                               "

      # Remove \n that are there in the string as a result of pressing enter while formatting.
      jssh_command.gsub!(/\n/, "")
      #puts jssh_command
      jssh_socket.send("#{jssh_command};\n", 0)
      node_count = read_socket()
      #puts "value of count is : #{node_count}"

      elements = Array.new(node_count.to_i)

      for i in 0..elements.length - 1 do
        elements[i] = "element_xpath_#{rand_no}[#{i}]"
      end

      return elements;
    end

    #
    # Description:
    #   Returns first element found while traversing the DOM; that matches an given XPath query.
    #   Mozilla browser directly supports XPath query on its DOM. So no need to create the DOM tree as WATiR does for IE.
    #   Refer: http://developer.mozilla.org/en/docs/DOM:document.evaluate
    #   Used internally by Firewatir use ff.element_by_xpath instead.
    #
    # Input:
    #   xpath - The xpath expression or query.
    #
    # Output:
    #   First element in DOM that matched the XPath expression or query.
    #
    def element_by_xpath(container, xpath)
      #puts "here locating element by xpath"
      rand_no = rand(1000)
      xpath.gsub!("\"", "\\\"")
      jssh_command = "var element_xpath_#{rand_no} = null; element_xpath_#{rand_no} = #{@container.document_var}.evaluate(\"#{xpath}\", #{container.document_var}, null, #{FIRST_ORDERED_NODE_TYPE}, null).singleNodeValue; element_xpath_#{rand_no};"

      jssh_socket.send("#{jssh_command}\n", 0)
      result = read_socket()
      #puts "command send to jssh is : #{jssh_command}"
      #puts "result is : #{result}"
      if(result == "null" || result == "" || result.include?("exception"))
        @@current_level = 0
        return nil
      else
        @@current_level += 1
        return "element_xpath_#{rand_no}"
      end
    end

    #
    # Description:
    #   Returns the name of the element with which we can access it in JSSh.
    #   Used internally by Firewatir to execute methods, set properties or return property value for the element.
    #
    # Output:
    #   Name of the variable with which element is referenced in JSSh
    #
    def element_object
      #puts caller.join("\n")
      #puts "In element_object element name is : #{@element_name}"
      #puts "in element_object : #{@container.class}"
      #if(@container.class == FireWatir::Firefox)
      return @element_name #if @element_name != nil
      #else
      #    return @container.element_name
      #end
      #return @o.element_name if @o != nil
    end
    private :element_object

    #
    # Description:
    #   Returns the type of element. For e.g.: HTMLAnchorElement. used internally by Firewatir
    #
    # Output:
    #   Type of the element.
    #
    def element_type
      #puts "in element_type object is : #{element_object}"
      # Get the type of the element.
      jssh_socket.send("#{element_object};\n", 0)
      temp = read_socket()

      #puts "#{element_object} and type is #{temp}"
      temp =~ /\[object\s(.*)\]/
      if $1
        return $1
      else
        # This is done because in JSSh if you write element name of anchor type
        # then it displays the link to which it navigates instead of displaying
        # object type. So above regex match will return nil
        return "HTMLAnchorElement"
      end
    end
    #private :element_type

    #
    # Description:
    #   Fires the provided event for an element and by default waits for the action to get completed.
    #
    # Input:
    #   event - Event to be fired like "onclick", "onchange" etc.
    #   wait - Whether to wait for the action to get completed or not. By default its true.
    #
    # TODO: Provide ability to specify event parameters like keycode for key events, and click screen
    #       coordinates for mouse events.
    def fire_event(event, wait = true)
      assert_exists()
      event = event.to_s # in case event was given as a symbol

      event = event.downcase

      event =~ /on(.*)/i
      event = $1 if $1

      # check if we've got an old-school on-event
      #jssh_socket.send("typeof(#{element_object}.#{event});\n", 0)
      #is_defined = read_socket()

      # info about event types harvested from:
      #   http://www.howtocreate.co.uk/tutorials/javascript/domevents
      case event
        when 'abort', 'blur', 'change', 'error', 'focus', 'load', 'reset', 'resize',
                      'scroll', 'select', 'submit', 'unload'
        dom_event_type = 'HTMLEvents'
        dom_event_init = "initEvent(\"#{event}\", true, true)"
        when 'keydown', 'keypress', 'keyup'
        dom_event_type = 'KeyEvents'
        # Firefox has a proprietary initializer for keydown/keypress/keyup.
        # Args are as follows:
        #   'type', bubbles, cancelable, windowObject, ctrlKey, altKey, shiftKey, metaKey, keyCode, charCode
        dom_event_init = "initKeyEvent(\"#{event}\", true, true, #{@container.window_var}, false, false, false, false, 0, 0)"
        when 'click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover',
                      'mouseup'
        dom_event_type = 'MouseEvents'
        # Args are as follows:
        #   'type', bubbles, cancelable, windowObject, detail, screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey, metaKey, button, relatedTarget
        dom_event_init = "initMouseEvent(\"#{event}\", true, true, #{@container.window_var}, 1, 0, 0, 0, 0, false, false, false, false, 0, null)"
      else
        dom_event_type = 'HTMLEvents'
        dom_event_init = "initEvents(\"#{event}\", true, true)"
      end

      if(element_type == "HTMLSelectElement")
        dom_event_type = 'HTMLEvents'
        dom_event_init = "initEvent(\"#{event}\", true, true)"
      end


      jssh_command  = "var event = #{@container.document_var}.createEvent(\"#{dom_event_type}\"); "
      jssh_command << "event.#{dom_event_init}; "
      jssh_command << "#{element_object}.dispatchEvent(event);"

      #puts "JSSH COMMAND:\n#{jssh_command}\n"

      jssh_socket.send("#{jssh_command}\n", 0)
      read_socket() if wait
      wait() if wait

      @@current_level = 0
    end
    alias fireEvent fire_event

    #
    # Description:
    #   Returns the value of the specified attribute of an element.
    #
    def attribute_value(attribute_name)
      #puts attribute_name
      assert_exists()
      return_value = get_attribute_value(attribute_name)
      @@current_level = 0
      return return_value
    end

    #
    # Description:
    #   Checks if element exists or not. Raises UnknownObjectException if element doesn't exists.
    #
    def assert_exists
      unless exists?
        raise UnknownObjectException.new(
                                         Watir::Exception.message_for_unable_to_locate(@how, @what))
      end
    end

    #
    # Description:
    #   Checks if element is enabled or not. Raises ObjectDisabledException if object is disabled and
    #   you are trying to use the object.
    #
    def assert_enabled
      unless enabled?
        raise ObjectDisabledException, "object #{@how} and #{@what} is disabled"
      end
    end

    #
    # Description:
    #   First checks if element exists or not. Then checks if element is enabled or not.
    #
    # Output:
    #   Returns true if element exists and is enabled, else returns false.
    #
    def enabled?
      assert_exists
      value = js_eval_method "disabled"
      @@current_level = 0
      return true if(value == "false")
      return false if(value == "true")
      return value
    end

    #
    # Description:
    #   Checks element for display: none or visibility: hidden, these are
    #   the most common methods to hide an html element

    def visible?
      assert_exists
      val = js_eval "var val = 'true'; var str = ''; var obj = #{element_object}; while (obj != null) { try { str = #{@container.document_var}.defaultView.getComputedStyle(obj,null).visibility; if (str=='hidden') { val = 'false'; break; } str = #{@container.document_var}.defaultView.getComputedStyle(obj,null).display; if (str=='none') { val = 'false'; break; } } catch(err) {} obj = obj.parentNode; } val;"
      return (val == 'false')? false: true
    end


    #
    # Description:
    #   Checks if element exists or not. If element is not located yet then first locates the element.
    #
    # Output:
    #   True if element exists, false otherwise.
    #
    def exists?
      # puts "element is : #{element_object}"
      # puts caller(0)
      # If elements array has changed locate the element again. So that the element name points to correct element.
      if(element_object == nil || element_object == "")
        @@current_level = 0
        #puts "locating element"
        locate if respond_to?(:locate)
        if(@element_name == nil || @element_name == "")
          return false
        else
          #puts caller(0)
          #puts "element name is : #{@element_name}"
          return true
        end
      else
        #puts "not locating the element again"
        return true
      end
      #@@current_level = 0
      #if(element_object == nil || element_object == "")
      #    return false
      #else
      #    return true
      #end
    rescue UnknownFrameException
      false
    end
    alias exist? exists?

    #
    # Description:
    #   Returns the text of the element.
    #
    # Output:
    #   Text of the element.
    #
    def text()
      assert_exists
      element = (element_type == "HTMLFrameElement") ? "body" : element_object
      return_value = js_eval("#{element}.textContent.replace(/\\xA0/g, ' ').replace(/\\s+/g, ' ')").strip
      @@current_level = 0
      return return_value
    end
    alias innerText text

    # Returns the name of the element (as defined in html)
    def_wrap :name
    # Returns the id of the element
    def_wrap :id
    # Returns whether the element is disabled
    def disabled
      ! enabled?
    end
    alias disabled? disabled
    # Returns the state of the element
    def_wrap :checked
    # Returns the value of the element
    def_wrap :value
    # Returns the title of the element
    def_wrap :title
    # Returns the value of 'alt' attribute in case of Image element.
    def_wrap :alt
    # Returns the value of 'href' attribute in case of Anchor element.
    def_wrap :src
    # Returns the type of the element. Use in case of Input element only.
    def_wrap :type
    # Returns the url the Anchor element points to.
    def_wrap :href
    # Return the ID of the control that this label is associated with
    def_wrap :for, :htmlFor
    # Returns the class name of the element
    def_wrap :class_name, :className
    # Return the html of the object
    def_wrap :html, :innerHTML
    # Return the action of form
    def_wrap :action

    #
    # Description:
    #   Display basic details about the object. Sample output for a button is shown.
    #   Raises UnknownObjectException if the object is not found.
    #      name      b4
    #      type      button
    #      id         b5
    #      value      Disabled Button
    #      disabled   true
    #
    # Output:
    #   Array with value of properties shown above.
    #
    def to_s(attributes=nil)
      #puts "here in to_s"
      #puts caller(0)
      assert_exists
      if(element_type == "HTMLTableCellElement")
        return text()
      else
        result = string_creator(attributes).join("\n")
        @@current_level = 0
        return result
      end
    end

    #
    # Description:
    #   Function to fire click event on elements.
    #
    def click
      assert_exists
      assert_enabled

      highlight(:set)
      #puts "#{element_object} and #{element_type}"
      case element_type

        when "HTMLAnchorElement", "HTMLImageElement"
        # Special check for link or anchor tag. Because click() doesn't work on links.
        # More info: http://www.w3.org/TR/DOM-Level-2-HTML/html.html#ID-48250443
        # https://bugzilla.mozilla.org/show_bug.cgi?id=148585

        jssh_command = "var event = #{@container.document_var}.createEvent(\"MouseEvents\");"

        # Info about initMouseEvent at: http://www.xulplanet.com/references/objref/MouseEvent.html
        jssh_command << "event.initMouseEvent('click',true,true,null,1,0,0,0,0,false,false,false,false,0,null);"
        jssh_command << "#{element_object}.dispatchEvent(event);\n"

        #puts "jssh_command is: #{jssh_command}"
        jssh_socket.send("#{jssh_command}", 0)
        read_socket()
      else
        jssh_socket.send("typeof(#{element_object}.click);\n", 0)
        isDefined = read_socket()
        if(isDefined == "undefined")
          fire_event("onclick")
        else
          jssh_socket.send("#{element_object}.click();\n" , 0)
          read_socket()
        end
      end
      highlight(:clear)
      # Wait for firefox to reload.
      wait()
    end

    #
    # Description:
    #   Document var.  Unfinished.
    #
    def document_var
      "document"
    end

    #
    # Description:
    #   Wait for the browser to get loaded, after the event is being fired.
    #
    def wait
      #ff = FireWatir::Firefox.new
      #ff.wait()
      #puts @container
      @container.wait()
      @@current_level = 0
    end

    #
    # Description:
    #   Function is used for click events that generates javascript pop up.
    #   Doesn't fire the click event immediately instead, it stores the state of the object. User then tells which button
    #   is to be clicked in case a javascript pop up comes after clicking the element. Depending upon the button to be clicked
    #   the functions 'alert' and 'confirm' are re-defined in JavaScript to return appropriate values either true or false. Then the
    #   re-defined functions are send to jssh which then fires the click event of the element using the state
    #   stored above. So the click event is fired in the second statement. Therefore, if you are using this function you
    #   need to call 'click_js_popup_button()' function in the next statement to actually trigger the click event.
    #
    #   Typical Usage:
    #       ff.button(:id, "button").click_no_wait()
    #       ff.click_js_popup_button("OK")
    #
    #def click_no_wait
    #    assert_exists
    #    assert_enabled
    #
    #    highlight(:set)
    #    @@current_js_object = Element.new("#{element_object}", @container)
    #end

    #
    # Description:
    #   Function to click specified button on the javascript pop up. Currently you can only click
    #   either OK or Cancel button.
    #   Functions alert and confirm are redefined so that it doesn't causes the JSSH to get blocked. Also this
    #   will make Firewatir cross platform.
    #
    # Input:
    #   button to be clicked
    #
    #def click_js_popup(button = "OK")
    #    jssh_command = "var win = browser.contentWindow;"
    #    if(button =~ /ok/i)
    #        jssh_command << "var popuptext = '';win.alert = function(param) {popuptext = param; return true; };
    #                         win.confirm = function(param) {popuptext = param; return true; };"
    #    elsif(button =~ /cancel/i)
    #        jssh_command << "var popuptext = '';win.alert = function(param) {popuptext = param; return false; };
    #                         win.confirm = function(param) {popuptext = param; return false; };"
    #    end
    #    jssh_command.gsub!(/\n/, "")
    #    jssh_socket.send("#{jssh_command}\n", 0)
    #    read_socket()
    #    click_js_popup_creator_button()
    #    #jssh_socket.send("popuptext_alert;\n", 0)
    #    #read_socket()
    #    jssh_socket.send("\n", 0)
    #    read_socket()
    #end

    #
    # Description:
    #   Clicks on button or link or any element that triggers a javascript pop up.
    #   Used internally by function click_js_popup.
    #
    #def click_js_popup_creator_button
    #    #puts @@current_js_object.element_name
    #    jssh_socket.send("#{@@current_js_object.element_name}\n;", 0)
    #    temp = read_socket()
    #    temp =~ /\[object\s(.*)\]/
    #    if $1
    #        type = $1
    #    else
    #        # This is done because in JSSh if you write element name of anchor type
    #        # then it displays the link to which it navigates instead of displaying
    #        # object type. So above regex match will return nil
    #        type = "HTMLAnchorElement"
    #    end
    #    #puts type
    #    case type
    #        when "HTMLAnchorElement", "HTMLImageElement"
    #            jssh_command = "var event = document.createEvent(\"MouseEvents\");"
    #            # Info about initMouseEvent at: http://www.xulplanet.com/references/objref/MouseEvent.html
    #            jssh_command << "event.initMouseEvent('click',true,true,null,1,0,0,0,0,false,false,false,false,0,null);"
    #            jssh_command << "#{@@current_js_object.element_name}.dispatchEvent(event);\n"
    #
    #            jssh_socket.send("#{jssh_command}", 0)
    #            read_socket()
    #        when "HTMLDivElement", "HTMLSpanElement"
    #             jssh_socket.send("typeof(#{element_object}.#{event.downcase});\n", 0)
    #             isDefined = read_socket()
    #             #puts "is method there : #{isDefined}"
    #             if(isDefined != "undefined")
    #                 if(element_type == "HTMLSelectElement")
    #                     jssh_command = "var event = document.createEvent(\"HTMLEvents\");
    #                                     event.initEvent(\"click\", true, true);
    #                                     #{element_object}.dispatchEvent(event);"
    #                     jssh_command.gsub!(/\n/, "")
    #                     jssh_socket.send("#{jssh_command}\n", 0)
    #                     read_socket()
    #                 else
    #                     jssh_socket.send("#{element_object}.#{event.downcase}();\n", 0)
    #                     read_socket()
    #                 end
    #             end
    #        else
    #            jssh_command = "#{@@current_js_object.element_name}.click();\n";
    #            jssh_socket.send("#{jssh_command}", 0)
    #            read_socket()
    #    end
    #    @@current_level = 0
    #    @@current_js_object = nil
    #end
    #private :click_js_popup_creator_button

    #
    # Description:
    #   Gets all the cells of the row of a table.
    #
    # Output:
    #   Array of table cell elements.
    #
    def get_cells
      assert_exists
      #puts "element name in cells is : #{element_object}"
      if(element_type == "HTMLTableRowElement")
        jssh_socket.send("#{element_object}.cells.length;\n", 0)
        length = read_socket.to_i
        return_array = Array.new(length)
        for i in 0..length - 1 do
          return_array[i] = "#{element_object}.cells[#{i}]"
        end
        return return_array
      else
        puts "The element must be of table row type to execute this function."
        return nil
      end
    end
    private :get_cells

    #
    # Description:
    #   Traps all the function calls for an element that is not defined and fires them again
    #   as it is to the jssh. This can be used in case the element supports properties or methods
    #   that are not defined in the corresponding element class or in the base class(Element).
    #
    # Input:
    #   methodId - Id of the method that is called.
    #   *args - arguments sent to the methods.
    #
    def method_missing(methId, *args)
      methodName = methId.id2name
      #puts "method name is : #{methodName}"
      assert_exists
      #assert_enabled
      methodName = "colSpan" if methodName == "colspan"
      if(methodName =~ /invoke/)
        jssh_command = "#{element_object}."
        for i in args do
          jssh_command << i;
        end
        #puts "#{jssh_command}"
        jssh_socket.send("#{jssh_command};\n", 0)
        return_value = read_socket()
        #puts "return value is : #{return_value}"
        return return_value
      else
        #assert_exists
        #puts "element name is #{element_object}"

        # We get method name with trailing '=' when we try to assign a value to a
        # property. So just remove the '=' to get the type
        temp = ""
        assigning_value = false
        if(methodName =~ /(.*)=$/)
          temp  = "#{element_object}.#{$1}"
          assigning_value = true
        else
          temp = "#{element_object}.#{methodName}"
        end
        #puts "temp is : #{temp}"

        jssh_socket.send("typeof(#{temp});\n", 0)
        method_type = read_socket()
        #puts "method_type is : #{method_type}"

        if(assigning_value)
          if(method_type != "boolean" && args[0].class != Fixnum)
            args[0].gsub!("\\", "\\"*4)
            args[0].gsub!("\"", "\\\"")
            args[0].gsub!("\n","\\n")

            if (args[0].class == String)
              args[0] = args[0].to_json(:ascii_only => 1)
              args[0] = args[0][1, args[0].length - 2]
            end

            jssh_command = "#{element_object}.#{methodName}\"#{args[0]}\""
          else
            jssh_command = "#{element_object}.#{methodName}#{args[0]}"
          end
          #puts "jssh_command is : #{jssh_command}"
          jssh_socket.send("#{jssh_command};\n", 0)
          read_socket()
          return
        end

        methodName = "#{element_object}.#{methodName}"
        if(args.length == 0)
          #puts "In if loop #{methodName}"
          if(method_type == "function")
            jssh_command =  "#{methodName}();\n"
          else
            jssh_command =  "#{methodName};\n"
          end
        else
          #puts "In else loop : #{methodName}"
          jssh_command =  "#{methodName}("

          count = 0
          if args != nil
            for i in args
              jssh_command << "," if count != 0
              if i.kind_of? Numeric
                jssh_command << i.to_s
              else
                jssh_command << "\"#{i.to_s.gsub(/"/,"\\\"")}\""
              end
              count = count + 1
            end
          end

          jssh_command << ");\n"
        end

        if(method_type == "boolean")
          jssh_command = jssh_command.gsub("\"false\"", "false")
          jssh_command = jssh_command.gsub("\"true\"", "true")
        end
        #puts "jssh_command is #{jssh_command}"
        jssh_socket.send("#{jssh_command}", 0)
        returnValue = read_socket()
        #puts "return value is : #{returnValue}"

        @@current_level = 0

        if(method_type == "boolean")
          return false if(returnValue == "false")
          return true if(returnValue == "true")
        elsif(method_type == "number")
          return returnValue.to_i
        else
          return returnValue
        end
      end
    end

  end # Element
end # FireWatir

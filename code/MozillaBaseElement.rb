=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2005-2006, Angrez Singh, Abhishek Goliya
  Persistent Systems Pvt. Ltd.
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Angrez Singh, Abhishek Goliya nor the names of contributors to
  this software may be used to endorse or promote products derived from this
  software without specific prior written permission.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  --------------------------------------------------------------------------
  (based on BSD Open Source License)
=end

# Base class for html elements.
# This is not a class that users would normally access.
    class Element
        
        include Container
        # Number of spaces that separate the property from the value in the to_s method
        TO_S_SIZE = 14

        # XPath Result type. Return only first node that matches the xpath expression.
        # More details: "http://developer.mozilla.org/en/docs/DOM:document.evaluate"
        FIRST_ORDERED_NODE_TYPE = 9
        
        attr_accessor :element_name
        attr_accessor :element_type
        def initialize(element)
            
            if(element != nil && element.class == String)
                @element_name = element
                # Get the type of the element.
                $jssh_socket.send("#{element}; \n", 0)
                temp = read_socket()
                temp =~ /\[object\s(.*)\]/
                if $1
                    @element_type = $1
                else
                    # This is done because in JSSh if you right element name of anchor type
                    # then it displays the link to which it navigates. So above regex match
                    # will return nil
                    @element_type = "HTMLAnchorElement"
                end
            elsif(element != nil && element.class == Element)
                @o = element
            end
            
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
                        # array with element_name as index to send command to jssh.
                        $jssh_socket.send('typeof(' + element_object + '.#{ole_method_name});\n', 0)
                        returnType = read_socket()
                        $jssh_socket.send('' + element_object + '.#{ole_method_name};\n', 0)
                        returnValue = read_socket()
                        
                        if(returnType == \"boolean\")
                            return false if returnValue == \"false\"
                            return true if returnValue == \"true\"
                        end
                        return returnValue
                    end"
        end
        
        def text
        end
        
        def self.def_wrap_guard(method_name)
            class_eval "def #{method_name}
                        assert_exists
                        # Every element has its name starting from element. If yes then
                        # use element_name to send the command to jssh. Else its a number
                        # and we are still searching for element, in this case use doc.all
                        # array with element_name as index to send command to jssh.
                        begin
                            element_object.to_s
                            $jssh_socket.send('' + element_object + '.#{method_name};\n', 0)
                            read_socket()
                        rescue
                            ''
                        end
                    end"
        end
        
        # Return an array with many of the properties, in a format to be used by the to_s method
        def string_creator
            n = []
            n <<   "name:".ljust(TO_S_SIZE) +       self.name.to_s
            n <<   "type:".ljust(TO_S_SIZE) + self.type
            n <<   "id:".ljust(TO_S_SIZE) +         self.id.to_s
            n <<   "value:".ljust(TO_S_SIZE) +      self.value.to_s
            n <<   "disabled:".ljust(TO_S_SIZE) +   self.disabled.to_s
            return n
        end
        
        # This method is responsible for setting and clearing the colored highlighting on the currently active element.
        # use :set   to set the highlight
        #   :clear  to clear the highlight
        def highlight(set_or_clear)
            if set_or_clear == :set
                #puts "element_name is : #{element_object}"
                $jssh_socket.send("#{element_object}.style.background; \n", 0)
                @original_color = read_socket()
                
                # TODO: Need to change this so that it would work if user sets any other color.
                #puts "color is : #{DEFAULT_HIGHLIGHT_COLOR}"
                $jssh_socket.send("#{element_object}.style.background = \"#{DEFAULT_HIGHLIGHT_COLOR}\"; \n", 0)
                read_socket()
                
            else # BUG: assumes is :clear, but could actually be anything
                begin 
                    $jssh_socket.send("#{element_object}.style.background = \"#{@original_color}\"; \n", 0)
                    read_socket()
                rescue
                    # we could be here for a number of reasons...
                    # e.g. page may have reloaded and the reference is no longer valid
                ensure
                    @original_color = nil
                end
            end
        end
        
        
        public
        
        # This function returns the name of the element with which we can access it in JSSh.
        def element_object
            return @o.element_name if @o != nil
            return @element_name
        end
        
        # This function returns the type of element. For e.g.: HTMLAnchorElement
        def element_type
            return @o.element_type if @o != nil
            return @element_type
        end
        
        # This function returns all the elements that are there in the page document.
        def all
            #puts "Element name in all : #{element_object}"
            if(element_object == BODY_VAR)
                $jssh_socket.send("var elements = #{element_object}.ownerDocument.getElementsByTagName('*'); elements.length;\n", 0)
                length = read_socket().to_i
                
                # Make use of correct document while getting the elements.
                $jssh_socket.send("doc = #{element_object}.ownerDocument; \n", 0);
                read_socket();
                #puts "length returned by JSSh is : #{length}"
                # Return a array of numbers equal to length.
                returnArray = Array.new
                for i in 0..length-1
                    returnArray.push(Element.new("elements[#{i}]"))
                end
                returnArray
            end
        end
        
        # This function fires event on an element.
        def fireEvent(event)
            #puts "here in fire event function. Event is : #{event}"
            #puts "typeof(#{element_object}.#{event.downcase}); \n"
            $jssh_socket.send("typeof(#{element_object}.#{event.downcase}); \n", 0)
            isDefined = read_socket()
            #puts "is method there : #{isDefined}"
            if(isDefined != "undefined")
                $jssh_socket.send("#{element_object}.#{event.downcase}(); \n", 0)
                read_socket()
            end
        end
        
        # This function returns the value of any attribute of an element.
        def attribute_value(attribute_name)
            #puts attribute_name
            assert_exists()
            $jssh_socket.send("#{element_object}.getAttribute(\"#{attribute_name}\");\n" , 0)
            return read_socket()
        end
        
        # This function checks if element exists or not.
        def assert_exists
            unless exists?
                raise UnknownObjectException.new("Unable to locate object, using #{@how} and #{@what}")
            end
        end
        
        # This function checks if element is enabled or not.
        def assert_enabled
            unless enabled?
                raise ObjectDisabledException, "object #{@how} and #{@what} is disabled"
            end                
        end
        
        def enabled?
            assert_exists
            $jssh_socket.send("#{element_object}.disabled; \n", 0)
            value = read_socket()
            return true if(value == "false") 
            return false if(value == "true") 
            
            return value
        end
        
        def exists?
            locate if defined?(locate)
            #puts "element is : #{element_object}"
            unless element_object
                return false
            end
            return true
        end
        
       
        # returns the name of the element (as defined in html)
        def_wrap_guard :name
        # returns the id of the element
        def_wrap_guard :id
        # returns whether the element is disabled
        def_wrap :disabled 
        alias disabled? disabled
        # returns the value of the element
        def_wrap_guard :value
        # returns the title of the element
        def_wrap_guard :title
        
        def_wrap_guard :alt
        def_wrap_guard :src
        
        # returns the type of the element
        def_wrap_guard :type # input elements only        

        # returns the url the link points to
        def_wrap :href # link only

        # return the ID of the control that this label is associated with
        def_wrap :for, :htmlFor # label only
        
        # returns the class name of the element
        # raises an ObjectNotFound exception if the object cannot be found
        def_wrap :class_name, :className

        # Return the outer html of the object - see http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/outerhtml.asp?frame=true
        def_wrap :html, :outerHTML
        
        #return the inner text of the object
        def_wrap :text
        
        
        # Display basic details about the object. Sample output for a button is shown.
        # Raises UnknownObjectException if the object is not found.
        #      name      b4
        #      type      button
        #      id         b5
        #      value      Disabled Button
        #      disabled   true
        def to_s
            assert_exists
            return string_creator #.join("\n")
        end
        
        # Function to fire click events on elements.  
        def click
            assert_exists
            assert_enabled

            highlight(:set)
            # Special check for link or anchor tag. Because click() doesn't work on links.
            # More info: http://www.w3.org/TR/DOM-Level-2-HTML/html.html#ID-48250443
            # https://bugzilla.mozilla.org/show_bug.cgi?id=148585

            if(element_type == "HTMLAnchorElement")
                var jssh_command = "var event = #{DOCUMENT_VAR}.createEvent(\"MouseEvents\");"
                
                # Info about initMouseEvent at: http://www.xulplanet.com/references/objref/MouseEvent.html        
                jssh_command += "event.initMouseEvent('click',true,true,null,1,0,0,0,0,false,false,false,false,0,null);"
                jssh_command += "#{element_object}.dispatchEvent(event); \n"
                
                $jssh_socket.send("#{jssh_command}", 0)
                read_socket()
            elsif(element_type == "HTMLImageElement")
                fireEvent("onclick")
            else
                $jssh_socket.send("#{element_object}.click();\n" , 0)
                read_socket()
            end
            
            @container.wait() if @container
            highlight(:clear)
        end
        
        # Function that doesn't wait after clicking. Useful when click function opens a new
        # javascript pop up.
        def click_no_wait
            assert_exists
            assert_enabled

            highlight(:set)
            # Special check for link or anchor tag. Because click() doesn't work on links.
            # More info: http://www.w3.org/TR/DOM-Level-2-HTML/html.html#ID-48250443
            # https://bugzilla.mozilla.org/show_bug.cgi?id=148585

            if(element_type == "HTMLAnchorElement")
                var jssh_command = "var event = #{DOCUMENT_VAR}.createEvent(\"MouseEvents\");"
                
                # Info about initMouseEvent at: http://www.xulplanet.com/references/objref/MouseEvent.html        
                jssh_command += "event.initMouseEvent('click',true,true,null,1,0,0,0,0,false,false,false,false,0,null);"
                jssh_command += "#{element_object}.dispatchEvent(event); \n"
                
                $jssh_socket.send("#{jssh_command}", 0)
                #read_socket()
            elsif(element_type == "HTMLImageElement")
                fireEvent("onclick")
            else
                $jssh_socket.send("#{element_object}.click();\n" , 0)
                #read_socket()
            end
        end
        
        # Used by select list object. 
        def options
            #puts "#{element_object}"
            return Element.new("#{element_object}")
        end
        
        def [](key)
            #puts "#{element_object}"
            #puts "#{element_type}"
            if(element_type == "HTMLSelectElement")
                return Element.new("#{element_object}.options[#{key}]")
            end
        end
        
        # Function to click "Browser" button of HTMLInput file control.
        def clickFileFieldButton()
            jssh_command = "button = #{DOCUMENT_VAR}.getBoxObjectFor(#{element_object}).lastChild;"
            jssh_command += "button.click(); \n";
            
            #puts jssh_command
            $jssh_socket.send("#{jssh_command}", 0)
            read_socket()
            length = 0
            @container.set_browser_document()
            
            # Right now found only this way to wait till the File Upload dialog box is not
            # not closed.
            while length == 0
                $jssh_socket.send("elements = #{element_object}.ownerDocument.getElementsByTagName('*'); elements.length;\n", 0)
                length = read_socket().to_i
                #puts "length in click function is : #{length}"
            end
        end
        
        # This method will trap all the function calls for an element & fires them again 
        # through JSSh & element name.
	    def method_missing(methId, *args)
	        methodName = methId.id2name
	        #puts "method name is : #{methodName}"
	        
	        if(methodName =~ /invoke/)
	            jssh_command = "#{element_object}."
	            for i in args do
	                jssh_command += i;
	            end
	            $jssh_socket.send("#{jssh_command}; \n", 0)
	            read_socket()
	        else
	            assert_exists
	            #puts "element name is #{element_object}"
    	        
    	        # We get method name with trailing '=' when we try to assign a value to a 
    	        # property. So just remove the '=' to get the type 
	            methodName =~ /([^=]*)/
	            
	            temp  = "#{element_object}.#{$1}" 
	            #puts "#{temp}"
                
                $jssh_socket.send("typeof(#{temp}); \n", 0)
                method_type = read_socket()
                
                methodName = "#{element_object}.#{methodName}"
                
                if(args.length == 0)
                    #puts "In if loop #{methodName}"
                    if(method_type == "function")	        
	                    jssh_command =  "#{methodName}();\n"
	                else
	                    jssh_command =  "#{methodName}; \n"
	                end
	            else
	                #puts "In else loop : #{methodName}"
		            jssh_command =  "#{methodName}(" 

		            count = 0
		            if args != nil 
			            for i in args
			                jssh_command += "," if count != 0
				            if i.kind_of? Numeric  
				                jssh_command += i.to_s
				            else
					            jssh_command += "\"#{i.to_s.gsub(/"/,"\\\"")}\""
				            end
				            count += 1   
			            end 
		            end

		            jssh_command += ");\n"
	            end

                if(method_type == "boolean")
                    jssh_command = jssh_command.gsub("\"false\"", "false")
                    jssh_command = jssh_command.gsub("\"true\"", "true")
                end
                #puts "#{jssh_command}"
		        $jssh_socket.send("#{jssh_command}", 0)
		        returnValue = read_socket()
		        #puts "return value is : #{returnValue}"
		        
		        if(method_type == "boolean")
		            return false if(returnValue == "false")
		            return true if(returnValue == "true")
		        else
		            return returnValue
		        end
		    end
	    end
    end
    
    # Class for body element.
    class Body < Element
    end
    
    # Class for page document.
    class Document < Element
        def getElementsByTagName(tag)
            jssh_command = "var elements = #{DOCUMENT_VAR}.getElementsByTagName('#{tag}');"
            jssh_command += "elements.length;\n"
            
            $jssh_socket.send("#{jssh_command}", 0)
            length = read_socket().to_i
            
            #puts "JSSh command is : #{jssh_command}"
            #puts "Number of elements with #{tag} tag is : #{length}"
            # Return a array of numbers equal to length.
            returnArray = Array.new
            for i in 0..length - 1
                returnArray.push(Element.new("elements[#{i}]"))
            end
            returnArray
                
        end
        
        def body
            Body.new("#{BODY_VAR}")
        end
    end
    
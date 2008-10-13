=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2004 - 2005, Paul Rogers and Bret Pettichord
  Copyright (c) 2006 - 2007, Angrez Singh
  Copyright (c) 2008, Bret Pettichord
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Angrez Singh nor the names of contributors to
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

=begin rdoc
   This is FireWatir, Web Application Testing In Ruby using Firefox browser
   The home page for this project is http://code.google.com/p/firewatir

   Typical usage:
    # include the controller
    require "firewatir"

    # go to the page you want to test
    ff = FireWatir::Firefox.start("http://myserver/mypage")

    # enter "Angrez" into an input field named "username"
    ff.text_field(:name, "username").set("Angrez")

    # enter "Ruby Co" into input field with id "company_ID"
    ff.text_field(:id, "company_ID").set("Ruby Co")

    # click on a link that has "green" somewhere in the text that is displayed
    # to the user, using a regular expression
    ff.link(:text, /green/)

    # click button that has a caption of "Cancel"
    ff.button(:value, "Cancel").click

   FireWatir allows your script to read and interact with HTML objects--HTML tags
   and their attributes and contents.  Types of objects that FireWatir can identify
   include:

   Type         Description
   ===========  ===============================================================
   button       <input> tags, with the type="button" attribute
   check_box    <input> tags, with the type="checkbox" attribute
   div          <div> tags
   form
   frame
   hidden       hidden <input> tags
   image        <img> tags
   label
   link         <a> (anchor) tags
   p            <p> (paragraph) tags
   radio        radio buttons; <input> tags, with the type="radio" attribute
   select_list  <select> tags, known informally as drop-down boxes
   span         <span> tags
   table        <table> tags
   text_field   <input> tags with the type="text" attribute (a single-line
                text field), the type="text_area" attribute (a multi-line
                text field), and the type="password" attribute (a
                single-line field in which the input is replaced with asterisks)

   In general, there are several ways to identify a specific object.  FireWatir's
   syntax is in the form (how, what), where "how" is a means of identifying
   the object, and "what" is the specific string or regular expression
   that FireWatir will seek, as shown in the examples above.  Available "how"
   options depend upon the type of object, but here are a few examples:

   How           Description
   ============  ===============================================================
   :id           Used to find an object that has an "id=" attribute. Since each
                 id should be unique, according to the XHTML specification,
                 this is recommended as the most reliable method to find an
                 object.
   :name         Used to find an object that has a "name=" attribute.  This is
                 useful for older versions of HTML, but "name" is deprecated
                 in XHTML.
   :value        Used to find a text field with a given default value, or a
                 button with a given caption
   :index        Used to find the nth object of the specified type on a page.
                 For example, button(:index, 2) finds the second button.
                 Current versions of FireWatir use 1-based indexing, but future
                 versions will use 0-based indexing.
   :xpath	     The xpath expression for identifying the element.
   
   Note that the XHTML specification requires that tags and their attributes be
   in lower case.  FireWatir doesn't enforce this; FireWatir will find tags and
   attributes whether they're in upper, lower, or mixed case.  This is either
   a bug or a feature.

   FireWatir uses JSSh for interacting with the browser.  For further information on 
   Firefox and DOM go to the following Web page:

   http://www.xulplanet.com/references/objref/
   
=end

require 'firewatir/exceptions'
require 'container'
require 'MozillaBaseElement'
require 'htmlelements'
require 'socket'

require 'watir/matches'

module FireWatir
    include Watir::Exception
    
    class Firefox
       
        include FireWatir::Container
        
        # XPath Result type. Return only first node that matches the xpath expression.
        # More details: "http://developer.mozilla.org/en/docs/DOM:document.evaluate"
        FIRST_ORDERED_NODE_TYPE = 9
        
        VERSION = '1.1.1'

        # variable to check if firefox browser has been started or not. Currently this is
        # used only while starting firefox on windows. For other platforms you need to start
        # firefox manually.
        #@@firefox_started = false
        
        # Stack to hold windows.
        @@window_stack = Array.new
        
        # This allows us to identify the window uniquely and close them accordingly.
        @window_title = nil 
        @window_url = nil 

        
        #
        # Description: 
        #   Starts the firefox browser. Currently this only works for Windows Platform.
        #   For others, you need to start Firefox manually using -jssh option.
        #   On windows this starts the first version listed in the registry.
        # 
        # Input:
       	#   options  - Hash of any of the following options:
	    #     :waitTime - Time to wait for Firefox to start. By default it waits for 2 seconds.
        #                 This is done because if Firefox is not started and we try to connect
        #                 to jssh on port 9997 an exception is thrown.
        #     :profile  - The Firefox profile to use. If none is specified, Firefox will use
        #                 the last used profile. Note that the :profile option only works if
        #                 no other instances of Firefox are already running.

        # TODO: Start the firefox version given by user. For example 
        #       ff = FireWatir::Firefox.new("1.5.0.4")
        #
 
        def initialize(options = {})
			if(options.kind_of?(Integer))
                options = {:waitTime => options}
            end

            if(options[:profile])
                profile_opt = "-P #{options[:profile]}"
            else
                profile_opt = ""
            end

            waitTime = options[:waitTime] || 2

            if(RUBY_PLATFORM =~ /.*mswin.*/)
                # Get the path to Firefox.exe using Registry.
                require 'win32/registry.rb'
                path_to_exe = ""
                Win32::Registry::HKEY_LOCAL_MACHINE.open('SOFTWARE\Mozilla\Mozilla Firefox') do |reg|
                    keys = reg.keys
                    reg1 = Win32::Registry::HKEY_LOCAL_MACHINE.open("SOFTWARE\\Mozilla\\Mozilla Firefox\\#{keys[0]}\\Main")
                    reg1.each do |subkey, type, data|
                        if(subkey =~ /pathtoexe/i)
                            path_to_exe = data
                        end
                    end
                end

            @t = Thread.new { system("\"#{path_to_exe}\" -jssh #{profile_opt}") }
            elsif(RUBY_PLATFORM =~ /linux/i)
                path_to_bin = `which firefox`.strip
                @t = Thread.new { `#{path_to_bin} -jssh #{profile_opt}` }
            end     
            
            sleep waitTime
            
            set_defaults()
            get_window_number()
            set_browser_document()
        end

        #
        # Description:
        # Creates a new instance of Firefox. Loads the URL and return the instance.
        #
        # Input:
        #   url - url of the page to be loaded.
        #
        # Output:
        #   New instance of firefox browser with the given url loaded.
        #
        def self.start(url)
            ff = Firefox.new
            ff.goto(url)
            return ff
        end

        #
        # Description:
        #   Gets the window number opened. Used internally by Firewatir.
        #
        def get_window_number()
            $jssh_socket.send("getWindows().length;\n", 0)
            @@current_window = read_socket().to_i - 1
            
            # Derek Berner 5/16/08 
            # If at any time a non-browser window like the "Downloads" window 
            #   pops up, it will become the topmost window, so make sure we 
            #   ignore it.
            @@current_window = js_eval("getWindows().length").to_i - 1
            while js_eval("getWindows()[#{@@current_window}].getBrowser") == ''
                @@current_window -= 1;
            end

            # This will store the information about the window.
            #@@window_stack.push(@@current_window)
            #puts "here in get_window_number window number is #{@@current_window}"
            return @@current_window
        end
        private :get_window_number

        #
        # Description:
        #   Loads the given url in the browser. Waits for the page to get loaded.
        #
        # Input:
        #   url - url to be loaded.
        #
        def goto(url)
            #set_defaults()
            get_window_number()
            set_browser_document()
            # Load the given url.
            $jssh_socket.send("#{BROWSER_VAR}.loadURI(\"#{url}\");\n" , 0)
            read_socket()

            wait()
        end
        
        #
        # Description: 
        #   Loads the previous page (if there is any) in the browser. Waits for the page to get loaded.
        #
        def back()
            #set_browser_document()
            $jssh_socket.send("if(#{BROWSER_VAR}.canGoBack) #{BROWSER_VAR}.goBack();\n", 0)
            read_socket();
            wait()
        end

        #
        # Description:
        #   Loads the next page (if there is any) in the browser. Waits for the page to get loaded.
        #
        def forward()
            #set_browser_document()
            $jssh_socket.send("if(#{BROWSER_VAR}.canGoForward) #{BROWSER_VAR}.goForward();\n", 0)
            read_socket();
            wait()
        end
        
        #
        # Description:
        #   Reloads the current page in the browser. Waits for the page to get loaded.
        #
        def refresh()
            #set_browser_document()
            $jssh_socket.send("#{BROWSER_VAR}.reload();\n", 0)
            read_socket();
            wait()
        end
        
        #
        # Description:
        #   This function creates a new socket at port 9997 and sets the default values for instance and class variables.
        #   Generatesi UnableToStartJSShException if cannot connect to jssh even after 3 tries.
        #
        def set_defaults(no_of_tries = 0)
            # JSSH listens on port 9997. Create a new socket to connect to port 9997.
            begin
                $jssh_socket = TCPSocket::new(MACHINE_IP, "9997")
                $jssh_socket.sync = true
                read_socket()
            rescue
                    no_of_tries += 1
                    retry if no_of_tries < 3
                    raise UnableToStartJSShException, "Unable to connect to machine : #{MACHINE_IP} on port 9997. Make sure that JSSh is properly installed and Firefox is running with '-jssh' option"
            end
            @error_checkers = []
        end
        private :set_defaults
 
        def set_slow_speed
            @typingspeed = DEFAULT_TYPING_SPEED
            @defaultSleepTime = DEFAULT_SLEEP_TIME
        end
        private :set_slow_speed
        
        #
        # Description:
        #   Sets the document, window and browser variables to point to correct object in JSSh.
        #
        def set_browser_document
            # Get the window in variable WINDOW_VAR.
            # Get the browser in variable BROWSER_VAR.
            jssh_command = "var #{WINDOW_VAR} = getWindows()[#{@@current_window}];"
            jssh_command += " var #{BROWSER_VAR} = #{WINDOW_VAR}.getBrowser();"
            # Get the document and body in variable DOCUMENT_VAR and BODY_VAR respectively.
            jssh_command += "var #{DOCUMENT_VAR} = #{BROWSER_VAR}.contentDocument;"
            jssh_command += "var #{BODY_VAR} = #{DOCUMENT_VAR}.body;"

            $jssh_socket.send("#{jssh_command}\n", 0)
            read_socket()

            # Get window and window's parent title and url
            $jssh_socket.send("#{DOCUMENT_VAR}.title;\n", 0)
            @window_title = read_socket()
            $jssh_socket.send("#{DOCUMENT_VAR}.URL;\n", 0)
            @window_url = read_socket()
        end
        private :set_browser_document
        
        #
        # Description:
        #   Closes the window.
        #
        def close()
            #puts "current window number is : #{@@current_window}"
            # Derek Berner 5/16/08
            # Try to join thread only if there is exactly one open window
            if js_eval("getWindows().length").to_i == 1
                $jssh_socket.send(" getWindows()[0].close(); \n", 0)
                @t.join if @t != nil
                #sleep 5
            else
                # Check if window exists, because there may be the case that it has been closed by click event on some element.
                # For e.g: Close Button, Close this Window link etc.
                window_number = find_window("url", @window_url)

                # If matching window found. Close the window.
                if(window_number > 0)
                    $jssh_socket.send(" getWindows()[#{window_number}].close();\n", 0)
                    read_socket();
                end    
                
                #Get the parent window url from the stack and return that window.
                #@@current_window = @@window_stack.pop()
                @window_url = @@window_stack.pop()
                @window_title = @@window_stack.pop()
                # Find window with this url.
                window_number = find_window("url", @window_url)
                @@current_window = window_number
                set_browser_document()
            end
        end
       
        #
        # Description:
        #   Used for attaching pop up window to an existing Firefox window, either by url or title.
        #   ff.attach(:url, 'http://www.google.com')
        #   ff.attach(:title, 'Google') 
        #
        # Output:
        #   Instance of newly attached window.
        #
        def attach(how, what)
            window_number = find_window(how, what)

            if(window_number == 0)
               raise NoMatchingWindowFoundException.new("Unable to locate window, using #{how} and #{what}")  
            elsif(window_number > 0)
                # Push the window_title and window_url of parent window. So that when we close the child window
                # appropriate handle of parent window is returned back.
                @@window_stack.push(@window_title)
                @@window_stack.push(@window_url)

                @@current_window = window_number.to_i
                set_browser_document()
            end    
            self
        end

        #
        # Description:
        #   Finds a Firefox browser window with a given title or url.
        #
        def find_window(how, what)
            jssh_command = "getWindows().length;";
            $jssh_socket.send("#{jssh_command}\n", 0)
            @@total_windows = read_socket()
            #puts "total windows are : " + @@total_windows.to_s

            jssh_command =  "var windows = getWindows(); var window_number = 0;var found = false;
                             for(var i = 0; i < windows.length; i++)
                             {
                                var attribute = '';
                                if(\"#{how}\" == \"url\")
                                {
                                    attribute = windows[i].getBrowser().contentDocument.URL;
                                }
                                if(\"#{how}\" == \"title\")
                                {
                                    attribute = windows[i].getBrowser().contentDocument.title;
                                }"
            if(what.class == Regexp)                    
                # Construct the regular expression because we can't use it directly by converting it to string.
                # If reg ex is /Google/i then its string conversion will be (?i-mx:Google) so we can't use it.
                # Construct the regular expression again from the string conversion.
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
                
                jssh_command += "var regExp = new RegExp(#{newRegExp});
                                 found = regExp.test(attribute);"
            else
                jssh_command += "found = (attribute == \"#{what}\");"
            end
            
            jssh_command +=     "if(found)
                                {
                                    window_number = i;
                                    break;
                                }
                            }
                            window_number;"
                            
            jssh_command.gsub!(/\n/, "")
            #puts "jssh_command is : #{jssh_command}"
            $jssh_socket.send("#{jssh_command}\n", 0)
            window_number = read_socket()
            #puts "window number is : " + window_number.to_s

            return window_number.to_i
        end
        private :find_window
        
        #
        # Description:
        #   Matches the given text with the current text shown in the browser.
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
            case target
              when Regexp
                self.text.match(target)
              when String
                self.text.index(target)
              else
                raise ArgumentError, "Argument #{target} should be a string or regexp."
            end
        end

        #
        # Description:
        #   Returns the url of the page currently loaded in the browser.
        #
        # Output:
        #   URL of the page.
        #
        def url()
            @window_url
        end 

        #
        # Description:
        #   Returns the title of the page currently loaded in the browser.
        #
        # Output:
        #   Title of the page.
        #
        def title()
            @window_title
        end

        #
        # Description:
        #   Returns the html of the page currently loaded in the browser.
        #
        # Output:
        #   HTML shown on the page.
        #
        def html()
            $jssh_socket.send("var htmlelem = #{DOCUMENT_VAR}.getElementsByTagName('html')[0]; htmlelem.innerHTML;\n", 0)
            #$jssh_socket.send("#{BODY_VAR}.innerHTML;\n", 0)
            result = read_socket()
            return "<html>" + result + "</html>"
        end

        #
        # Description:
        #   Returns the text of the page currently loaded in the browser.
        #
        # Output:
        #   Text shown on the page.
        #
        def text()
            $jssh_socket.send("#{BODY_VAR}.textContent;\n", 0)
            return read_socket().strip
        end
        
        #
        # Description:
        #   Maximize the current browser window.
        #
        def maximize()
            $jssh_socket.send("#{WINDOW_VAR}.maximize();\n", 0)
            read_socket()
        end

        #
        # Description:
        #   Minimize the current browser window.
        #
        def minimize()
            $jssh_socket.send("#{WINDOW_VAR}.minimize();\n", 0)
            read_socket()
        end

        #
        # Description:
        #   Waits for the page to get loaded.
        #
        def wait(last_url = nil)
            #puts "In wait function "
            isLoadingDocument = ""
            start = Time.now
            
            while isLoadingDocument != "false"
                isLoadingDocument = js_eval("#{BROWSER_VAR}=#{WINDOW_VAR}.getBrowser(); #{BROWSER_VAR}.webProgress.isLoadingDocument;")
                #puts "Is browser still loading page: #{isLoadingDocument}"
                
                 # Derek Berner 5/16/08
                 # Raise an exception if the page fails to load
                 if (Time.now - start) > 300
                    raise "Page Load Timeout"
                end
            end
            # Derek Berner 5/16/08
            # If the redirect is to a download attachment that does not reload this page, this
            # method will loop forever. Therefore, we need to ensure that if this method is called
            # twice with the same URL, we simply accept that we're done.
            $jssh_socket.send("#{BROWSER_VAR}.contentDocument.URL;\n", 0)
            url = read_socket()
            
            if(url != last_url)
                # Check for Javascript redirect. As we are connected to Firefox via JSSh. JSSh
                # doesn't detect any javascript redirects so check it here.
                # If page redirects to itself that this code will enter in infinite loop.
                # So we currently don't wait for such a page.
                # wait variable in JSSh tells if we should wait more for the page to get loaded
                # or continue. -1 means page is not redirected. Anyother positive values means wait.
                jssh_command = "var wait = -1; var meta = null; meta = #{BROWSER_VAR}.contentDocument.getElementsByTagName('meta');
                                if(meta != null)
                                {
                                    var doc_url = #{BROWSER_VAR}.contentDocument.URL;
                                    for(var i=0; i< meta.length;++i)
                                    {
						    			var content = meta[i].content;
							    		var regex = new RegExp(\"^refresh$\", \"i\");
								    	if(regex.test(meta[i].httpEquiv))
									    {
										    var arrContent = content.split(';');
    										var redirect_url = null;
	    									if(arrContent.length > 0)
		    								{
			    								if(arrContent.length > 1)
				    								redirect_url = arrContent[1];
	                                            
							    				if(redirect_url != null)
						    					{
								    				regex = new RegExp(\"^.*\" + redirect_url + \"$\");
									    			if(!regex.test(doc_url))
										    		{
											    		wait = arrContent[0];
												    }
											    }
											    break;
										    }
									    }
								    }
                                }
                                wait;"
                #puts "command in wait is : #{jssh_command}"                
                jssh_command = jssh_command.gsub(/\n/, "")
                $jssh_socket.send("#{jssh_command}; \n", 0)
                wait_time = read_socket();
                #puts "wait time is : #{wait_time}"
                begin
                    wait_time = wait_time.to_i
                    if(wait_time != -1)
                        sleep(wait_time)
                        # Call wait again. In case there are multiple redirects.
                        $jssh_socket.send("#{BROWSER_VAR} = #{WINDOW_VAR}.getBrowser(); \n",0)
                        read_socket()
                        wait(url)
                    end    
                rescue
                end
			end
            set_browser_document()
            run_error_checks()
            return self
        end
        
        # Add an error checker that gets called on every page load.
        #
        # * checker - a Proc object 
        def add_checker(checker)
            @error_checkers << checker
        end
        
        # Disable an error checker
        #
        # * checker - a Proc object that is to be disabled
        def disable_checker(checker)
            @error_checkers.delete(checker)
        end
        
        # Run the predefined error checks. This is automatically called on every page load.
        def run_error_checks
            @error_checkers.each { |e| e.call(self) }
        end
        
      
        #def jspopup_appeared(popupText = "", wait = 2)
        #    winHelper = WindowHelper.new()
        #    return winHelper.hasPopupAppeared(popupText, wait)
        #end
 
        #
        # Description:
        #   Redefines the alert and confirm methods on the basis of button to be clicked.
        #   This is done so that JSSh doesn't get blocked. You should use click_no_wait method before calling this function.
        #
        #   Typical Usage:
        #   ff.button(:id, "button").click_no_wait
        #   ff.click_jspopup_button("OK")
        #
        # Input:
        #   button - JavaScript button to be clicked. Values can be OK or Cancel
        #
        #def click_jspopup_button(button)
        #    button = button.downcase
        #    element = Element.new(nil)
        #    element.click_js_popup(button)
        #end

        #
        # Description:
        #   Tells FireWatir to click javascript button in case one comes after performing some action on an element. Matches
        #   text of pop up with one if supplied as parameter. If text matches clicks the button else stop script execution until
        #   pop up is dismissed by manual intervention.
        # 
        # Input:
        #   button      - JavaScript button to be clicked. Values can be OK or Cancel
        #   waitTime    - Time to wait for pop up to come. Not used just for compatibility with Watir.
        #   userInput   - Not used just for compatibility with Watir
        #   text        - Text that should appear on pop up.
        #
        def startClicker(button, waitTime = 1, userInput = nil, text = nil)
            jssh_command = "var win = #{BROWSER_VAR}.contentWindow;"
            if(button =~ /ok/i)
                jssh_command += "var popuptext = '';
                                 var old_alert = win.alert;
                                 var old_confirm = win.confirm;
                                 win.alert = function(param) {"
                if(text != nil)                 
                    jssh_command +=          "if(param == \"#{text}\") {
                                                popuptext = param; 
                                                return true;
                                              }
                                              else {
                                                popuptext = param;
                                                win.alert = old_alert;
                                                win.alert(param);
                                              }"
                else
                    jssh_command +=          "popuptext = param; return true;"
                end
                jssh_command += "};
                                 win.confirm = function(param) {"
                if(text != nil)                 
                    jssh_command +=          "if(param == \"#{text}\") {
                                                popuptext = param; 
                                                return true;
                                              }
                                              else {
                                                win.confirm = old_confirm;
                                                win.confirm(param);
                                              }"
                else
                    jssh_command +=          "popuptext = param; return true;"
                end
                jssh_command += "};"

            elsif(button =~ /cancel/i)
                jssh_command = "var old_confirm = win.confirm; 
                                              win.confirm = function(param) {"
                if(text != nil)                 
                    jssh_command +=          "if(param == \"#{text}\") {
                                                popuptext = param; 
                                                return false;
                                              }
                                              else {
                                                win.confirm = old_confirm;
                                                win.confirm(param);
                                              }"
                else
                    jssh_command +=          "popuptext = param; return false;"
                end
                jssh_command += "};"
            end
            jssh_command.gsub!(/\n/, "")
            #puts "jssh command sent for js pop up is : #{jssh_command}"
            $jssh_socket.send("#{jssh_command}\n", 0)
            read_socket()
        end
        
        #
        # Description:
        #   Returns text of javascript pop up in case it comes.
        #
        # Output:
        #   Text shown in javascript pop up.
        #
        def get_popup_text()
            $jssh_socket.send("popuptext;\n", 0)
            return_value = read_socket()
            # reset the variable
            $jssh_socket.send("popuptext = '';\n", 0)
            read_socket()
            return return_value
        end
        
        #
        # Description:
        #   Returns the document element of the page currently loaded in the browser.
        #
        # Output:
        #   Document element.
        #
        def document
             Document.new("#{DOCUMENT_VAR}")
        end
       
        #
        # Description:
        #   Returns the first element that matches the xpath query.
        #
        # Input:
        #   Xpath expression or query.
        #
        # Output:
        #   Element matching the xpath query.
        #
        def element_by_xpath(xpath)
            temp = Element.new(nil, self)
            element_name = temp.element_by_xpath(self, xpath)
            return element_factory(element_name)
        end

        # 
        # Description:
        #   Factory method to create object of correct Element class while using XPath to get the element.
        #
        def element_factory(element_name)
            jssh_type = Element.new(element_name,self).element_type
            #puts "jssh type is : #{jssh_type}" # DEBUG
            candidate_class = jssh_type =~ /HTML(.*)Element/ ? $1 : ''
            #puts candidate_class # DEBUG
            if candidate_class == 'Input'
                $jssh_socket.send("#{element_name}.type;\n", 0)
                input_type = read_socket().downcase.strip
                puts input_type # DEBUG
                firewatir_class = input_class(input_type)
            else
                firewatir_class = jssh2firewatir(candidate_class)
            end
            
            #puts firewatir_class # DEBUG
            klass = FireWatir.const_get(firewatir_class)

            if klass == Element
                klass.new(element_name,self)
            elsif klass == CheckBox
                klass.new(self,:jssh_name,element_name,["checkbox"])
            elsif klass == Radio
                klass.new(self,:jssh_name,element_name,["radio"])
            else
                klass.new(self,:jssh_name,element_name)
            end 
        end
        private :element_factory

        #
        # Description:
        #   Get the class name for element of input type depending upon its type like checkbox, radio etc.
        #
        def input_class(input_type)
            hash = {
                'select-one' => 'SelectList',
                'select-multiple' => 'SelectList',
                'text' => 'TextField',
                'password' => 'TextField',
                'textarea' => 'TextField',
                # TODO when there's no type, it's a TextField
                'file' => 'FileField',
                'checkbox' => 'CheckBox',
                'radio' => 'Radio',
                'reset' => 'Button',
                'button' => 'Button',
                'submit' => 'Button',
                'image' => 'Button'
            }
            hash.default = 'Element'
 
            hash[input_type]
        end
        private :input_class

        #
        # Description:
        #   Converts element type returned by JSSh like HTMLDivElement to its corresponding class in Firewatir.
        #
        def jssh2firewatir(candidate_class)
            hash = {
                'Div' => 'Div',
                'Button' => 'Button',
                'Frame' => 'Frame',
                'Span' => 'Span',
                'Paragraph' => 'P',
                'Label' => 'Label',
                'Form' => 'Form',
                'Image' => 'Image',
                'Table' => 'Table',
                'TableCell' => 'TableCell',
                'TableRow' => 'TableRow',
                'Select' => 'SelectList',
                'Link' => 'Link',
                'Anchor' => 'Link' # FIXME is this right?
                #'Option' => 'Option' #Option uses a different constructor
            }
            hash.default = 'Element'
            hash[candidate_class]
        end
        private :jssh2firewatir

        #
        # Description:
        #   Returns the array of elements that matches the xpath query.
        #
        # Input:
        #   Xpath expression or query.
        #
        # Output:
        #   Array of elements matching xpath query.
        #
        def elements_by_xpath(xpath)
            element = Element.new(nil, self)
            elem_names = element.elements_by_xpath(self, xpath)
            a = elem_names.inject([]) {|elements,name| elements << element_factory(name)}
        end    
	
        #
        # Description:
        #   Show all the forms available on the page.
        #
        # Output:
        #   Name, id, method and action of all the forms available on the page.
        #
        def show_forms
            forms = Document.new(self).get_forms()
            count = forms.length
            puts "There are #{count} forms"
            for i in 0..count - 1 do
                puts "Form name: " + forms[i].name
                puts "       id: " + forms[i].id
                puts "   method: " + forms[i].attribute_value("method")
                puts "   action: " + forms[i].action
            end
        end
        alias showForms show_forms
        
        #
        # Description:
        #   Show all the images available on the page.
        #
        # Output:
        #   Name, id, src and index of all the images available on the page.
        #
        def show_images
            images = Document.new(self).get_images
            puts "There are #{images.length} images"
            index = 1
            images.each do |l|
                puts "image: name: #{l.name}"
                puts "         id: #{l.id}"
                puts "        src: #{l.src}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showImages show_images

        #
        # Description:
        #   Show all the links available on the page.
        #
        # Output:
        #   Name, id, href and index of all the links available on the page.
        #
        def show_links
            links = Document.new(self).get_links
            puts "There are #{links.length} links"
            index = 1
            links.each do |l|
                puts "link:  name: #{l.name}"
                puts "         id: #{l.id}"
                puts "       href: #{l.href}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showLinks show_links
        
        #
        # Description:
        #   Show all the divs available on the page.
        #
        # Output:
        #   Name, id, class and index of all the divs available on the page.
        #
        def show_divs
            divs = Document.new(self).get_divs
            puts "There are #{divs.length} divs"
            index = 1
            divs.each do |l|
                puts "div:   name: #{l.name}"
                puts "         id: #{l.id}"
                puts "      class: #{l.className}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showDivs show_divs
        
        #
        # Description:
        #   Show all the tables available on the page.
        #
        # Output:
        #   Id, row count, column count (only first row) and index of all the tables available on the page.
        #
        def show_tables
            tables = Document.new(self).get_tables
            puts "There are #{tables.length} tables"
            index = 1
            tables.each do |l|
                puts "table:   id: #{l.id}"
                puts "       rows: #{l.row_count}"
                puts "    columns: #{l.column_count}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showTables show_tables
        
        #
        # Description:
        #   Show all the pre elements available on the page.
        #
        # Output:
        #   Id, name and index of all the pre elements available on the page.
        #
        def show_pres
            pres = Document.new(self).get_pres
            puts "There are #{pres.length} pres"
            index = 1
            pres.each do |l|
                puts "pre:     id: #{l.id}"
                puts "       name: #{l.name}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showPres show_pres
        
        #
        # Description:
        #   Show all the spans available on the page.
        #
        # Output:
        #   Name, id, class and index of all the spans available on the page.
        #
        def show_spans
            spans = Document.new(self).get_spans
            puts "There are #{spans.length} spans"
            index = 1
            spans.each do |l|
                puts "span:  name: #{l.name}"
                puts "         id: #{l.id}"
                puts "      class: #{l.className}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showSpans show_spans
        
        #
        # Description:
        #   Show all the labels available on the page.
        #
        # Output:
        #   Name, id, for and index of all the labels available on the page.
        #
        def show_labels
            labels = Document.new(self).get_labels
            puts "There are #{labels.length} labels"
            index = 1
            labels.each do |l|
                puts "label: name: #{l.name}"
                puts "         id: #{l.id}"
                puts "        for: #{l.for}"
                puts "      index: #{index}"
                index += 1
            end
        end
        alias showLabels show_labels
        
        #
        # Description:
        #   Show all the frames available on the page. Doesn't show nested frames.
        #
        # Output:
        #   Name, and index of all the frames available on the page.
        #
        def show_frames
            jssh_command = "var frameset = #{WINDOW_VAR}.frames;
                            var elements_frames = new Array();
                            for(var i = 0; i < frameset.length; i++)
                            {
                                var frames = frameset[i].frames;
                                for(var j = 0; j < frames.length; j++)
                                {
                                    elements_frames.push(frames[j].frameElement);    
                                }
                            }
                            elements_frames.length;"
            
            jssh_command.gsub!("\n", "")
            $jssh_socket.send("#{jssh_command};\n", 0)
            length = read_socket().to_i 
            
            puts "There are #{length} frames"
            
            frames = Array.new(length)
            for i in 0..length - 1 do
                frames[i] = Frame.new(self, :jssh_name, "elements_frames[#{i}]")
            end
            
            for i in 0..length - 1 do
                puts "frame: name: #{frames[i].name}"
                puts "      index: #{i+1}"
            end
        end
        alias showFrames show_frames

	    # 5/16/08 Derek Berner
    	# Wrapper method to send JS commands concisely,
	    # and propagate errors
    	def js_eval(str)
	        #puts "JS Eval: #{str}"
    	    $jssh_socket.send("#{str};\n",0)
	        value = read_socket()
	        if md=/^(\w+)Error:(.*)$/.match(value) 
	            eval "class JS#{md[1]}Error\nend"
	            raise (eval "JS#{md[1]}Error"), md[2]
	        end
	        #puts "Value: #{value}"
	        value
	    end

    end # Class Firefox
 
    # 
    # Module for handling the Javascript pop-ups. Not in use currently, will be available in future.    
    # Use ff.startClicker() method for clicking javascript pop ups. Refer to unit tests on how to handle
    # javascript pop up (unittests/javascript_test.rb)
    #module Dialog
    #    # Class for handling javascript popup. Not in use currently, will be available in future. See unit tests on how to handle
    #    # javascript pop up (unittests/javascript_test.rb).
    #    class JSPopUp
    #        include Container
    #        
    #        def has_appeared(text)
    #            require 'socket' 
    #            sleep 4 
    #            shell = TCPSocket.new("localhost", 9997)
    #            read_socket(shell)
    #            #jssh_command =  "var url = #{DOCUMENT_VAR}.URL;"
    #            jssh_command = "var length = getWindows().length; var win;length;\n"
    #            #jssh_command += "for(var i = 0; i < length; i++)"
    #            #jssh_command += "{"
    #            #jssh_command += "   win = getWindows()[i];"
    #            #jssh_command += "   if(win.opener != null && "
    #            #jssh_command += "      win.title == \"[JavaScript Application]\" &&"
    #            #jssh_command += "      win.opener.document.URL == url)"
    #            #jssh_command += "   {"
    #            #jssh_command += "       break;"
    #            #jssh_command += "   }"
    #            #jssh_command += "}"
    #            
    #            #jssh_command += " win.title;\n";
    #            #jssh_command += "var dialog = win.document.childNodes[0];"
    #            #jssh_command += "vbox = dialog.childNodes[1].childNodes[1];"
    #            #jssh_command += "vbox.childNodes[1].childNodes[0].childNodes[0].textContent;\n"
    #            puts jssh_command 
    #            shell.send("#{jssh_command}", 0)
    #            jstext = read_socket(shell)
    #            puts jstext
    #            return jstext == text
    #        end
    #    end
    #end       

end

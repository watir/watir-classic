=begin
  license
  ---------------------------------------------------------------------------
  Copyright (c) 2004-2005, Paul Rogers and Bret Pettichord
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice,
  this list of conditions and the following disclaimer.
  
  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  
  3. Neither the names Paul Rogers, Bret Pettichord nor the names of contributors to
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

#  This is Watir, Web Application Testing In Ruby
#  Home page is http://wtr.rubyforge.org
#
#  Version "$Revision$"
#
#  Typical usage: 
#   # include the controller 
#   require "watir" 
#   # go to the page you want to test 
#   ie = Watir::IE.start("http://myserver/mypage")  
#   # enter "Paul" into an input field named "username" 
#   ie.text_field(:name, "username").set("Paul") 
#   # enter "Ruby Co" into input field with id "company_ID" 
#   ie.text_field(:id ,"company_ID").set("Ruby Co") 
#   # click button that has a caption of "Cancel" 
#   ie.button(:value, "Cancel").click 
#   
#  The ways that are available to identify an html object depend upon the object type, but include
#   :id           used for an object that has an ID attribute -- this is the best way!
#   :name         used for an object that has a name attribute. 
#   :value        value of text fields, captions of buttons 
#   :index        finds the nth object of the specified type - eg button(:index , 2) finds the second button. This is 1 based. <br>
#   :beforeText   finds the object immeditaley before the specified text. Doesnt work if the text is in a table cell
#   :afterText    finds the object immeditaley after the specified text. Doesnt work if the text is in a table cell
#


# These 2 web sites provide info on Internet Explorer and on the DOM as implemented by Internet Explorer
# http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/webbrowser/webbrowser.asp
# http://msdn.microsoft.com/library/default.asp?url=/workshop/browser/overview/overview.asp

# command line options:
#
#  -b  (background)   Run Internet Explorer invisible
#  -f  (fast)         Run tests fast
#  -x  (spinner)      Add a spinner that displays when pages are waiting to be loaded.

require 'win32ole'
require 'logger'
require 'watir/winClicker'
require 'watir/exceptions'

class String
    def matches (x)
        return self == x
    end
end

class Regexp
    def matches (x)
        return self.match(x) 
    end
end

# ARGV needs to be deleted to enable the Test::Unit functionality that grabs
# the remaining ARGV as a filter on what tests to run.
# Note: this means that watir must be require'd BEFORE test/unit.
def command_line_flag(switch)
    setting = ARGV.include?(switch) 
    ARGV.delete(switch)
    return setting
end            

# Constant to make Internet explorer minimisez. -b stands for background
$HIDE_IE = command_line_flag('-b') 

# Constant to enable/disable the spinner
$ENABLE_SPINNER = command_line_flag('-x') 

# Constant to set fast speed
$FAST_SPEED = command_line_flag('-f')

# Eat the -s command line switch (deprecated)
command_line_flag('-s')

module Watir
    include Watir::Exception

    # BUG: this won't work right until the null objects are pulled out
    def exists?
        begin
            yield
            true
        rescue
            false
        end
    end

    class WatirLogger < Logger
        def initialize(  filName , logsToKeep, maxLogSize )
            super( filName , logsToKeep, maxLogSize )
            self.level = Logger::DEBUG
            self.datetime_format = "%d-%b-%Y %H:%M:%S"
            self.debug("Watir starting")
        end
    end
    
    class DefaultLogger < Logger
        def initialize()
            super(STDERR)
            self.level = Logger::WARN
            self.datetime_format = "%d-%b-%Y %H:%M:%S"
            self.info "Log started"
        end
    end
    
    # This class displays the spinner object that appears in the console when a page is being loaded
    class Spinner
        
        def initialize(enabled = true)
            @s = [ "\b/" , "\b|" , "\b\\" , "\b-"]
            @i=0
            @enabled = enabled
        end
        
        # reverse the direction of spinning
        def reverse
            @s.reverse!
        end
        
        def spin
            print self.next if @enabled
        end

        # get the next character to display
        def next
            @i=@i+1
            @i=0 if @i>@s.length-1
            return @s[@i]
        end
    end

    # This module contains the factory methods that are used to access most html objects
    #
    # For example, to access a button on a web page that has the following html
    #  <input type = button name= 'b1' value='Click Me' onClick='javascript:doSomething()'>
    #
    # the following watir code could be used
    #
    #  ie.button(:name, 'b1').click
    #
    # or
    #
    #  ie.button(:value, 'Click Me').to_s
    #
    # there are many methods available to the Button object
    #
    # Is includable for classes that have @ieController, document and document.body
    module SupportsSubElements 
        include Watir::Exception

        # this method returns the real Internet Explorer object, allowing access to objects, properties and methods that Watir doesnot support
        def ie
            return @ieController
        end

        # write the specified string to the log, assuming a logger has been setup using IE#set_logger
        def log ( what )
            @ieController.logger.debug( what ) if @logger
        end

        # this method causes Watir to wait until Internet Explorer has finished the action
        def wait( noSleep  = false )
             @ieController.wait( noSleep )
        end

        def process_default(default_attribute, how, what)
            if what == nil
                what = how
                how = default_attribute 
            end
            return how, what
        end 
        private :process_default

        # this method is the main way of accessing a frame 
        #   *  how   - how the frame is accessed. This can also just be the name of the frame
        #   *  what  - what we want to access.
        #
        # Typical usage:
        #
        #   ie.frame(:index, 1) 
        #   ie.frame(:name , 'main_frame')
        #   ie.frame('main_frame')        # in this case, just a name is supplied
        def frame(how, what=nil)
            how, what = process_default :name, how, what
            return Frame.new(self, how, what)
        end
 
        # this method is used to access a form.
        # available ways of accessing it are, :index , :name, :id, :method, :action
        #  * how        - symbol - WHat mecahnism we use to find the form, one of the above. NOTE if what is not supplied this parameter is the NAME of the form
        #  * what   - String - the text associated with the symbol
        def form(how, what=nil)
            how, what = process_default :name, how, what
            return Form.new(self, how, what)      
        end

        # This method is used to get a table from the page. 
        # :index (1 based counting)and :id are supported. 
        #  NOTE :name is not supported, as the table tag does not have a name attribute. It is not part of the DOM.
        # :index can be used when there are multiple tables on a page. 
        # The first form can be accessed with :index 1, the second :index 2, etc. 
        #   * how - symbol - the way we look for the table. Supported values are
        #                  - :id
        #                  - :index
        #   * what  - string the thing we are looking for, ex. id or index of the object we are looking for
        def table( how, what )
            return Table.new( self , how, what)
        end

        # this is the main method for accessing the tables iterator. It returns a Tables object
        #
        # Typical usage:
        #
        #   ie.tables.each { |t| puts t.to_s }            # iterate through all the tables on the page
        #   ie.tables[1].to_s                             # goto the first table on the page                                   
        #   ie.tables.length                              # show how many tables are on the page. Tables that are nested will be included in this
        def tables()
            return Tables.new(self)
        end

        # this method accesses a table cell. 
        # how - symbol - how we access the cell,  :id is supported
        # 
        # returns a TableCell Object
        def cell( how, what )
           return TableCell.new( self, how, what)
        end

        # this method accesses a table row. 
        # how - symbol - how we access the row,  :id is supported
        # 
        # returns a TableRow object
        def row( how, what )
           return TableRow.new( self, how, what)
        end

        # This is the main method for accessing a button. Often declared as an <input type = submit> tag.
        #  *  how   - symbol - how we access the button 
        #  *  what  - string, int or re , what we are looking for, 
        # Returns a Button object.
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :value      - find the item using the value attribute ( in this case the button caption)
        #    :caption    - same as value
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #
        # Typical Usage
        #
        #    ie.button(:id,    'b_1')                       # access the button with an ID of b_1
        #    ie.button(:name,  'verify_data')               # access the button with a name of verify_data
        #    ie.button(:value, 'Login')                     # access the button with a value (the text displayed on the button) of Login
        #    ie.button(:caption, 'Login')                   # same as above
        #    ie.button(:value, /Log/)                       # access the button that has text matching /Log/
        #    ie.button(:index, 2)                           # access the second button on the page ( 1 based, so the first button is accessed with :index,1)
        #
        # if only a single parameter is supplied,  then :value is used 
        #
        #    ie.button('Click Me')                          # access the button with a value of Click Me
        def button(how, what=nil)
            how, what = process_default :value, how, what
            return Button.new(self, how, what)
        end

        # this is the main method for accessing the buttons iterator. It returns a Buttons object
        #
        # Typical usage:
        #
        #   ie.buttons.each { |b| puts b.to_s }            # iterate through all the buttons on the page
        #   ie.buttons[1].to_s                             # goto the first button on the page                                   
        #   ie.buttons.length                              # show how many buttons are on the page. 
        def buttons()
            return Buttons.new(self)
        end


        # This is the main method for accessing a file field. Usually an <input type = file> HTML tag.  
        #  *  how   - symbol - how we access the field , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #
        # returns a FileField object
        #
        # Typical Usage
        #
        #    ie.file_field(:id,   'up_1')                     # access the file upload field with an ID of up_1
        #    ie.file_field(:name, 'upload')                   # access the file upload field with a name of upload
        #    ie.file_field(:index, 2)                         # access the second file upload on the page ( 1 based, so the first field is accessed with :index,1)
        #
        def file_field(how , what)
            return FileField.new(self , how, what)
        end
        
        # this is the main method for accessing the file_fields iterator. It returns a FileFields object
        #
        # Typical usage:
        #
        #   ie.file_fields.each { |f| puts f.to_s }            # iterate through all the file fields on the page
        #   ie.file_fields[1].to_s                             # goto the first file field on the page                                   
        #   ie.file_fields.length                              # show how many file fields are on the page. 
        def file_fields()
            return FileFields.new(self)
        end

        # This is the main method for accessing a text field. Usually an <input type = text> HTML tag. or a text area - a  <textarea> tag
        #  *  how   - symbol - how we access the field , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #
        # returns a TextField object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #
        # Typical Usage
        #
        #    ie.text_field(:id,   'user_name')                 # access the text field with an ID of user_name
        #    ie.text_field(:name, 'address')                   # access the text field with a name of address
        #    ie.text_field(:index, 2)                          # access the second text field on the page ( 1 based, so the first field is accessed with :index,1)
        def text_field(how , what=nil)
            return TextField.new(self, how, what)
        end

        # this is the method for accessing the text_fields iterator. It returns a Text_Fields object
        #
        # Typical usage:
        #
        #   ie.text_fields.each { |t| puts t.to_s }            # iterate through all the text fields on the page
        #   ie.text_fields[1].to_s                             # goto the first text field on the page                                   
        #   ie.text_fields.length                              # show how many text field are on the page.
        def text_fields
            return TextFields.new(self)
        end

        # This is the main method for accessing a hidden field. Usually an <input type = hidden> HTML tag
        #  *  how   - symbol - how we access the field , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #
        # returns a Hidden object
        #
        # Typical usage
        #
        #    ie.hidden(:id, 'session_id')                 # access the hidden field with an ID of session_id
        #    ie.hidden(:name, 'temp_value')               # access the hidden field with a name of temp_value
        #    ie.hidden(:index, 2)                         # access the second hidden field on the page ( 1 based, so the first field is accessed with :index,1)
        def hidden( how, what )
            return Hidden.new(self, how, what)
        end

        # this is the method for accessing the hiddens iterator. It returns a Hiddens object
        #
        # Typical usage:
        #
        #   ie.hiddens.each { |t|  puts t.to_s }           # iterate through all the hidden fields on the page
        #   ie.hiddens[1].to_s                             # goto the first hidden field on the page                                   
        #   ie.hiddens.length                              # show how many hidden fields are on the page.
        def hiddens
            return Hiddens.new(self)
        end

        # This is the main method for accessing a selection list. Usually a <select> HTML tag.
        #  *  how   - symbol - how we access the selection list , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #
        # returns a SelectList object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #
        # Typical usage
        #
        #    ie.select_list(:id, 'currency')                   # access the select box with an id of currency
        #    ie.select_list(:name, 'country')                  # access the select box with a name of country
        #    ie.select_list(:name, /n_/ )                      # access the first select box whose name matches n_
        #    ie.select_list(:index, 2)                         # access the second select box on the page ( 1 based, so the first field is accessed with :index,1)
        def select_list(how , what=nil)
            return SelectList.new(self, how, what)
        end

        # this is the method for accessing the select lists iterator. Returns a SelectLists object
        #
        # Typical usage:
        #
        #   ie.select_lists.each { |s| puts s.to_s }            # iterate through all the select boxes on the page
        #   ie.select_lists[1].to_s                             # goto the first select boxes on the page                                   
        #   ie.select_lists.length                              # show how many select boxes are on the page.
        def select_lists()
            return SelectLists.new(self)
        end
        
        # This is the main method for accessing a check box. Usually an <input type = checkbox> HTML tag.
        #
        #  *  how   - symbol - how we access the check box , :index, :id, :name etc
        #  *  what  - string, int or re , what we are looking for, 
        #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
        #
        # returns a CheckBox object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #
        # Typical usage
        #
        #    ie.checkbox(:id, 'send_email')                   # access the check box with an id of send_mail
        #    ie.checkbox(:name, 'send_copy')                  # access the check box with a name of send_copy
        #    ie.checkbox(:name, /n_/ )                        # access the first check box whose name matches n_
        #    ie.checkbox(:index, 2)                           # access the second check box on the page ( 1 based, so the first field is accessed with :index,1)
        #
        # In many instances, checkboxes on an html page have the same name, but are identified by different values. An example is shown next.
        #
        #  <input type = checkbox name = email_frequency value = 'daily' > Daily Email
        #  <input type = checkbox name = email_frequency value = 'Weekly'> Weekly Email
        #  <input type = checkbox name = email_frequency value = 'monthly'>Monthly Email
        #
        # Watir can access these using the following:
        #
        #    ie.checkbox(:id, 'day_to_send' , 'monday' )         # access the check box with an id of day_to_send and a value of monday
        #    ie.checkbox(:name ,'email_frequency', 'weekly')     # access the check box with a name of email_frequency and a value of 'weekly'
        def checkbox(how, what=nil ,value=nil)
            return CheckBox.new(self, how, what, ["checkbox"], value)
        end

        # this is the method for accessing the check boxes iterator. Returns a CheckBoxes object
        #
        # Typical usage:
        #
        #   ie.checkboxes.each { |c| puts c.to_s }           # iterate through all the check boxes on the page
        #   ie.checkboxes[1].to_s                             # goto the first check box on the page                                   
        #   ie.checkboxes.length                              # show how many check boxes are on the page.
        def checkboxes
            return CheckBoxes.new(self)
        end

        # This is the main method for accessing a radio button. Usually an <input type = radio> HTML tag.
        #  *  how   - symbol - how we access the radio button, :index, :id, :name etc
        #  *  what  - string, int or regexp , what we are looking for, 
        #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
        #
        # returns a Radio object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #
        # Typical usage
        #
        #    ie.radio(:id, 'send_email')                   # access the radio button with an id of currency
        #    ie.radio(:name, 'send_copy')                  # access the radio button with a name of country
        #    ie.radio(:name, /n_/ )                        # access the first radio button whose name matches n_
        #    ie.radio(:index, 2)                           # access the second radio button on the page ( 1 based, so the first field is accessed with :index,1)
        #
        # In many instances, radio buttons on an html page have the same name, but are identified by different values. An example is shown next.
        #
        #  <input type = radio  name = email_frequency value = 'daily' > Daily Email
        #  <input type = radio  name = email_frequency value = 'Weekly'> Weekly Email
        #  <input type = radio  name = email_frequency value = 'monthly'>Monthly Email
        #
        # Watir can access these using the following:
        #
        #    ie.radio(:id, 'day_to_send' , 'monday' )         # access the radio button with an id of day_to_send and a value of monday
        #    ie.radio(:name ,'email_frequency', 'weekly')     # access the radio button with a name of email_frequency and a value of 'weekly'
        #
        def radio(how, what=nil, value=nil)
            return Radio.new(self, how, what, ["radio"], value)
        end

        # This is the method for accessing the radio buttons iterator. Returns a Radios object
        #
        # Typical usage:
        #
        #   ie.radios.each { |r| puts r.to_s }            # iterate through all the radio buttons on the page
        #   ie.radios[1].to_s                             # goto the first radio button on the page                                   
        #   ie.radios.length                              # show how many radio buttons are on the page.
        #
        def radios
            return Radios.new(self)
        end
        
        # This is the main method for accessing a link.
        #  *  how   - symbol - how we access the link, :index, :id, :name , :beforetext, :afterText, :title , :text , :url
        #  *  what  - string, int or re , what we are looking for
        #
        # returns a Link object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :beforeText - finds the item immediately before the specified text
        #    :afterText  - finds the item immediately after the specified text
        #    :url        - finds the link based on the url. This must be the full path to the link, so is best used with a regular expression
        #    :text       - finds a link using the innerText of the link, ie the Text that is displayed to the user
        #    :title      - finds the item using the tool tip text
        #
        # Typical Usage
        # 
        #   ie.link(:url, /login/)              # access the first link whose url matches login. We can use a string in place of the regular expression
        #                                       # but the complete path must be used, ie.link(:url, 'http://myserver.com/my_path/login.asp')
        #   ie.link(:index,2)                   # access the second link on the page
        #   ie.link(:title , "Picture")         # access a link using the tool tip
        #   ie.link(:text, 'Click Me')          # access the link that has Click Me as its text
        #   ie.link(:afterText, 'Click->')      # access the link that immediately follows the text Click->
        #
        def link(how, what=nil)
            return Link.new(self, how, what)
        end

        # This is the main method for accessing the links collection. Returns a Links object
        #
        # Typical usage:
        #
        #   ie.links.each { |l| puts l.to_s }            # iterate through all the links on the page
        #   ie.links[1].to_s                             # goto the first link on the page                                   
        #   ie.links.length                              # show how many links are on the page.
        #
        def links
            return Links.new(self)
        end

        # This is the main method for accessing images - normally an <img src="image.gif"> HTML tag.
        #  *  how   - symbol - how we access the image, :index, :id, :name , :src or :alt are supported
        #  *  what  - string, int or re , what we are looking for, 
        #
        # returns an Image object
        #
        # Valid values for 'how' are
        #
        #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
        #                  index is 1 based
        #    :name       - find the item using the name attribute
        #    :id         - find the item using the id attribute
        #    :alt        - finds the item using the tool tip text
        #    :src        - finds the item using the src tag. This must be the fully qualified name, so is best used with a regular expression
        #
        # Typical Usage
        # 
        #   ie.image(:src, /myPic/)             # access the first image that matches myPic. We can use a string in place of the regular expression
        #                                       # but the complete path must be used, ie.image(:src, 'http://myserver.com/my_path/my_image.jpg')
        #   ie.image(:index,2)                  # access the second image on the page
        #   ie.image(:alt , "A Picture")        # access an image using the alt text
        #   
        def image( how , what=nil)
            return Image.new(self, how, what)
        end
        
        # This is the main method for accessing the images collection. Returns an Images object
        #
        # Typical usage:
        #
        #   ie.images.each { |i| puts i.to_s }            # iterate through all the images on the page
        #   ie.images[1].to_s                             # goto the first image on the page                                   
        #   ie.images.length                              # show how many images are on the page.
        #
        def images
            return Images.new(self)
        end

        # This is the main method for accessing JavaScript popups.
        # returns a PopUp object
        def popup
            return PopUp.new(self )
        end

        # This is the main method for accessing divs. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
        #  *  how   - symbol - how we access the div, :index, :id, :title
        #  *  what  - string, integer or re , what we are looking for, 
        #
        # returns an Div object
        #
        # Typical Usage
        # 
        #   ie.div(:id, /list/)                 # access the first div that matches list.
        #   ie.div(:index,2)                    # access the second div on the page
        #   ie.div(:title , "A Picture")        # access a div using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
        #   
        def div(how, what)
            return Div.new(self, how, what)
        end

        # this is the main method for accessing the divs iterator. Returns a Divs object
        #
        # Typical usage:
        #
        #   ie.divs.each { |d| puts d.to_s }            # iterate through all the divs on the page
        #   ie.divs[1].to_s                             # goto the first div on the page                                   
        #   ie.divs.length                              # show how many divs are on the page.
        #
        def divs
            return Divs.new(self)
        end

        # This is the main method for accessing span tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/span.asp?frame=true
        #  *  how   - symbol - how we access the span, :index, :id, :name 
        #  *  what  - string, integer or re , what we are looking for, 
        #
        # returns a Span object
        #
        # Typical Usage
        # 
        #   ie.span(:id, /list/)                 # access the first span that matches list.
        #   ie.span(:index,2)                    # access the second span on the page
        #   ie.span(:title , "A Picture")        # access a span using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
        #   
        def span(how , what)
            return Span.new(self, how, what)
        end

        # this is the main method for accessing the spans iterator. 
        # 
        # Returns a Spans object
        #
        # Typical usage:
        #
        #   ie.spans.each { |s| puts s.to_s }            # iterate through all the spans on the page
        #   ie.spans[1].to_s                             # goto the first span on the page                                   
        #   ie.spans.length                              # show how many spans are on the page.
        #
        def spans
            return Spans.new(self)
        end

        # This is the main method for accessing p tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/p.asp?frame=true
        #  *  how   - symbol - how we access the p, :index, :id, :name 
        #  *  what  - string, integer or re , what we are looking for, 
        #
        # returns a P object
        #
        # Typical Usage
        # 
        #   ie.p(:id, /list/)                 # access the first p tag  that matches list.
        #   ie.p(:index,2)                    # access the second p tag on the page
        #   ie.p(:title , "A Picture")        # access a p tag using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
        #   
        def p(how, what)
            return P.new(self , how , what)
        end

        # this is the main method for accessing the ps iterator. 
        # 
        # Returns a Ps object
        #
        # Typical usage:
        #
        #   ie.ps.each { |p| puts p.to_s }            # iterate through all the p tags on the page
        #   ie.ps[1].to_s                             # goto the first p tag on the page                                   
        #   ie.ps.length                              # show how many p tags are on the page.
        #
        def ps
            return Ps.new(self)
        end

        # This is the main method for accessing labels. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
        #  *  how   - symbol - how we access the label, :index, :id, :for
        #  *  what  - string, integer or re , what we are looking for, 
        #
        # returns a Label object
        #
        # Typical Usage
        # 
        #   ie.label(:id, /list/)                 # access the first span that matches list.
        #   ie.label(:index,2)                    # access the second label on the page
        #   ie.label(:for, "text_1")              # access a the label that is associated with the object that has an id of text_1
        #   
        def label(how, what)
            return Label.new(self, how, what)
        end

        # this is the main method for accessing the labels iterator. It returns a Labels object
        # 
        # Returns a Labels object
        #
        # Typical usage:
        #
        #   ie.labels.each { |l| puts l.to_s }            # iterate through all the labels on the page
        #   ie.labels[1].to_s                             # goto the first label on the page                                   
        #   ie.labels.length                              # show how many labels are on the page.
        #
        def labels()
            return Labels.new(self)
        end

        #--
        #
        # Searching for Page Elements
        # Not for external consumption
        #        
        #++
        def getContainerContents()
            return document.body.all 
        end
        private :getContainerContents

        # this method is used internally by Watir and should not be used externally. 
        # It cannot be marked as private because of the way mixins and inheritance work in watir.
        # BUG: This looks wrong: Not everything that includes SupportsSubElements has a document.body!
        def getContainer()
            return document.body
        end
     
        # This is the main method for finding objects on a web page.
        #
        # This method is used internally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
        #
        #   * how - symbol - the way we look for the object. Supported values are
        #                  - :name
        #                  - :id
        #                  - :index
        #                  - :value etc
        #   * what  - string that we are looking for, ex. the name, or id tag attribute or index of the object we are looking for.
        #   * types - what object types we will look at. Only used when index is specified as the how.
        #   * value - used for objects that have one name, but many values. ex. radio lists and checkboxes
        def getObject(how, what, types, value=nil)
            container = getContainerContents # XXX actually this returns a collection object (not a container)
            how = :value if how == :caption
            log "getting object - how is #{how} what is #{what} types = #{types} value = #{value}"
            
            o = nil
            if how == :index
                index =  what.to_i
                log" getting object #{types.to_s}  at index( #{index}"
                
                objectIndex = 1
                container.each do | thisObject |
                    begin
                        this_type = thisObject.invoke("type")
                    rescue
                        this_type = nil
                    end
                    if types.include?(this_type)
                        if objectIndex == index
                            o = thisObject
                            break
                        end
                        objectIndex += 1
                    end
                end
                return o
                
            else
                container.each do |object|
                    next  unless o == nil
                    
                    begin
                        case how
                        when :id
                            attribute = object.invoke("id")
                        when :name
                            attribute = object.invoke("name")
                        when :value
                            attribute = object.value
                        when :alt
                            attribute = object.alt
                        when :src
                            attribute = object.src
                        when :beforeText
                            attribute = object.getAdjacentText("afterEnd").strip
                        when :afterText
                            attribute = object.getAdjacentText("beforeBegin").strip
                        else
                            next
                        end
                        
                        if what.matches(attribute) && types.include?(object.invoke("type"))
                            if value
                                log "checking value supplied #{value} ( #{value.class}) actual #{object.value} ( #{object.value.class})"
                                if object.value.to_s == value.to_s
                                    o = object
                                end
                            else # no value
                                o = object
                            end
                        end
                        
                    rescue => e
                        log 'IE#getObject error ' + e.to_s 
                    end
                    
                end
            end
            
            return o
        end

        # This method is used iternally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
        #
        # this method finds the specified image
        #    * how  - symbol - how to look
        #    * what - string or regexp - what to look ofr
        def getImage( how, what )

            doc = document
            count = 1
            images = doc.all.tags("IMG")
            o=nil
            images.each do |img|
                
                #puts "Image on page: src = #{img.src}"
                
                next unless o == nil
                if how == :index
                    o = img if count == what.to_i
                else                
                    case how
                        
                    when :src
                        attribute = img.src
                    when :name
                        attribute = img.name
                    when :id
                        attribute = img.invoke("id")
                    when :alt
                        attribute = img.invoke("alt")
                    else
                        next
                    end
                    
                    o = img if what.matches(attribute)
                end
                count +=1
            end # do
            return o

        end

        # This method is used iternally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
        #
        # This method gets a link from the document. This is a hyperlink, generally declared in the <a href="http://testsite">test site</a> HTML tag.
        #   * how  - symbol - how we get the link Supported types are:
        #                     :index - the link at position x , 1 based
        #                     :url   - get the link that has a url that matches. A regular expression match is performed
        #                     :text  - get link based on the supplied text. uses either a string or regular expression match
        #   * what - depends on how - an integer for index, a string or regexp for url and text
        def getLink( how, what )
            links = document.all.tags("A")
            
            # Guard ensures watir won't crash if somehow the list of links is nil
            if (links == nil)
                raise UnknownObjectException, "Unknown Object in getLink: attempted to click a link when no links present"
            end
            
            link = nil
            case how
            when :index
                begin
                    link = links[ (what-1).to_s ]
                rescue
                    link=nil
                end
                
            when :url
                links.each do |thisLink|
                    if what.matches(thisLink.href) 
                        link = thisLink if link == nil
                    end
                end
                
            when :text
                links.each do |thisLink|
                    if what.matches(thisLink.innerText.strip) 
                        link = thisLink if link == nil
                    end
                end
                
            when :id
                links.each do |thisLink|
                    if what.matches(thisLink.invoke("id"))
                        link = thisLink if link == nil
                    end
                end
            when :name
                links.each do |thisLink|
                    if what.matches(thisLink.invoke("name"))
                        link = thisLink if link == nil
                    end
                end

            when :title
                links.each do |thisLink|
                    if what.matches(thisLink.invoke("title"))
                        link = thisLink if link == nil
                    end
                end
                
            when :beforeText
                links.each do |thisLink|
                    if what.matches(thisLink.getAdjacentText("afterEnd").strip)
                        link = thisLink if link == nil
                    end
                end

            when :afterText
                links.each do |thisLink|
                    if what.matches(thisLink.getAdjacentText("beforeBegin").strip)
                        link = thisLink if link == nil
                    end
                end
            else
                raise MissingWayOfFindingObjectException, "#{how.inspect} is an unknown way of finding a link ( #{what} )"
            end
            
            # if no link found, link will be a nil.  This is OK.  Actions taken on links (e.g. "click") should rescue 
            # the nil-related exceptions and provide useful information to the user.
            return link
        
        end

        # This method is used iternally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
        #
        # This method gets a table row or cell 
        #   * how  - symbol - how we get the link row or cell types are:
        #            id
        #   * what -  a string or regexp 
        def getTablePart( part , how , what )
             doc = document
             parts = doc.all.tags( part )
             n = nil
             parts.each do | p |
                 next unless n==nil
                 if what.matches( p.invoke("id") )
                     n = p 
                 end
             end
             return n
        end

        # This method is used iternally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
        #
        # this method is used to get elements like SPAN or DIV
        def getNonControlObject(part , how, what )

             doc = document
             parts = doc.all.tags( part )
             n = nil
             case how
                when :id
                    attribute = "id"
                when :name
                    attribute = "name"
                when :title
                    attribute = "title"
                when :for   # only applies to labels
                    attribute = "htmlFor"
              end

              if attribute
                 parts.each do | p |
                     next unless n==nil
                     n = p if what.matches( p.invoke(attribute) )
                 end
              elsif how == :index
                  count = 1
                  parts.each do | p |
                     next unless n==nil
                     n = p if what == count
                     count +=1
                  end
              else
                  raise MissingWayOfFindingObjectException, "unknown way of finding a #{ part} ( {what} )"
              end
            return n

        end

    end

    
    # This class is the main Internet Explorer Controller
    # An instance of this must be created to access Internet Explorer.
    class IE
        include Watir::Exception
        include SupportsSubElements 

        # The revision number ( according to CVS )
        REVISION = "$Revision$"

        # the Release number
        VERSION = "1.4"
        
        # Used internally to determine when IE has finished loading a page
        READYSTATE_COMPLETE = 4         
        
        # The default delay when entering text on a web page.
        DEFAULT_TYPING_SPEED = 0.08
        
        # The default time we wait after a page has loaded.
        DEFAULT_SLEEP_TIME = 0.1
        
        # The default color for highlighting objects as they are accessed.
        DEFAULT_HIGHLIGHT_COLOR = "yellow"
        
        # This is used to change the typing speed when entering text on a page.
        attr_accessor :typingspeed
        
        # This is used to change how long after a page has finished loading that we wait for.
        attr_accessor :defaultSleepTime
        
        # The color we want to use for the active object. This can be any valid web-friendly color.
        attr_accessor :activeObjectHighLightColor

        # use this to switch the spinner on and off
        attr_accessor :enable_spinner

        # use this to get the time for the last page download
        attr_reader :down_load_time
        
        # When a new window is created it is stored in newWindow
        attr_accessor :newWindow

        # Use this to gain access to the 'raw' internet explorer object.        
        attr_reader :ie

        # access to the logger object
        attr_accessor :logger


        # this contains the list of unique urls that have been visited
        attr_reader :url_list                        

        def initialize(suppress_new_window=nil)
            unless suppress_new_window
                create_browser_window
                set_defaults
            end
        end
        
        # Create a new IE Window, starting at the specified url.
        # If no url is given, start empty.
        def IE.start( url = nil )
            ie = new
            ie.goto(url) if url
            return ie
        end
        
        # Attach to an existing IE window, either by url or title.
        # IE.attach(:url, 'http://www.google.com')
        # IE.attach(:title, 'Google') 
        def IE.attach(how, what)
            ie = new(true) # don't create window
            ie.attach_init(how, what)
            return ie
        end   

        # this method is used internally to attach to an existing window
        # dont make private
        def attach_init( how, what )
            attach_browser_window(how, what)
            set_defaults
            wait                        
        end        
        
        def set_defaults
            @form = nil

            @enable_spinner = $ENABLE_SPINNER
            @error_checkers= []

            @ie.visible = ! $HIDE_IE
            @activeObjectHighLightColor = DEFAULT_HIGHLIGHT_COLOR
            if $FAST_SPEED
                set_fast_speed
            else
                set_slow_speed
            end

            @logger = DefaultLogger.new()

            @url_list = []

            # add an error checker for http navigation errors, such as 404, 500 etc
            navigation_checker=Proc.new{ |ie|
                if ie.document.frames.length > 1
                    1.upto ie.document.frames.length do |i|
                        check_for_http_error(ie.frame(:index, i)  )
                    end
                else
                    check_for_http_error(ie)
                end
             }

            add_checker(  navigation_checker )       

        end
        private :set_defaults        
        
        # This method checks the currently displayed page for http errors, 404, 500 etc
        # It gets called internally by the wait method, so a user does not need to call it explicitly
        def check_for_http_error(ie)
            url=ie.document.url 
            #puts "url is " + url
            if /shdoclc.dll/.match(url)
                #puts "Match on shdoclc.dll"
                m = /id=IEText.*?>(.*?)</i.match(ie.html)
                if m
                    #puts "Error is #{m[1]}"
                    raise NavigationException , m[1]
                end
            end
        end

        def set_fast_speed
            @typingspeed = 0
            @defaultSleepTime = 0.01
        end            

        def set_slow_speed
            @typingspeed = DEFAULT_TYPING_SPEED
            @defaultSleepTime = DEFAULT_SLEEP_TIME
        end
        
        def create_browser_window
            @ie = WIN32OLE.new('InternetExplorer.Application')
        end
        private :create_browser_window

        def attach_browser_window( how, what )
            log "Seeking Window with #{how}: #{ what }"
            shell = WIN32OLE.new("Shell.Application")
            appWindows = shell.Windows()
            
            ieTemp = nil
            appWindows.each do |aWin| 
                log "Found a window: #{aWin}. "
                
                case how
                when :url
                    log " url is: #{aWin.locationURL}\n"
                    ieTemp = aWin if (what.matches(aWin.locationURL) )
                when :title
                    # normal windows explorer shells do not have document
                    title = nil
                    begin
                        title = aWin.document.title
                    rescue WIN32OLERuntimeError
                    end
                    ieTemp = aWin if (what.matches( title ) ) 
                else
                    raise ArgumentError
                end
            end

            #if it can not find window
            if ieTemp == nil
                 raise NoMatchingWindowFoundException,
                 "Unable to locate a window with #{ how} of #{what}"
            end
            @ie = ieTemp
        end
        private :attach_browser_window

        # deprecated: use logger= instead
        def set_logger( logger )
            @logger = logger
        end

        def log ( what )
            @logger.debug( what ) if @logger
        end
        
        # Deprecated: Use IE#ie instead
        # This method returns the Internet Explorer object. 
        # Methods, properties,  etc. that the IE object does not support can be accessed.
        def getIE()
            return @ie
        end
        
        #
        # Accessing data outside the document
        #
        
        # Return the title of the window
        def title
            @ie.document.title
        end
        
        # Return the status of the window, typically from the status bar at the bottom.
        def status
            raise NoStatusBarException if !@ie.statusBar
            return @ie.statusText()
        end

        #
        # Navigation
        #

        # Navigate to the specified URL.
        #  * url  - string - the URL to navigate to
        def goto( url )
            @ie.navigate(url)
            wait()
            sleep 0.2
            return @down_load_time
        end
        
        # Go to the previous page - the same as clicking the browsers back button
        # an WIN32OLERuntimeError exception is raised if the browser cant go back
        def back
            @ie.GoBack()
            wait
        end

        # Go to the next page - the same as clicking the browsers forward button
        # an WIN32OLERuntimeError exception is raised if the browser cant go forward
        def forward
            @ie.GoForward()
            wait
        end
        
        # Refresh the current page - the same as clicking the browsers refresh button
        # an WIN32OLERuntimeError exception is raised if the browser cant refresh
        def refresh
            @ie.refresh2(3)
            wait
        end
        
        # clear the list of urls that we have visited
        def clear_url_list
            @url_list.clear
        end

        # Closes the Browser
        def close
            @ie.quit
        end
        
        # Maximize the window (expands to fill the screen)
        def maximize; set_window_state (:SW_MAXIMIZE); end
        
        # Minimize the window (appears as icon on taskbar)
        def minimize; set_window_state (:SW_MINIMIZE); end

        # Restore the window (after minimizing or maximizing)
        def restore;  set_window_state (:SW_RESTORE);  end
        
        def set_window_state (state)
    		autoit = WIN32OLE.new('AutoItX3.Control')
		    autoit.WinSetState title, '', autoit.send(state)			
        end
        private :set_window_state
                
		# Send key events to IE window. 
		# See http://www.autoitscript.com/autoit3/docs/appendix/SendKeys.htm
		# for complete documentation on keys supported and syntax.
        def send_keys (key_string)
            autoit = WIN32OLE.new 'AutoItX3.Control' 
            autoit.WinActivate title
            autoit.Send key_string
        end

        # used by the popup code only
        def dir
            return File.expand_path(File.dirname(__FILE__))
        end
        
        #
        # Document and Document Data
        #
        
        # Return the current document
        def document
            return @ie.document
        end
           
        # returns the current url, as displayed in the address bar of the browser 
        def url
            return @ie.LocationURL
        end

        # Search the current page for specified text or regexp.
        # Returns true if the specified text was found.
        # Returns matchdata object if the specified regexp was found.
        #  * text - string or regular expression - the string to look for
        def contains_text(text)
            returnValue = false
            retryCount = 0
            begin
                retryCount += 1
                returnValue = 
                if text.kind_of? Regexp
                    document.body.innerText.match(text)
                elsif text.kind_of? String
                    document.body.innerText.index(text)
                else
                    raise MissingWayOfFindingObjectException
                end 
            rescue MissingWayOfFindingObjectException => e
                raise e
            rescue
                retry if retryCount < 2 
            end
            return returnValue
        end

        # 
        # Synchronization
        #
        
        # This method is used internally to cause an execution to stop until the page has loaded in Internet Explorer.
        def wait( noSleep  = false )
            begin
                @down_load_time=0
                pageLoadStart = Time.now
                @pageHasReloaded= false
                
                s= Spinner.new(@enable_spinner)
                while @ie.busy
                    @pageHasReloaded = true
                    sleep 0.02
                    s.spin
                end
                s.reverse
                
                log "wait: readystate=" + @ie.readyState.to_s 
                until @ie.readyState == READYSTATE_COMPLETE
                    @pageHasReloaded = true
                    sleep 0.02
                    s.spin
                end
                sleep 0.02
                
                until @ie.document.readyState == "complete"
                    sleep 0.02
                    s.spin
                end
                
                
                if @ie.document.frames.length > 1
                    begin
                        0.upto @ie.document.frames.length-1 do |i|
                            until @ie.document.frames[i.to_s].document.readyState == "complete"
                                sleep 0.02
                                s.spin
                            end
                            @url_list << @ie.document.frames[i.to_s].document.url unless url_list.include?(@ie.document.frames[i.to_s].document.url)
                        end
                    rescue=>e
                        @logger.warn 'frame error in wait'   + e.to_s + "\n" + e.backtrace.join("\n")
                    end
                else
                    @url_list << @ie.document.url unless @url_list.include?(@ie.document.url)
                end
                @down_load_time =  Time.now - pageLoadStart 

                run_error_checks

                print "\b" unless @enable_spinner == false
                
                s=nil
            rescue WIN32OLERuntimeError => e
                @logger.info "runtime error in wait: #{e}\n#{e.backtrace.join("\\\n")}"
            end
            sleep 0.01
            sleep @defaultSleepTime unless noSleep  == true
        end

        # Error checkers

        # this method runs the predefined error checks
        def run_error_checks
            @error_checkers.each do |e|
                e.call(self)
            end
        end

        # this method is used to add an error checker that gets executed on every page load
        # *  checker   Proc Object, that contains the code to be run 
        def add_checker( checker) 
            @error_checkers << checker
        end
        
        # this allows a checker to be disabled
        # *  checker   Proc Object, the checker that is to be disabled
        def disable_checker( checker )
            @error_checkers.delete(checker)
        end

        # The HTML of the current page
        def html
            return document.body.outerHTML
        end
        
        # The text of the current document
        def text
            return document.body.innerText.strip
        end

        #
        # Show me state
        #        
        
        # This method is used to display the available html frames that Internet Explorer currently has loaded.
        # This method is usually only used for debugging test scripts.
        def show_frames
            if allFrames = document.frames
                count = allFrames.length
                puts "there are #{count} frames"
                for i in 0..count-1 do  
                    begin
                        fname = allFrames[i.to_s].name.to_s
                        puts "frame  index: #{i+1} name: #{fname}"
                    rescue => e
                        puts "frame  index: #{i+1} --Access Denied--" if e.to_s.match(/Access is denied/)
                    end
                end
            else
                puts "no frames"
            end
        end
        
        # Show all forms displays all the forms that are on a web page.
        def show_forms
            if allForms = document.forms
                count = allForms.length
                puts "There are #{count} forms"
                for i in 0..count-1 do
                    wrapped = FormWrapper.new(allForms.item(i))
                    puts "Form name: #{wrapped.name}"
                    puts "       id: #{wrapped.id}"
                    puts "   method: #{wrapped.method}"
                    puts "   action: #{wrapped.action}"
                end
            else
                puts "No forms"
            end
        end

        # this method shows all the images availble in the document
        def show_images
            doc = document
            index=1
            doc.images.each do |l|
                puts "image: name: #{l.name}"
                puts "         id: #{l.invoke("id")}"
                puts "        src: #{l.src}"
                puts "      index: #{index}"
                index+=1
            end
        end
        
        # this method shows all the links availble in the document
        def show_links 

            props=       ["name" ,"id" , "href"  ]
            print_sizes= [12 , 12, 60]
            doc = document
            index=0
            text_size = 60
            # draw the table header
            s = "index".ljust(6) 
            props.each_with_index do |p,i|
                s=s+ p.ljust(print_sizes[i]) 
            end
            s=s + "text/src".ljust(text_size)
            s=s+"\n"

            # now get the details of the links
            doc.links.each do |n|
                index+=1
                s = s + index.to_s.ljust(6)
                props.each_with_index do |prop,i|
                    printsize=print_sizes[i]
                    begin
                        p = n.invoke(prop)
                         temp_var = "#{p}".to_s.ljust(printsize)
                    rescue
                        # this object probably doesnt have this property
                         temp_var = "".to_s.ljust(printsize)
                    end
                    s =s+ temp_var
                end
                s=s+  n.innerText
                if n.getElementsByTagName("IMG").length > 0
                     s=s+  " / " + n.getElementsByTagName("IMG")[0.to_s].src
                end
                s=s+"\n"
            end
            puts  s
        end

        # this method shows the name, id etc of the object that is currently active - ie the element that has focus
        # its mostly used in irb when creating a script
        def show_active
            s = "" 
            
            current = document.activeElement
            begin
                s=s+current.invoke("type").to_s.ljust(16)
            rescue
            end
            props=["name", "id", "value", "alt", "src", "innerText", "href"]
            props.each do |prop|
                begin
                    p = current.invoke(prop)
                    s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
                rescue
                    #this object probably doesnt have this property
                end
            end
            s=s+"\n"
        end
        
        # This method shows the available objects on the current page.
        # This is usually only used for debugging or writing new test scripts.
        # This is a nice feature to help find out what HTML objects are on a page
        # when developing a test case using Watir.
        def show_all_objects
            puts "-----------Objects in  page -------------" 
            doc = document
            s = ""
            props=["name" ,"id" , "value" , "alt" , "src"]
            doc.all.each do |n|
                begin
                    s=s+n.invoke("type").to_s.ljust(16)
                rescue
                    next
                end
                props.each do |prop|
                    begin
                        p = n.invoke(prop)
                        s =s+ "  " + "#{prop}=#{p}".to_s.ljust(18)
                    rescue
                        # this object probably doesnt have this property
                    end
                end
                s=s+"\n"
            end
            puts s+"\n\n\n"
        end

        # this method shows all the divs availble in the document
        def show_divs
            divs = document.getElementsByTagName("DIV")
            puts "Found #{divs.length} div tags"
            index=1
            divs.each do |d|
                puts "#{index}  id=#{d.invoke('id')}      class=#{d.invoke("className")}"
                index+=1
            end
        end

        # this method is used to show all the tables that are available
        def show_tables
            tables = document.getElementsByTagName("TABLE")
            puts "Found #{tables.length} tables"
            index=1
            tables.each do |d|
                puts "#{index}  id=#{d.invoke('id')}      rows=#{d.rows.length}   columns=#{d.rows["0"].cells.length }"
                index+=1
            end
        end

        # this method shows all the spans availble in the document
        def show_spans
            spans = document.getElementsByTagName("SPAN")
            puts "Found #{spans.length} span tags"
            index=1
            spans.each do |d|
                puts "#{index}   id=#{d.invoke('id')}      class=#{d.invoke("className")}"
                index+=1
            end
        end

        def show_labels
            labels = document.getElementsByTagName("LABEL")
            puts "Found #{labels.length} label tags"
            index=1
            labels.each do |d|
                puts "#{index}  text=#{d.invoke('innerText')}      class=#{d.invoke("className")}  for=#{d.invoke("htmlFor")}"
                index+=1
            end
        end

        #
        # This method gives focus to the frame
        # It may be removed and become part of the frame object
        def focus
            document.activeElement.blur
            document.focus
        end
       
    end # class IE
        
    # 
    # MOVETO: watir/popup.rb
    # Module Watir::Popup
    #
    
    # POPUP object
    class PopUp
        def initialize( ieController )
            @ieController = ieController
        end
        
        def button( caption )
            return JSButton.new(  @ieController.getIE.hwnd , caption )
        end
    end
    
    class JSButton 
        def initialize( hWnd , caption )
            @hWnd = hWnd
            @caption = caption
        end
        
        def startClicker( waitTime = 3 )
            clicker = WinClicker.new
            clicker.clickJSDialog_Thread
            # clickerThread = Thread.new( @caption ) {
            #   sleep waitTime
            #   puts "After the wait time in startClicker"
            #   clickWindowsButton_hwnd(hwnd , buttonCaption )
            #}
        end
    end
    
    # 
    # Module Watir::Control or Watir::BrowserDriver
    #

    class Frame < IE
    
        def initialize(container, how, what)
            @container = container
            @frame = nil

            frames = @container.document.frames

            for i in 0 .. frames.length-1
                next unless @frame == nil
                this_frame = frames.item(i)
                if how == :index 
                    if i+1 == what
                        @frame = this_frame
                    end
                elsif how == :name
                    begin
                        if what.matches(this_frame.name)
                            @frame = this_frame
                        end
                    rescue # access denied?
                    end
                elsif how == :id
                    # BUG: Won't work for IFRAMES
                    if what.matches(@container.document.getElementsByTagName("FRAME").item(i).invoke("id"))
                        @frame = this_frame
                    end
                else
                    raise ArgumentError, "Argument #{how} not supported"
                end
            end
            
            unless @frame
                raise UnknownFrameException , "Unable to locate a frame with name #{ what} " 
            end

            @typingspeed = container.typingspeed      
            @activeObjectHighLightColor = container.activeObjectHighLightColor      
        end

        def ie
            return @frame
        end

        def document
            @frame.document
        end

        def wait(no_sleep = false)
            @container.wait(no_sleep)
        end
    end
    

    # Forms

    module FormAccess
        def name
            @form.getAttributeNode('name').value
        end
        def action
            @form.action
        end
        def method
            @form.invoke('method')
        end
        def id
            @form.invoke("id").to_s
        end
    end        
        
    # wraps around a form OLE object
    class FormWrapper
        include FormAccess
        def initialize ( ole_object )
            @form = ole_object
        end
    end
       
    #   Form Factory object 
    class Form < IE
        include FormAccess

        attr_accessor :form


        #   * container   - the containing object, normally an instance of IE
        #   * how         - symbol - how we access the form (:name, :id, :index, :action, :method)
        #   * what        - what we use to access the form
        def initialize( container, how, what )
            @container = container
            @formHow = how
            @formName = what
            
            log "Get form  formHow is #{@formHow}  formName is #{@formName} "
            count = 1
            doc = @container.document
            doc.forms.each do |thisForm|
                next unless @form == nil

                wrapped = FormWrapper.new(thisForm)

                log "form on page, name is " + wrapped.name
                
                @form =
                case @formHow
                when :name 
                    wrapped.name == @formName ? thisForm : nil
                when :id
                    wrapped.id == @formName.to_s ? thisForm : nil
                when :index
                    count == @formName.to_i ? thisForm : nil
                when :method
                    wrapped.method.downcase == @formName.downcase ? thisForm : nil
                when :action
                    @formName.matches(wrapped.action) ? thisForm : nil
                else
                    raise MissingWayOfFindingObjectException
                end
                count = count +1
            end
            
            @typingspeed = @container.typingspeed      
            @activeObjectHighLightColor = @container.activeObjectHighLightColor      
        end

        def exists?
            @form ? true : false
        end
        
        # Submit the data -- equivalent to pressing Enter or Return to submit a form. 
        def submit
            raise UnknownFormException ,  "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
            @form.submit 
            @container.wait
        end   

        def getContainerContents
            raise UnknownFormException , "Unable to locate a form using #{@formHow} and #{@formName} " if @form == nil
            @form.elements.all
        end   
        private :getContainerContents

        def getContainer
            return @form
        end

        def wait(no_sleep = false)
            @container.wait(no_sleep)
        end
                
        # This method is responsible for setting and clearing the colored highlighting on the specified form.
        # use :set   to set the highlight
        #   :clear  to clear the highlight
        def highLight( setOrClear  , element , count)

            if setOrClear == :set
                begin
                    original_color = element.style.backgroundColor
                    original_color = "" if original_color== nil
                    element.style.backgroundColor = activeObjectHighLightColor
                rescue => e
                    puts e 
                    puts e.backtrace.join("\n")
                    original_color = ""
                end
                @original_styles[ count ] = original_color 
            else
                begin 
                    element.style.backgroundColor  = @original_styles[ count]
                rescue => e
                    puts e
                    # we could be here for a number of reasons...
                ensure
                end
            end
        end
        private :highLight

        # causes the object to flash. Normally used in IRB when creating scripts        
        def flash
            @original_styles = {}
            10.times do
                count=0
                @form.elements.each do |element|
                    highLight(:set , element , count)
                    count +=1
                end
                sleep 0.05
                count = 0
                @form.elements.each do |element|
                    highLight(:clear , element , count)
                    count +=1
                end
                sleep 0.05
            end
        end
                
    end # class Form
    
    # Base class for most elements.
    # This is not a class that users would normally access. 
    class Element
        include Watir::Exception
        
        # number of spaces that seperate the property from the value in the to_s method
        TO_S_SIZE = 14
        
        #   o  - the ole object for the element being wrapped
        def initialize( o )
            @o = o
            @originalColor = nil
        end
        
        private
        def self.def_wrap(method_name)
            class_eval "def #{method_name}
                          assert_exists
                          @o.invoke('#{method_name}')
                        end"
        end
        def self.def_wrap_guard(method_name)
            class_eval "def #{method_name}
                          assert_exists
                          begin
                            @o.invoke('#{method_name}')
                          rescue
                            ''
                          end
                        end"
        end
        def assert_exists
            unless @o
                raise UnknownObjectException.new("Unable to locate object, using #{@how} and #{@what}")
            end
        end
        def assert_enabled
            unless enabled?
                raise ObjectDisabledException, "object #{@how} and #{@what} is disabled"
            end                
        end

        public
        def_wrap_guard :type        
        def_wrap_guard :name
        def_wrap :id
        def_wrap :disabled
        def_wrap_guard :value
        def_wrap_guard :title

        # returns the Object in its OLE form, allowing any methods of the DOM that Watir doesnt support to be used    
        #--    
        # BUG: should be renamed appropriately and then use an attribute reader
        #++
        def getOLEObject
            return @o
        end
  
        # returns the outer html of the object - see http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/outerhtml.asp?frame=true
        def html
            assert_exists
            return @o.outerHTML
        end

        # Returns an array with many of the properties, in a format to be used by the to_s method
        def string_creator
            n = []
            n <<   "type:".ljust(TO_S_SIZE) + self.type
            n <<   "id:".ljust(TO_S_SIZE) +         self.id.to_s
            n <<   "name:".ljust(TO_S_SIZE) +       self.name.to_s
            n <<   "value:".ljust(TO_S_SIZE) +      self.value.to_s
            n <<   "disabled:".ljust(TO_S_SIZE) +   self.disabled.to_s
            return n
        end
        
        # This method displays basic details about the object. Sample output for a button is shown.
        # Raises UnknownObjectException if the object is not found.
        #      name      b4
        #      type      button
        #      id         b5
        #      value      Disabled Button
        #      disabled   true
        def to_s
            assert_exists
            return string_creator.join("\n")
        end
        
        # This method is responsible for setting and clearing the colored highlighting on the currently active element.
        # use :set   to set the highlight
        #   :clear  to clear the highlight
        def highLight( setOrClear )
            if setOrClear == :set
                begin
                    @originalColor = @o.style.backgroundColor
                    @o.style.backgroundColor = @ieController.activeObjectHighLightColor
                rescue 
                    @originalColor = nil
                end
            else # BUG: assumes is :clear, but could actually be anything
                begin 
                    @o.style.backgroundColor = @originalColor unless @originalColor == nil
                rescue
                    # we could be here for a number of reasons...
                ensure
                    @originalColor = nil
                end
            end
        end
        private :highLight
        
        #   This method clicks the active element.
        #   raises: UnknownObjectException  if the object is not found
        #   ObjectDisabledException if the object is currently disabled
        def click
            assert_exists
            assert_enabled
           
            highLight(:set)
            @o.click()
            @ieController.wait()
            highLight(:clear)
        end

        # causes the object to flash. Normally used in IRB when creating scripts        
        def flash
            assert_exists
            10.times do
                highLight(:set)
                sleep 0.05
                highLight(:clear)
                sleep 0.05
            end
            nil
        end
        
        # This method executes a user defined "fireEvent" for objects with JavaScript events tied to them such as DHTML menus.
        #   usage: allows a generic way to fire javascript events on page objects such as "onMouseOver", "onClick", etc.
        #   raises: UnknownObjectException  if the object is not found
        #           ObjectDisabledException if the object is currently disabled
        def fireEvent(event)
            assert_exists
            assert_enabled

            highLight(:set)
            @o.fireEvent(event)
            @ieController.wait()
            highLight(:clear)
        end
        alias fire_event fireEvent
        
        # This method sets focus on the active element.
        #   raises: UnknownObjectException  if the object is not found
        #           ObjectDisabledException if the object is currently disabled
        def focus()
            assert_exists
            assert_enabled
            @o.focus()
        end
        
        # This methods checks to see if the current element actually exists. 
        def exists?
            @o? true: false
        end
        
        # Returns true if the element is enabled, false if it isn't.
        #   raises: UnknownObjectException  if the object is not found
        def enabled?
            assert_exists
            return ! @o.invoke("disabled")
        end
    end


    # this class is the super class for the iterator classes ( buttons, links, spans etc
    # it would normally only be accessed by the iterator methods ( spans , links etc) of IE
    class ElementCollections
        include Enumerable

        # Super class for all the iteractor classes
        #   * ieController  - an instance of an IE object
        def initialize( ieController)
            @ieController = ieController
            @length = length() # defined by subclasses

            # set up the items we want to display when the show method s used
            set_show_items
        end
 
        def set_show_items
            @show_attributes = AttributeLengthPairs.new( "id" , 20)
            @show_attributes.add( "name" , 20)
        end

        def get_length_of_input_objects(object_type) 
            object_types = 
                if object_type.kind_of? Array 
                    object_type  
                else
                    [ object_type ]
                end

            length = 0
            objects = @ieController.getContainer.getElementsByTagName("INPUT")
            if  objects.length > 0 
                objects.each do |o|
                   length += 1 if object_types.include?(o.invoke("type").downcase )
                end
            end    
            return length
        end

        # iterate through each of the elements in the collection in turn
        def each
            0.upto( @length-1 ) { |i | yield iterator_object(i) }
        end

        # allows access to a specific item in the collection
        def [](n)
            return iterator_object(n-1)
        end

        # this method is the way to show the objects, normally used from irb
        def show
            s="index".ljust(6)
            @show_attributes.each do |attribute_length_pair| 
                s=s + attribute_length_pair.attribute.ljust(attribute_length_pair.length)
            end

            index = 1
            self.each do |o|
                s= s+"\n"
                s=s + index.to_s.ljust(6)
                @show_attributes.each do |attribute_length_pair| 
                    begin
                        s=s  + eval( 'o.getOLEObject.invoke("#{attribute_length_pair.attribute}")').to_s.ljust( attribute_length_pair.length  )
                    rescue=>e
                        s=s+ " ".ljust( attribute_length_pair.length )
                    end
                end
                index+=1
            end
            puts s 
        end

        # this method creates an object of the correct type that the iterators use
        private
        def iterator_object(i)
            element_class.new(@ieController, :index, i+1)
        end
    end

    # this class contains items that are common between the span and div objects
    # it would not normally be used directly
    #
    # many of the methods available to this object are inherited from the Element class
    #
    class SpanDivCommon < Element
        include Watir::Exception
        include SupportsSubElements 

        attr_reader :typingspeed      

        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            @o = @ieController.getNonControlObject(tag , @how, @what )
            super( @o )
            @typingspeed = @ieController.typingspeed      
            @activeObjectHighLightColor = @ieController.activeObjectHighLightColor      
        end

        def getContainerContents()
            return @o.all
        end
        private :getContainerContents

        def getContainer()
            return @o
        end

        # this method returns the innerText of the object
        # raises an ObjectNotFound exception if the object cannot be found
        def text
            assert_exists
            return @o.innerText.strip
        end

        # returns the class name of the span or div is using
        # raises an ObjectNotFound exception if the object cannot be found
        def class_name
            assert_exists
            return @o.invoke("className")
        end

        # this method returns the type of  object
        # raises an ObjectNotFound exception if the object cannot be found
        def type
            assert_exists
            return self.class.name[self.class.name.index("::")+2 .. self.class.name.length ]
        end

        # this method is used to populate the properties in the to_s method
        def span_div_string_creator
            n = []
            n <<   "class:".ljust(TO_S_SIZE) + self.class_name
            n <<   "text:".ljust(TO_S_SIZE) + self.text
            return n
         end
         private :span_div_string_creator

         # returns the properties of the object in a string
         # raises an ObjectNotFound exception if the object cannot be found
         def to_s
            assert_exists
            r = string_creator
            r=r + span_div_string_creator
            return r.join("\n")
         end
    end

    class P < SpanDivCommon 
        TAG = 'P'
        def tag; TAG; end
        def self.tag; TAG; end
    end

    # this class is used to deal with Div tags in the html page. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
    # It would not normally be created by users
    class Div < SpanDivCommon 
        TAG = 'DIV'
        def tag; TAG; end
        def self.tag; TAG; end
    end

    # this class is used to deal with Span tags in the html page. It would not normally be created by users
    class Span < SpanDivCommon 
        TAG = 'SPAN'
        def tag; TAG; end
        def self.tag; TAG; end
    end

    # this class is used to access a label object on the html page - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
    #
    # many of the methods available to this object are inherited from the Element class
    #
    class Label < Element
        def initialize( ieController , how, what)
            @ieController = ieController
            @how = how
            @what = what
            @o = @ieController.getNonControlObject("LABEL" , @how, @what )
            super( @o )
        end

        # return the type of this object
        def type
            assert_exists
            return "Label"
        end

        # return the ID of the control that this label is associated with
        def for
            assert_exists
            return @o.htmlFor
        end

        def text
            assert_exists
            return @o.innerText.strip
        end
        alias innerText :text

        # this method is used to populate the properties in the to_s method
        def label_string_creator
            n = []
            n <<   "for:".ljust(TO_S_SIZE) + self.for
            n <<   "inner text:".ljust(TO_S_SIZE) + self.innerText
            return n
        end
        private :label_string_creator

        # returns the properties of the object in a string
        # raises an ObjectNotFound exception if the object cannot be found
        def to_s
            assert_exists
            r = string_creator
            r=r + label_string_creator
            return r.join("\n")
        end

    end

    # This class is used for dealing with tables.
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#table method
    #
    # many of the methods available to this object are inherited from the Element class
    #
    class Table < Element
 
        # Returns an initialized instance of the table object to wich anElement belongs
        #   * ieController  - an instance of an IE object
        #   * anElement     - a Watir object (TextField, Button, etc.)
        def Table.create_from_element(ieController,anElement)
            o = anElement.getOLEObject.parentElement
            while(o && o.tagName != 'TABLE')
                o = o.parentElement
            end
            return Table.new(ieController,:from_object,o)
        end

        # Returns an initialized instance of a table object
        #   * parent      - an instance of an IEController ( or a frame etc )
        #   * how         - symbol - how we access the table
        #   * what         - what we use to access the table - id, name index etc 
        def initialize( parent,  how , what )
            @ieController = parent
            @how = how
            @what = what

            table = nil

	      if(@how != :from_object) then
               table=get_table
	      else
		    table = @what
	      end

            parent.log "table - #{@what}, #{@how} Not found " if table ==  nil
            @o = table
            super( @o )
        end

        # --- 
        # BUG: should be private
        # +++
        # this method finds the specified table on the page
        def get_table
                allTables = @ieController.document.getElementsByTagName("TABLE")
                @ieController.log "There are #{ allTables.length } tables"
                tableIndex = 1
                table=nil
                allTables.each do |t|
                    next  unless table == nil
                    case @how
                        when :id
                        if @what.matches( t.invoke("id").to_s )
                            table = t
                        end
                        when :index
                        if tableIndex == @what.to_i
                            table = t
                        end
                    end
                    tableIndex = tableIndex + 1
                end
            return table
        end


        # override the highlight method, as if the tables rows are set to have a background color, 
        # this will override the table background color,  and the normal flsh method wont work
        def highLight(setOrClear )

           if setOrClear == :set
                begin
                    @original_border = @o.border.to_i
                    if @o.border.to_i==1
                        @o.border = 2
                    else
                        @o.border=1
                    end
                rescue
                    @original_border = nil
                end
            else
                begin 
                    @o.border= @original_border unless @original_border == nil
                    @original_border = nil
                rescue
                    # we could be here for a number of reasons...
                ensure
                    @original_border = nil
                end
            end
            super    
        end

        # this method is used to ppulate the properties in the to_s method
        def table_string_creator
            n = []
            n <<   "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
            n <<   "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
            return n
        end
        private :table_string_creator

        # returns the properties of the object in a string
        # raises an ObjectNotFound exception if the object cannot be found
        def to_s
            assert_exists
            r = string_creator
            r=r + table_string_creator
            return r.join("\n")
        end

        # iterates through the rows in the table. Yields a TableRow object
        def each
            assert_exists
            1.upto( @o.getElementsByTagName("TR").length ) { |i |  yield TableRow.new(@ieController ,:direct, row(i) )    }
        end
 
        # Returns a row in the table
        #   * index         - the index of the row
        def [](index)
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
            return  TableRow.new(@ieController ,:direct, row(index) )
        end

        # This method returns the number of rows in the table.
        # Raises an UnknownTableException if the table doesnt exist.
        def row_count 
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
            #return table_body.children.length
            return @o.getElementsByTagName("TR").length
        end

        # This method returns the number of columns in a row of the table.
        # Raises an UnknownTableException if the table doesn't exist.
        #   * index         - the index of the row
        def column_count(index=1) 
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
            row(index).cells.length
        end

        # This method returns the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
        # Raises an UnknownTableException if the table doesn't exist.
        def to_a
            raise UnknownTableException ,  "Unable to locate a table using #{@how} and #{@what} " if @o == nil
            y = []
            table_rows = @o.getElementsByTagName("TR")
            for row in table_rows
                x = []
                for td in row.getElementsbyTagName("TD")
                    x << td.innerText.strip
                end
                y << x
            end
            return y
            
        end

        def table_body(index=1)
            return @o.getElementsByTagName('TBODY')[index]
        end
        private :table_body

        def body( how , what )
            return TableBody.new( @ieController, how, what , self)
        end

        def bodies
            return TableBodies.new(@ieController,  :direct , @o)
        end
   
        def row(index)
            return @o.invoke("rows")[(index-1).to_s]
        end
        private :row

        # Returns an array containing all the text values in the specified column
        # Raises an UnknownCellException if the specified column does not exist in every
        # Raises an UnknownTableException if the table doesn't exist.
        # row of the table
        #   * columnnumber  - column index to extract values from
        def column_values(columnnumber)
            return (1..row_count).collect {|idx| self[idx][columnnumber].text}
        end
        
        # Returns an array containing all the text values in the specified row
        # Raises an UnknownTableException if the table doesn't exist.
        #   * rownumber  - row index to extract values from
        def row_values(rownumber)
            return (1..column_count(rownumber)).collect {|idx| self[rownumber][idx].text}
        end

    end


    # this class is a collection of the table body objects that exist in the table
    # it wouldnt normally be created by a user, but gets returned by the bodies method of the Table object
    # many of the methods available to this object are inherited from the Element class
    #
    class TableBodies<Element
        def initialize(ieController, how, what )
            @ieController = ieController
            @o= nil
            if how == :direct
                @o = what     # in this case, @o is the parent table
            end
        end
 
        # returns the number of TableBodies that exist in the table
        def length
            assert_exists
            return @o.tBodies.length
        end

        # returns the n'th Body as a Watir TableBody object
        def []n
            assert_exists
            return TableBody.new( @ieController , :direct , @o.tBodies[(n-1).to_s] )
        end

        def get_IE_table_body_at_index( n )
            return @o.tBodies[(n-1).to_s]
        end

        # iterates through each of the TableBodies in the Table. Yields a TableBody object
        def each
            0.upto( @o.tBodies.length-1 ) { |i | yield TableBody.new( @ieController , :direct , @o.tBodies[i.to_s] )   }
        end

    end


    # this class is a table body
    class TableBody<Element
        def initialize(ieController, how, what, parent_table=nil )
            @ieController = ieController
            @o= nil
            if how == :direct
                @o = what     # in this case, @o is the table body
            elsif how == :index
                @o=parent_table.bodies.get_IE_table_body_at_index( what )
            end
            @rows = []
            update_rows
            super(@o)
        end
 
        # This method updates the internal representation of the table. It can be used on dynamic tables to update the watir representation 
        # after the table has changed
        # BUG: Remove
        def update_rows
            if @o
                @o.rows.each do |oo|
                    @rows << TableRow.new(@ieController, :direct, oo)
                end
            end
        end

        # returns the specified row as a TableRow object
        def []n
            assert_exists
            return TableRow.new( @ieController , :direct , @rows[n-1] )
        end

        # iterates through all the rows in the table body
        def each
            0.upto( @rows.length-1 ) { |i | yield @rows[i]    }
        end

        # returns the number of rows in this table body.
        def length
           return @rows.length
        end
    end


    # this class is a table row
    class TableRow < Element

        # Returns an initialized instance of a table row          
        #   * o  - the object contained in the row
        #   * ieController  - an instance of an IE object       
        #   * how          - symbol - how we access the row        
        #   * what         - what we use to access the row - id, index etc. If how is :direct then what is a Internet Explorer Raw Row 
        def initialize(ieController , how, what)
            @ieController = ieController
            @how = how   
            @what = what   
            @o=nil
            if how == :direct
                @o = what
            else
                @o = ieController.getTablePart( "TR" , how , what )   
            end
            update_row_cells
            super( @o )   
        end
   

        # this method updates the internal list of cells. 
        def update_row_cells
            if @o   # cant call the assert_exists here, as an exists? method call will fail
                @cells=[]
                @o.cells.each do |oo|
                    @cells << TableCell.new(@ieController, :direct, oo)
                end
            end
        end

        # this method iterates through each of the cells in the row. Yields a TableCell object
        def each
            0.upto( @cells.length-1 ) { |i | yield @cells[i]    }
        end

   	  # Returns an element from the row as a TableCell object
        def [](index)
            assert_exists
            raise UnknownCellException , "Unable to locate a cell at index #{index}" if @cells.length < index
            return @cells[(index-1)]
        end

        #defaults all missing methods to the array of elements, to be able to
        # use the row as an array
        def method_missing(aSymbol,*args)
            return @o.send(aSymbol,*args)
        end
   
        def column_count
             @cells.length
        end
    end
 
    # this class is a table cell - when called via the Table object
    class TableCell <Element
        include Watir::Exception
        include SupportsSubElements 

        attr_reader :typingspeed      
        attr_reader :activeObjectHighLightColor 

        # Returns an initialized instance of a table cell          
        #   * ieController  - an  IE object       
        #   * how         - symbol - how we access the cell        
        #   * what         - what we use to access the cell - id, name index etc
        def initialize( ieController,  how , what )   
            @ieController = ieController    
            #puts "How = #{how}"
             if how == :direct
                 @o = what
                 #puts "@o.class=#{@o.class}"
             else
                 @o = ieController.getTablePart( "TD" , how , what )   
             end
             super( @o )   
             @how = how   
             @what = what   
             @typingspeed = @ieController.typingspeed      
             @activeObjectHighLightColor = @ieController.activeObjectHighLightColor      
         end 

        def getContainerContents
            return @o.all
        end
        private :getContainerContents

        def getContainer
            return @o
        end

        def document
            return @o  
        end

        # returns the contents of the cell as text
        def text
             raise UnknownObjectException , "Unable to locate table cell with #{@how} of #{@what}" if @o == nil
             return @o.innerText.strip 
        end
        alias to_s text
 
        def colspan
            @o.colSpan
        end

   end

    # This class is the means of accessing an image on a page.
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#image method
    #
    # many of the methods available to this object are inherited from the Element class
    #
    class Image < Element
        
        # Returns an initialized instance of a image  object
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the image
        #   * what         - what we use to access the image, name, src, index, id or alt
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            @o = @ieController.getImage(@how, @what)
            super( @o )
        end

        # this method produces the properties for an image as an array
        def image_string_creator
            n = []
            n <<   "src:".ljust(TO_S_SIZE) + self.src.to_s
            n <<   "file date:".ljust(TO_S_SIZE) + self.fileCreatedDate.to_s
            n <<   "file size:".ljust(TO_S_SIZE) + self.fileSize.to_s
            n <<   "width:".ljust(TO_S_SIZE) + self.width.to_s
            n <<   "height:".ljust(TO_S_SIZE) + self.height.to_s
            n <<   "alt:".ljust(TO_S_SIZE) + self.alt.to_s
            return n
        end
        private :image_string_creator

        # returns a string representation of the object
        def to_s
            assert_exists
            r = string_creator
            r=r + image_string_creator
            return r.join("\n")
        end

        def_wrap :src

        # this method returns the file created date of the image
        def fileCreatedDate
            assert_exists
            return @o.invoke("fileCreatedDate")
        end

        # this method returns the filesize of the image
        def fileSize
            assert_exists
            return @o.invoke("fileSize").to_s
        end

        # returns the width in pixels of the image, as a string
        def width
            assert_exists
            return @o.invoke("width").to_s
        end

        # returns the alt text of the image
        def alt
            assert_exists
            return @o.invoke("alt").to_s
        end


        # returns the height in pixels of the image, as a string
        def height
            assert_exists
            return @o.invoke("height").to_s
        end

        # returns the type of the object - 'image'
        def type 
            assert_exists
            return "image"
        end
 
        # This method attempts to find out if the image was actually loaded by the web browser. 
        # If the image was not loaded, the browser is unable to determine some of the properties. 
        # We look for these missing properties to see if the image is really there or not. 
        # If the Disk cache is full ( tools menu -> Internet options -> Temporary Internet Files) , it may produce incorrect responses.
        def hasLoaded?
            raise UnknownObjectException ,  "Unable to locate image using #{@how} and #{@what} " if @o==nil
            return false  if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
            return true
        end

        # this method highlights the image ( in fact it adds or removes a border around the image)
        #  * setOrClear   - symbol - :set to set the border, :clear to remove it
        def highLight( setOrClear )
            if setOrClear == :set
                begin
                    @original_border = @o.border
                    @o.border = 1
                rescue
                    @original_border = nil
                end
            else
                begin 
                    @o.border = @original_border 
                    @original_border = nil
                rescue
                    # we could be here for a number of reasons...
                ensure
                    @original_border = nil
                end
            end
        end
        private :highLight

        # This method saves the image to the file path that is given.  The 
        # path must be in windows format (c:\\dirname\\somename.gif).  This method
        # will not overwrite a previously existing image.  If an image already
        # exists at the given path then a dialog will be displayed prompting
        # for overwrite.
        # Raises a WatirException if AutoIt is not correctly installed
        # path - directory path and file name of where image should be saved
        def save(path)
            require 'watir/windowhelper'
            WindowHelper.check_autoit_installed
            @ieController.goto(src)
            begin
                thrd = fill_save_image_dialog(path)
                @ieController.document.execCommand("SaveAs")
                thrd.join(5)
            ensure
                @ieController.back
            end
        end
        
        def fill_save_image_dialog(path)
            Thread.new do 
                system("ruby -e \"require 'win32ole'; @autoit = WIN32OLE.new('AutoItX3.Control'); waitresult = @autoit.WinWait 'Save Picture', '', 15; if waitresult == 1\" -e \"@autoit.ControlSetText 'Save Picture', '', '1148', '#{path}'; @autoit.ControlSend 'Save Picture', '', '1', '{ENTER}';\" -e \"end\"")
            end
        end
        private :fill_save_image_dialog
    end                                                      
    
    
    # This class is the means of accessing a link on a page
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#link method
    # many of the methods available to this object are inherited from the Element class
    #
    class Link < Element
        # Returns an initialized instance of a link object
        #   * ieController  - an instance of an IEController
        #   * how         - symbol - how we access the link
        #   * what         - what we use to access the link, text, url, index etc
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            begin
                @o = @ieController.getLink( @how, @what )
            rescue UnknownObjectException
                @o = nil
            end
            super( @o )
        end

        # returns 'link' as the object type
        def type
            assert_exists
            return "link"
        end

        # returns the text displayed by the link
        def innerText
            assert_exists
            return @o.innerText.strip
        end
        alias text innerText

        # returns the url the link points to
        def_wrap :href

        # if an image is used as part of the link, this will return true      
        def link_has_image
            return true  if @o.getElementsByTagName("IMG").length > 0
            return false
        end

        # this method returns the src of an image, if an image is used as part of the link
        def src
            if @o.getElementsByTagName("IMG").length > 0
                return  @o.getElementsByTagName("IMG")[0.to_s].src
            else
                return ""
            end
        end

        def link_string_creator
            n = []
            n <<   "href:".ljust(TO_S_SIZE) + self.href
            n <<   "inner text:".ljust(TO_S_SIZE) + self.innerText
            n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
            return n
         end

         # returns a textual description of the link
         def to_s
            assert_exists
            r = string_creator
            r=r + link_string_creator
            return r.join("\n")
         end
    end
    
    # This class is the way in which select boxes are manipulated.
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#select_list method
    #
    # many of the methods available to this object are inherited from the Element class
    #
    class SelectList < Element
        # returns an initialized instance of a SelectList object
        #   * ieController  - an instance of an IEController
        #   * how          - symbol - how we access the select box
        #   * what         - what we use to access the select box, name, id etc
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            @o = @ieController.getObject(@how, @what, ["select-one", "select-multiple"])
            super( @o )
        end
        
        attr :o

        # This method clears the selected items in the select box
        def clearSelection
            assert_exists
            highLight( :set)
            wait = false
            @o.each do |selectBoxItem|
                if selectBoxItem.selected
                    selectBoxItem.selected = false
                    wait = true
                end
            end
            @ieController.wait if wait
            highLight( :clear)
        end
#        private :clearSelection
        
        # This method selects an item, or items in a select box, by text.
        # Raises NoValueFoundException   if the specified value is not found.
        #  * item   - the thing to select, string, reg exp or an array of string and reg exps
        def select( item )
            select_item_in_select_list( :text , item )
        end

        # Selects an item, or items in a select box, by value.
        # Raises NoValueFoundException   if the specified value is not found.
        #  * item   - the value of the thing to select, string, reg exp or an array of string and reg exps
        def select_value( item )
            select_item_in_select_list( :value , item )
        end

        # BUG: Should be private
        # Selects something from the select box
        #  * name  - symbol  :value or :text - how we find an item in the select box
        #  * item  - string or reg exp - what we are looking for
        def select_item_in_select_list( attribute, value )
            assert_exists
            highLight( :set )
            doBreak = false
            @ieController.log "Setting box #{@o.name} to #{attribute} #{value} "
            @o.each do |option| # items in the list
                if value.matches( option.invoke(attribute.to_s))
                    if option.selected
                        doBreak = true
                        break
                    else
                        option.selected = true
                        @o.fireEvent("onChange")
                        @ieController.wait
                        doBreak = true
                        break
                    end
                end
            end
            unless doBreak
                raise NoValueFoundException, 
                        "No option with #{attribute.to_s} of #{value} in this select element"  
            end
            highLight( :clear )
        end
        
        # Returns all the items in the select list as an array. 
        # An empty array is returned if the select box has no contents.
        # Raises UnknownObjectException if the select box is not found
        def getAllContents()
            assert_exists
            @ieController.log "There are #{@o.length} items"
            returnArray = []
            @o.each { |thisItem| returnArray << thisItem.text }
            return returnArray 
        end
        
        # Returns the selected items as an array.
        # Raises UnknownObjectException if the select box is not found.
        def getSelectedItems
            assert_exists
            returnArray = []
            @ieController.log "There are #{@o.length} items"
            @o.each do |thisItem|
                if thisItem.selected
                    @ieController.log "Item ( #{thisItem.text} ) is selected"
                    returnArray << thisItem.text 
                end
            end
            return returnArray 
        end
        
        def option (attribute, value)
            Option.new(self, attribute, value)
        end
    end

    module OptionAccess
        def text
            @option.text
        end
        def value
            @option.value
        end
        def selected
            @option.selected
        end
    end

    class OptionWrapper
        include OptionAccess
        def initialize (option)
            @option = option
        end
    end

    # An item in a select list
    class Option
        include OptionAccess
        include Watir::Exception
        def initialize (select_list, attribute, value)
            @select_list = select_list
            @how = attribute
            @what = value
            @option = nil

            unless [:text, :value].include? attribute 
                raise MissingWayOfFindingObjectException,
                    "Option does not support attribute #{@how}"
            end
            @select_list.o.each do |option| # items in the list
                if value.matches( option.invoke(attribute.to_s))
                    @option = option
                    break
                end
            end
                
        end
        def assert_exists
            unless @option
                raise UnknownObjectException,  
                    "Unable to locate an option using #{@how} and #{@what}"
            end
        end
        private :assert_exists
        def select
            assert_exists
            @select_list.select_item_in_select_list(@how, @what)
        end
    end    

    # This is the main class for accessing buttons.
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#button method
    #
    # most of the methods available to Button objects are inherited from the Element class
    #
    class Button < Element
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            if(how == :from_object) then
                @o = what
            else
                @o = @ieController.getObject( @how, @what , object_types)
            end              
            super( @o )
        end

        def object_types
            return ["button" , "submit" , "image" , "reset" ] 
        end

    end

    
    # File dialog
    class FileField < Element
        # Create an instance of the file object
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what
            super( @o )
            @o = @ieController.getObject( @how, @what , ["file"] )

        end

        def set(setPath)
            assert_exists	        
            Thread.new {
                clicker = WinClicker.new
                clicker.setFileRequesterFileName_newProcess(setPath)
            }
            # may need to experiment with this value.  if it takes longer than this
            # to open the new external Ruby process, the current thread may become
            # blocked by the file chooser.
            sleep(1)	
            self.click
        end
    end

    # This class is the class for radio buttons and check boxes. 
    # It contains methods common to both.
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#checkbox or Watir::SupportsSubElements#radio methods
    #
    # most of the methods available to this element are inherited from the Element class
    #
    class RadioCheckCommon < Element

        def initialize( ieController,  how , what , type, value=nil )
            @ieController = ieController
            @how = how
            @what = what
            @type = type
            @value = value
            @o = @ieController.getObject(@how, @what, @type, @value)
            super( @o )
        end

        # This method determines if a radio button or check box is set.
        # Returns true is set/checked or false if not set/checked.
        # Raises UnknownObjectException if its unable to locate an object.
        def isSet?
            assert_exists
            return @o.checked
        end
        alias getState isSet?
        alias checked? isSet?
        
        # This method clears a radio button or check box. Note, with radio buttons one of them will almost always be set.
        # Returns true if set or false if not set.
        #   Raises UnknownObjectException if its unable to locate an object
        #         ObjectDisabledException  IF THE OBJECT IS DISABLED 
        def clear
            assert_exists
            assert_enabled
            highLight( :set)
            set_clear_item( false )
            highLight( :clear )
        end
        
        # This method sets the radio list item or check box.
        #   Raises UnknownObjectException  if its unable to locate an object
        #         ObjectDisabledException  if the object is disabled 
        def set
            assert_exists
            assert_enabled
            highLight( :set)
            set_clear_item( true )
            highLight( :clear )
        end
    
        # This method is the common code for setting or clearing checkboxes and radio. A user would normalyy not access this, but use Checkbox#set etc
        def set_clear_item( set )
            @o.checked = set
            @o.fireEvent("onClick")
            @ieController.wait
        end
        private :set_clear_item
    
    end

    #--
    #  this class is only used to change the name of the class that radio buttons use to something more meaningful
    #  and to make the docs better
    #++
    # This class is the watir representation of a radio button.        
    class Radio < RadioCheckCommon 

    end


    # This class is the watir representation of a check box.
    class CheckBox < RadioCheckCommon 

        # This method, with no arguments supplied, sets the check box.
        # If the optional set_or_clear is supplied, the checkbox is set, when its true and cleared when its false
        #   Raises UnknownObjectException  if its unable to locate an object
        #         ObjectDisabledException  if the object is disabled 
        def set( set_or_clear=true )
            assert_exists
            assert_enabled
            highLight( :set)

            if set_or_clear == true
                if @o.checked == false
                    set_clear_item( true )
                end
            else
                self.clear
            end
            highLight( :clear )
        end
        
        # This method clears a check box. 
        # Returns true if set or false if not set.
        #   Raises UnknownObjectException if its unable to locate an object
        #         ObjectDisabledException  if the object is disabled 
        def clear
            assert_exists
            assert_enabled
            highLight( :set)
            if @o.checked == true
                set_clear_item( false )
            end
            highLight( :clear)
        end
        

    end


    # This class is the main class for Text Fields
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#text_field method
    #
    # most of the methods available to this element are inherited from the Element class
    #
    class TextField < Element
        
        def initialize( ieController,  how , what )
            @ieController = ieController
            @how = how
            @what = what

	      if(how != :from_object) then
                @o = @ieController.getObject(@how, @what, supported_types)
	      else
		    @o = what
	      end
            super( @o )
        end

        def supported_types
            return ["text" , "password", "textarea"] 
        end
        private :supported_types

        def size
            assert_exists
            begin 
                s=@o.size
            rescue
                # TextArea does not support size
                s=""
            end
            return s

        end

        def maxLength
            assert_exists
            begin 
                s=@o.maxlength
            rescue
                # TextArea does not support maxLength
                s=""
            end
            return s
        end

        def text_string_creator
            n = []
            n <<   "length:".ljust(TO_S_SIZE) + self.size.to_s
            n <<   "max length:".ljust(TO_S_SIZE) + self.maxLength.to_s
            n <<   "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s

            return n
         end

         def to_s
            assert_exists
            r = string_creator
            r=r + text_string_creator
            return r.join("\n")
         end
        
        # This method returns true or false if the text field is read only.
        #   Raises  UnknownObjectException if the object can't be found.
        def readonly?
            assert_exists
            return @o.readOnly 
        end
        alias readOnly? :readonly?

        def assert_not_readonly
            raise ObjectReadOnlyException , "Textfield #{@how} and #{@what} is read only"  if self.readonly?
        end                
        #--
        # BUG: rename me
        #++
        # This method returns the current contents of the text field as a string.
        #   Raises  UnknownObjectException if the object can't be found
        def getContents()
            assert_exists
            return self.value
        end
        
        # This method returns true orfalse if the text field contents is either a string match 
        # or a regular expression match to the supplied value.
        #   Raises  UnknownObjectException if the object can't be found
        #   * containsThis - string or reg exp  -  the text to verify 
        def verify_contains( containsThis )
            assert_exists            
            if containsThis.kind_of? String
                return true if self.value == containsThis
            elsif containsThis.kind_of? Regexp
                return true if self.value.match(containsThis) != nil
            end
            return false
        end

        # this method is used to drag the entire contents of the text field to another text field
        #  19 Jan 2005 - It is added as prototype functionality, and may change
        #   * destination_how   - symbol, :id, :name how we identify the drop target 
        #   * destination_what  - string or regular expression, the name, id, etc of the text field that will be the drop target
        def dragContentsTo( destination_how , destination_what)
            assert_exists
            destination = @ieController.textField(destination_how , destination_what)

            raise UnknownObjectException ,  "Unable to locate destination using #{destination_how } and #{destination_what } "   if destination.exists? == false

            @o.focus
            @o.select()
            value = self.value

            @o.fireEvent("onSelect")
            @o.fireEvent("ondragstart")
            @o.fireEvent("ondrag")
            destination.fireEvent("onDragEnter")
            destination.fireEvent("onDragOver")
            destination.fireEvent("ondrop")

            @o.fireEvent("ondragend")
            destination.value= ( destination.value + value.to_s  )
            self.value = ""
        end

        # This method clears the contents of the text box.
        #   Raises  UnknownObjectException if the object can't be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        def clear
            assert_exists
            assert_enabled
            assert_not_readonly
            
            highLight(:set)
            
            @o.scrollIntoView
            @o.focus
            @o.select()
            @o.fireEvent("onSelect")
            @o.value = ""
            @o.fireEvent("onKeyPress")
            @o.fireEvent("onChange")
            @ieController.wait()
            highLight(:clear)
        end
        
        # This method appens the supplied text to the contents of the text box.
        #   Raises  UnknownObjectException if the object cant be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        #   * setThis  - string - the text to append
        def append( setThis)
            assert_exists
            assert_enabled
            assert_not_readonly
            
            highLight(:set)
            @o.scrollIntoView
            @o.focus
            doKeyPress( setThis )
            highLight(:clear)
        end
        
        # This method sets the contents of the text box to the supplied text 
        #   Raises  UnknownObjectException if the object cant be found
        #   Raises  ObjectDisabledException if the object is disabled
        #   Raises  ObjectReadOnlyException if the object is read only
        #   * setThis  - string - the text to set 
        def set( setThis )
            assert_exists
            assert_enabled
            assert_not_readonly
            
            highLight(:set)
            @o.scrollIntoView
            @o.focus
            @o.select()
            @o.fireEvent("onSelect")
            @o.value = ""
            @o.fireEvent("onKeyPress")
            doKeyPress( setThis )
            highLight(:clear)
            @o.fireEvent("onChange")
            @o.fireEvent("onBlur")
        end
        
        # this method sets the value of the text field directly. It causes no events to be fired or exceptions to be raised, so generally shouldnt be used
        # it is preffered to use the set method.
        def value=(v)
            assert_exists
            @o.value = v.to_s
        end

        def fire_key_events
            @o.fireEvent("onKeyDown")
            @o.fireEvent("onKeyPress")
            @o.fireEvent("onKeyUp")
        end
        private :fire_key_events

        # This method is used internally by setText and appendText
        # It should not be used externally.
        #   * value   - string  - The string to enter into the text field
        def doKeyPress( value )
            begin
                maxLength = @o.maxLength
                if value.length > maxLength
                    value = suppliedValue[0 .. maxLength ]
                    @ieController.log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
                end
            rescue
                # probably a text area - so it doesnt have a max Length
                maxLength = -1
            end
            for i in 0 .. value.length-1   
                sleep @ieController.typingspeed   # typing speed
                c = value[i,1]
                #@ieController.log  " adding c.chr " + c  #.chr.to_s
                @o.value = @o.value.to_s + c   #c.chr
                fire_key_events
            end
            
        end
        private :doKeyPress
    end

    # this class can be used to access hidden field objects
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#hidden method
    #
    # most of the methods available to this element are inherited from the Element class
    #
    class Hidden < TextField 

        def initialize( ieController,  how , what )
            super
        end

        def supported_types
            return ["hidden"]
        end
       

        # set is overriden in this class, as there is no way to set focus to a hidden field
        def set(n)
            self.value=n
        end
 
        # override the append method, so that focus isnt set to the hidden object
        def append(n)
            self.value = self.value.to_s + n.to_s
        end

        # override the clear method, so that focus isnt set to the hidden object
        def clear
            self.value = ""
        end

        # this method will do nothing, as you cant set focus to a hidden field
        def focus
            # do nothing!
        end

    end

    #--
    #   These classes are not for public consumption, so we switch off rdoc


    # presumes element_class or element_tag is defined
    # for subclasses of ElementCollections
    module CommonCollection
        def element_tag
            element_class.tag
        end
        def length
            @ieController.getContainer.getElementsByTagName(element_tag).length
        end
    end        
    
    # This class is used as part of the .show method of the iterators class
    # it would not normally be used by a user
    class AttributeLengthPairs
        
        # This class is used as part of the .show method of the iterators class
        # it would not normally be used by a user
        class AttributeLengthHolder
            attr_accessor :attribute
            attr_accessor :length
            
            def initialize( attrib, length)
                @attribute = attrib
                @length = length
            end
        end
        
        def initialize( attrib=nil , length=nil)
            @attr=[]
            add( attrib , length ) if attrib
            @index_counter=0
        end

        # BUG: Untested. (Null implementation passes all tests.)
        def add( attrib , length)
            @attr <<  AttributeLengthHolder.new( attrib , length )
        end

        def delete(attrib)
            item_to_delete=nil
            @attr.each_with_index do |e,i|
                item_to_delete = i if e.attribute==attrib
            end
            @attr.delete_at(item_to_delete ) unless item_to_delete == nil
        end

        def next
            temp = @attr[@index_counter]
            @index_counter +=1
            return temp
        end

        def each
             0.upto( @attr.length-1 ) { |i | yield @attr[i]   }
        end
    end

    #    resume rdoc
    #++   
    

    # this class accesses the buttons in the document as a collection
    # it would normally only be accessed by the Watir::SupportsSubElements#buttons method
    #
    class Buttons < ElementCollections
        def element_class; Button; end
        def length
            get_length_of_input_objects(["button", "submit", "image"])
        end

        def set_show_items
            super
            @show_attributes.add( "disabled" , 9)
            @show_attributes.add( "value" , 20)
        end
    end


    # this class accesses the file fields in the document as a collection
    # it would normally only be accessed by the Watir::SupportsSubElements#file_fields method
    #
    class FileFields< ElementCollections
        def element_class; FileField; end
        def length
            get_length_of_input_objects(["file"])
        end

        def set_show_items
            super
            @show_attributes.add( "disabled" , 9)
            @show_attributes.add( "value" , 20)
        end
    end


    # this class accesses the check boxes in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#checkboxes method
    #
    class CheckBoxes < ElementCollections
        def element_class; CheckBox; end  
        def length
            get_length_of_input_objects("checkbox")
        end
        # this method creates an object of the correct type that the iterators use
        private
        def iterator_object(i)
            @ieController.checkbox(:index, i+1)
        end
    end

    # this class accesses the radio buttons in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#radios method
    #
    class Radios < ElementCollections
        def element_class; Radio; end
        def length
            get_length_of_input_objects("radio")
        end
        # this method creates an object of the correct type that the iterators use
        private
        def iterator_object(i)
            @ieController.radio(:index, i+1)
        end
    end

    # this class accesses the select boxes  in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#select_lists method
    #
    class SelectLists < ElementCollections
        include CommonCollection
        def element_class; SelectList; end
        def element_tag; 'SELECT'; end
    end

    # this class accesses the links in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#links method
    #
    class Links < ElementCollections
        include CommonCollection
        def element_class; Link; end    
        def element_tag; 'A'; end

        def set_show_items
            super
            @show_attributes.add("href", 60)
            @show_attributes.add("innerText" , 60)
        end

    end

    # this class accesses the imnages in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#images method
    #
    class Images < ElementCollections
        def element_class; Image; end 
        def length
            @ieController.document.images.length
        end

        def set_show_items
            super
            @show_attributes.add("src", 60)
            @show_attributes.add("alt", 30)
        end 

    end

    # this class accesses the text fields in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#text_fields method
    #
    class TextFields < ElementCollections
        def element_class; TextField; end
        def length
            # text areas are also included inthe Text_filds, but we need to get them seperately
            get_length_of_input_objects( ["text" , "password"] ) +
                @ieController.ie.document.body.getElementsByTagName("textarea").length
        end
    end

    # this class accesses the hidden fields in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#hiddens method
    class Hiddens < ElementCollections
        def element_class; Hidden; end
        def length
            get_length_of_input_objects("hidden")
        end
    end

    # this class accesses the text fields in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#tables method
    #
    class Tables < ElementCollections
        include CommonCollection
        def element_class; Table; end
        def element_tag; 'TABLE'; end

        def set_show_items
            super
            @show_attributes.delete( "name")
        end
    end

    # this class accesses the labels in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#labels method
    #
    class Labels < ElementCollections
        include CommonCollection
        def element_class; Label; end
        def element_tag; 'LABEL'; end

        def set_show_items
            super
            @show_attributes.add("htmlFor", 20)
        end
    end

    # this class accesses the p tags in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#ps method
    #
    class Ps < ElementCollections
        include CommonCollection
        def element_class; P; end

        def set_show_items
            super
            @show_attributes.delete( "name")
            @show_attributes.add( "className" , 20)
        end

    end

    # this class accesses the spans in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#spans method
    #
    class Spans < ElementCollections
        include CommonCollection
        def element_class; Span; end

        def set_show_items
            super
            @show_attributes.delete( "name")
            @show_attributes.add( "className" , 20)
        end

    end

    # this class accesses the divs in the document as a collection
    # Normally a user would not need to create this object as it is returned by the Watir::SupportsSubElements#divs method
    #
    class Divs < ElementCollections
        include CommonCollection
        def element_class; Div; end

        def set_show_items
            super
            @show_attributes.delete( "name")
            @show_attributes.add( "className" , 20)
        end

    end

end

require 'watir/camel_case'

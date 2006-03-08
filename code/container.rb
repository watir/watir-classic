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
# Is includable for classes that have @container, document and ole_inner_elements

require 'watir/exceptions'

module Container 
    include Watir::Exception
        
    # Shifted from IE class to here. So that it can be used by both the browsers
    # TODO: the following constants should be able to be specified by object (not class)

    # The delay when entering text on a web page when speed = :slow.
    DEFAULT_TYPING_SPEED = 0.01

    # The default time we wait after a page has loaded when speed = :slow.
    DEFAULT_SLEEP_TIME = 0.1

    # The default color for highlighting objects as they are accessed.
    DEFAULT_HIGHLIGHT_COLOR = "yellow"
    
    # Note: @container is the container of this object, i.e. the container 
    # of this container. 
    # In other words, for ie.table().this_thing().text_field().set, 
    # container of this_thing is the table.

    # This is used to change the typing speed when entering text on a page.
    attr_accessor :typingspeed
    # The color we want to use for the active object. This can be any valid web-friendly color.
    attr_accessor :activeObjectHighLightColor

    def copy_test_config(container) # only used by form and frame
        @typingspeed = container.typingspeed      
        @activeObjectHighLightColor = container.activeObjectHighLightColor      
    end    
    private :copy_test_config

    # Write the specified string to the log.
    def log(what)
        @container.logger.debug(what) if @logger
    end

    # Wait until Internet Explorer has finished loading the page.
    def wait(no_sleep = false)
        @container.wait(no_sleep)
    end

    # Determine the how and what when defaults are possible.
    def process_default(default_attribute, how, what)
        if what == nil
            what = how
            how = default_attribute 
        end
        return how, what
    end 
    private :process_default

    #
    #           Factory Methods
    #

    private
    def self.def_creator(method_name, klass_name = nil)
        klass_name ||= method_name.to_s.capitalize
        class_eval "def #{method_name}(how, what)
                        #{klass_name}.new(self, how, what)
                    end"
    end

    def self.def_creator_with_default(method_name, default_symbol)
        klass_name = method_name.to_s.capitalize
        class_eval "def #{method_name}(how, what = nil)
                        how, what = process_default :#{default_symbol}, how, what
                        #{klass_name}.new(self, how, what)
                    end"
    end
                
    # this method is the main way of accessing a frame 
    #   *  how   - how the frame is accessed. This can also just be the name of the frame
    #   *  what  - what we want to access.
    #
    # Typical usage:
    #
    #   ie.frame(:index, 1) 
    #   ie.frame(:name , 'main_frame')
    #   ie.frame('main_frame')        # in this case, just a name is supplied
    public
    def_creator_with_default :frame, :name

    # this method is used to access a form.
    # available ways of accessing it are, :index , :name, :id, :method, :action, :xpath
    #  * how        - symbol - WHat mecahnism we use to find the form, one of the above. NOTE if what is not supplied this parameter is the NAME of the form
    #  * what   - String - the text associated with the symbol
    def_creator_with_default :form, :name

    # This method is used to get a table from the page. 
    # :index (1 based counting)and :id are supported. 
    #  NOTE :name is not supported, as the table tag does not have a name attribute. It is not part of the DOM.
    # :index can be used when there are multiple tables on a page. 
    # :xpath can be used to select table using XPath query.
    # The first form can be accessed with :index 1, the second :index 2, etc. 
    #   * how - symbol - the way we look for the table. Supported values are
    #                  - :id
    #                  - :index
    #                  - :xpath
    #   * what  - string the thing we are looking for, ex. id, index or xpath query, of the object we are looking for
    def_creator :table

    # this is the main method for accessing the tables iterator. It returns a Tables object
    #
    # Typical usage:
    #
    #   ie.tables.each { |t| puts t.to_s }            # iterate through all the tables on the page
    #   ie.tables[1].to_s                             # goto the first table on the page                                   
    #   ie.tables.length                              # show how many tables are on the page. Tables that are nested will be included in this
    def tables
        return Tables.new(self)
    end

    # this method accesses a table cell. 
    # how - symbol - how we access the cell, valid values are
    #    :id       - find the table cell with given id.
    #    :xpath    - find the table cell using xpath query.
    # 
    # returns a TableCell Object
    def_creator :cell, :TableCell

    # this method accesses a table row. 
    # how - symbol - how we access the row, valid values are
    #    :id       - find the table row with given id.
    #    :xpath    - find the table row using xpath query.
    # 
    # returns a TableRow object
    def_creator :row, :TableRow

    # This is the main method for accessing a button. Often declared as an <input type = submit> tag.
    #  *  how   - symbol - how we access the button 
    #  *  what  - string, int, re or xpath query , what we are looking for, 
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
    #    :xpath      - finds the item using xpath query
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
    #    ie.button(:xpath, "//input[@value='Click Me']/")     # access the button with a value of Click Me
    def_creator_with_default :button, :value

    # this is the main method for accessing the buttons iterator. It returns a Buttons object
    #
    # Typical usage:
    #
    #   ie.buttons.each { |b| puts b.to_s }            # iterate through all the buttons on the page
    #   ie.buttons[1].to_s                             # goto the first button on the page                                   
    #   ie.buttons.length                              # show how many buttons are on the page. 
    def buttons
        return Buttons.new(self)
    end

    # This is the main method for accessing a file field. Usually an <input type = file> HTML tag.  
    #  *  how   - symbol - how we access the field , valid values are
    #    :index      - find the file field using index
    #    :id         - find the file field using id attribute
    #    :name       - find the file field using name attribute
    #    :xpath      - find the file field using xpath query
    #  *  what  - string, int, re or xpath query , what we are looking for, 
    #
    # returns a FileField object
    #
    # Typical Usage
    #
    #    ie.file_field(:id,   'up_1')                     # access the file upload field with an ID of up_1
    #    ie.file_field(:name, 'upload')                   # access the file upload field with a name of upload
    #    ie.file_field(:index, 2)                         # access the second file upload on the page ( 1 based, so the first field is accessed with :index,1)
    #
    def_creator :file_field, :FileField
    
    # this is the main method for accessing the file_fields iterator. It returns a FileFields object
    #
    # Typical usage:
    #
    #   ie.file_fields.each { |f| puts f.to_s }            # iterate through all the file fields on the page
    #   ie.file_fields[1].to_s                             # goto the first file field on the page                                   
    #   ie.file_fields.length                              # show how many file fields are on the page. 
    def file_fields
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
    #    :afterText  - finds the item immediately after the specified texti
    #    :xpath      - find the item using xpath query 
    #
    # Typical Usage
    #
    #    ie.text_field(:id,   'user_name')                 # access the text field with an ID of user_name
    #    ie.text_field(:name, 'address')                   # access the text field with a name of address
    #    ie.text_field(:index, 2)                          # access the second text field on the page ( 1 based, so the first field is accessed with :index,1)
    #    ie.text_field(:xpath, "//textarea[@id='user_name']/")    ## access the text field with an ID of user_name

    def_creator :text_field, :TextField

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
    #  *  how   - symbol - how we access the field , valid values are
    #    :index      - find the item using index
    #    :id         - find the item using id attribute
    #    :name       - find the item using name attribute
    #    :xpath      - find the item using xpath query etc
    #  *  what  - string, int or re , what we are looking for, 
    #
    # returns a Hidden object
    #
    # Typical usage
    #
    #    ie.hidden(:id, 'session_id')                 # access the hidden field with an ID of session_id
    #    ie.hidden(:name, 'temp_value')               # access the hidden field with a name of temp_value
    #    ie.hidden(:index, 2)                         # access the second hidden field on the page ( 1 based, so the first field is accessed with :index,1)
    #    ie.hidden(:xpath, "//input[@type='hidden' and @id='session_value']/")    # access the hidden field with an ID of session_id
    def hidden(how, what)
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
    #    :xpath      - finds the item using xpath query
    #
    # Typical usage
    #
    #    ie.select_list(:id, 'currency')                   # access the select box with an id of currency
    #    ie.select_list(:name, 'country')                  # access the select box with a name of country
    #    ie.select_list(:name, /n_/ )                      # access the first select box whose name matches n_
    #    ie.select_list(:index, 2)                         # access the second select box on the page ( 1 based, so the first field is accessed with :index,1)
    #    ie.select(:xpath, "//select[@id='currency']/")    # access the select box with an id of currency 
    def select_list(how, what) 
        return SelectList.new(self, how, what)
    end

    # this is the method for accessing the select lists iterator. Returns a SelectLists object
    #
    # Typical usage:
    #
    #   ie.select_lists.each { |s| puts s.to_s }            # iterate through all the select boxes on the page
    #   ie.select_lists[1].to_s                             # goto the first select boxes on the page                                   
    #   ie.select_lists.length                              # show how many select boxes are on the page.
    def select_lists
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
    #    :xpath      - finds the item that matches xpath query
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
    #    ie.checkbox(:xpath, "//input[@name='email_frequency' and @value='daily']/")     # access the checkbox with a name of email_frequency and a value of 'daily'
    def checkbox(how, what, value = nil) 
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
    #    :xpath      - finds the item that matches xpath query
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
    #    ie.radio(:xpath, "//input[@name='email_frequency' and @value='daily']/")     # access the radio button with a name of email_frequency and a value of 'daily'
    def radio(how, what, value = nil) 
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
    #    :xpath      - finds the item that matches xpath query    
    #
    # Typical Usage
    # 
    #   ie.link(:url, /login/)              # access the first link whose url matches login. We can use a string in place of the regular expression
    #                                       # but the complete path must be used, ie.link(:url, 'http://myserver.com/my_path/login.asp')
    #   ie.link(:index,2)                   # access the second link on the page
    #   ie.link(:title , "Picture")         # access a link using the tool tip
    #   ie.link(:text, 'Click Me')          # access the link that has Click Me as its text
    #   ie.link(:afterText, 'Click->')      # access the link that immediately follows the text Click->
    #   ie.link(:xpath, "//a[contains(.,'Click Me')]/")      # access the link with Click Me as its text
    def link(how, what) 
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
    #  *  how   - symbol - how we access the image, :index, :id, :name, :src, :title or :alt are supported
    #  *  what  - string or regexp - what we are looking for 
    #
    # returns an Image object
    #
    # Valid values for 'how' are
    #
    #    :index      - find the item using the index in the container ( a container can be a document, a TableCell, a Span, a Div or a P
    #                  index is 1 based
    #    :name       - find the item using the name attribute
    #    :id         - find the item using the id attribute
    #    :alt        - finds the item using the alt text (tool tip)
    #    :src        - finds the item using the src tag. This must be the fully qualified name, so is best used with a regular expression
    #    :xpath      - finds the item that matches xpath query
    #    :title      - finds the item using the title (tool tip)
    #
    # Typical Usage
    # 
    #   ie.image(:src, /myPic/)             # access the first image that matches myPic. We can use a string in place of the regular expression
    #                                       # but the complete path must be used, ie.image(:src, 'http://myserver.com/my_path/my_image.jpg')
    #   ie.image(:index,2)                  # access the second image on the page
    #   ie.image(:alt , "A Picture")        # access an image using the alt text
    #   ie.image(:xpath, "//img[@alt='A Picture']/")    # access an image using the alt text
    #   
    def_creator :image
    
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
    def popup         # BUG this should not be on the container object!        
        return PopUp.new(self)
    end

    # This is the main method for accessing divs. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
    #  *  how   - symbol - how we access the div, valid values are
    #    :index      - finds the item using its index
    #    :id         - finds the item using id attribute
    #    :title      - finds the item using title attribute
    #    :xpath      - finds the item that matches xpath query
    #
    #  *  what  - string, integer, re or xpath query , what we are looking for, 
    #
    # returns an Div object
    #
    # Typical Usage
    # 
    #   ie.div(:id, /list/)                 # access the first div that matches list.
    #   ie.div(:index,2)                    # access the second div on the page
    #   ie.div(:title , "A Picture")        # access a div using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
    #   ie.div(:xpath, "//div[@id='list']/")    # access the first div whose id is 'list'
    #   
    def div(how, what)
        return Div.new(self, how, what)
    end

    # this is the main method for accessing the divs iterator. Returns a Divs collection
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
    #  *  how   - symbol - how we access the span, valid values are
    #    :index      - finds the item using its index
    #    :id         - finds the item using its id attribute
    #    :name       - finds the item using its name attribute
    #
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
    def span(how, what)
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
    #  *  how   - symbol - how we access the p, valid values are
    #    :index      - finds the item using its index
    #    :id         - finds the item using its id attribute
    #    :name       - finds the item using its name attribute
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
        return P.new(self, how, what)
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

    # This is the main method for accessing pre tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/pre.asp?frame=true
    #  *  how   - symbol - how we access the pre, valid values are
    #    :index      - finds the item using its index
    #    :id         - finds the item using its id attribute
    #    :name       - finds the item using its name attribute
    #  *  what  - string, integer or re , what we are looking for, 
    #
    # returns a Pre object
    #
    # Typical Usage
    # 
    #   ie.pre(:id, /list/)                 # access the first pre tag  that matches list.
    #   ie.pre(:index,2)                    # access the second pre tag on the page
    #   ie.pre(:title , "A Picture")        # access a pre tag using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
    #   
    def pre(how, what)
        return Pre.new(self, how, what)
    end

    # this is the main method for accessing the ps iterator. 
    # 
    # Returns a Pres object
    #
    # Typical usage:
    #
    #   ie.pres.each { |pre| puts pre.to_s }            # iterate through all the pre tags on the page
    #   ie.pres[1].to_s                             # goto the first pre tag on the page                                   
    #   ie.pres.length                              # show how many pre tags are on the page.
    #
    def pres
        return Pres.new(self)
    end

    # This is the main method for accessing labels. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
    #  *  how   - symbol - how we access the label, valid values are
    #    :index      - finds the item using its index
    #    :id         - finds the item using its id attribute
    #    :for        - finds the item which has an object associated with it.
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
    def labels
        return Labels.new(self)
    end

    #--
    #
    # Searching for Page Elements
    # Not for external consumption
    #        
    #++
    def ole_inner_elements
        return document.body.all 
    end
    private :ole_inner_elements

    # This method shows the available objects on the current page.
    # This is usually only used for debugging or writing new test scripts.
    # This is a nice feature to help find out what HTML objects are on a page
    # when developing a test case using Watir.
    def show_all_objects
        puts "-----------Objects in  page -------------" 
        doc = document
        s = ""
        props = ["name" ,"id" , "value" , "alt" , "src"]
        doc.all.each do |n|
            begin
                s += n.invoke("type").to_s.ljust(16)
            rescue
                next
            end
            props.each do |prop|
                begin
                    p = n.invoke(prop)
                    s += "  " + "#{prop}=#{p}".to_s.ljust(18)
                rescue
                    # this object probably doesnt have this property
                end
            end
            s += "\n"
        end
        puts s
    end

    # 
    #                Locator Methods
    #

    # Returns the specified ole object for input elements on a web page.
    #
    # This method is used internally by Watir and should not be used externally. It cannot be marked as private because of the way mixins and inheritance work in watir
    #
    #   * how - symbol - the way we look for the object. Supported values are
    #                  - :name
    #                  - :id
    #                  - :index
    #                  - :value etc
    #   * what  - string that we are looking for, ex. the name, or id tag attribute or index of the object we are looking for.
    #   * types - what object types we will look at. 
    #   * value - used for objects that have one name, but many values. ex. radio lists and checkboxes
    def locate_input_element(how, what, types, value = nil)
        elements = ole_inner_elements
        how = :value if how == :caption
        what = what.to_i if how == :index
        value = value.to_s if value
        log "getting object - how is #{how} what is #{what} types = #{types} value = #{value}"
        
        o = nil
        object_index = 1
        elements.each do |object|
            next if o
            element = Element.new(object)
            #puts "The value of type is : #{element.type}"
            if types.include?(element.type)
                if how == :index
                    attribute = object_index
                else
                    begin
                        attribute = element.send(how)
                    rescue NoMethodError
                        raise MissingWayOfFindingObjectException, 
                        "#{how} is an unknown way of finding a <INPUT> element (#{what})"
                    end
                end
                if what.matches(attribute) 
                    if value
                        if element.value == value
                            o = object
                        end
                    else
                        o = object
                    end
                end
                object_index += 1
            end
        end
        return o
    end

    # returns the ole object for the specified element
    def locate_tagged_element(tag, how, what)        
        elements = document.getElementsByTagName(tag)
        what = what.to_i if how == :index
        how = :href if how == :url
        o = nil
        count = 1
        elements.each do |object|
            next if o
            element = Element.new(object)
            if how == :index
                attribute = count                        
            else
                begin
                    attribute = element.send(how)
                rescue NoMethodError
                    raise MissingWayOfFindingObjectException, 
                        "#{how} is an unknown way of finding a <#{tag}> element (#{what})"
                end
            end
            o = object if what.matches(attribute)
            count += 1
        end # do
        return o
    end  
    
    #
    # Angrez:
    # Added few more functions to be used by Mozilla browser.
    #
    MACHINE_IP = "127.0.0.1"
    WINDOW_VAR = "window"
    BROWSER_VAR = "browser"
    DOCUMENT_VAR = "document"
    BODY_VAR    = "body"
    
    def read_socket()
        recieved_more_data = false
        return_value = ""
        data = ""
        
        s = Kernel.select([$jssh_socket] , nil , nil, 1)

        if(s != nil)
            for stream in s[0]
                data = $jssh_socket.recv(256)
                #puts "data is : #{data}"
                while( data.length == 256)
                    recieved_more_data = true
                    return_value += data
                    data = $jssh_socket.recv(256)
                    #puts "data is : #{data}"
                end
            end
        end
        
        # If recieved data is less than 256 characters or for last data 
        # we read in the above loop 
        return_value += data

        # Get the command prompt inserted by JSSH
        s = Kernel.select([$jssh_socket] , nil , nil, 1)
            
        if(s != nil)
        for stream in s[0]
            return_value += $jssh_socket.recv(256)
            end
        end
    
        length = return_value.length 
        #puts "Return value before removing command prompt is : #{return_value}"
        
        # Remove the command prompt. Every result returned by JSSH has "\n> " at the end.
        if length <= 3
            return_value = ""
        else
            return_value = return_value[0..length-4]
        end 
        #puts "Return value after removing command prompt is : #{return_value}"
        return return_value
    end

end # module 
    
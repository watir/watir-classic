module Watir
  # This module contains the factory methods that are used to access most html objects
  #
  # For example, to access a button on a web page that has the following html
  #  <input type=button name='b1' value='Click Me' onClick='javascript:doSomething()'>
  #
  # the following watir code could be used to click the button
  #
  #  browser.button(:name, 'b1').click
  #
  # or to find the name attribute
  #
  #  browser.button(:value, 'Click Me').name
  #
  # there are many methods available to the Button object
  #--
  # Is includable for classes that have @container, document and ole_inner_elements
  module Container
    include Watir::Exception
    
    # Note: @container is the container of this object, i.e. the container
    # of this container.
    # In other words, for browser.table().this_thing().text_field().set,
    # container of this_thing is the table.
    
    # This is used to change the typing speed when entering text on a page.
    attr_accessor :typingspeed
    attr_accessor :type_keys
    # The color we want to use for the active object. This can be any valid web-friendly color.
    attr_accessor :activeObjectHighLightColor
    # The PageContainer object containing this element
    attr_accessor :page_container
    
    def copy_test_config(container) # only used by form and frame
      @typingspeed = container.typingspeed
      @type_keys = container.type_keys
      @activeObjectHighLightColor = container.activeObjectHighLightColor
    end
    private :copy_test_config
    
    # Write the specified string to the log.
    def log(what)
      @container.logger.debug(what) if @logger
    end
    
    # Wait until Browser has finished loading the page.
    #--
    # called explicitly by most click and set methods
    def wait(no_sleep=false)
      @container.wait(no_sleep)
    end
    
    # Determine the how and what when defaults are possible.
    def process_default(default_attribute, how, what)
      if what.nil? && String === how
        what = how
        how = default_attribute
      end
      return how, what
    end
    private :process_default
    
    def set_container container #:nodoc:
      @container = container 
      @page_container = container.page_container
    end
        
    private
    def self.def_creator(method_name, klass_name=nil)
      klass_name ||= method_name.to_s.capitalize
      class_eval "def #{method_name}(how, what=nil)
                          #{klass_name}.new(self, how, what)
                        end"
    end
    
    def self.def_creator_with_default(method_name, default_symbol)
      klass_name = method_name.to_s.capitalize
      class_eval "def #{method_name}(how, what=nil)
                          how, what = process_default :#{default_symbol}, how, what
                          #{klass_name}.new(self, how, what)
                        end"
    end
    
    #--
    #           Factory Methods
    #++
    public

    # this method is the main way of accessing a frame
    #   *  how   - how the frame is accessed. This can also just be the name of the frame.
    #   *  what  - what we want to access.
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Frame object
    #
    # Typical usage:
    #
    #   browser.frame(:index, 1)
    #   browser.frame(:name, 'main_frame')
    #   browser.frame('main_frame')        # in this case, just a name is supplied
    def frame(how, what=nil)
      how, what = process_default :name, how, what
      Frame.new(self, how, what)
    end

    # this is the main method for accessing the frames iterator. Returns a Frames collection
    #
    # Typical usage:
    #
    #   browser.frames.each { |f| puts f.src }             # iterate through all the frames on the page
    #   browser.frames[1].to_s                             # goto the first frame on the page
    #   browser.frames.length                              # show how many frames are on the page.
    #
    def frames
      Frames.new(self)
    end
        
    # this method is used to access a form.
    # available ways of accessing it are, :index, :name, :id, :method, :action, :xpath
    #  * how    - symbol - What mecahnism we use to find the form, one of 
    #                 the above. NOTE if what is not supplied this parameter is the NAME of the form
    #  * what   - String - the text associated with the symbol
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Form object
    def form(how, what=nil)
      how, what = process_default :name, how, what
      Form.new(self, how, what)
    end
    
    # this is the main method for accessing the forms iterator. Returns a Forms collection
    #
    # Typical usage:
    #
    #   browser.forms.each { |f| puts f.src }             # iterate through all the forms on the page
    #   browser.forms[1].to_s                             # goto the first form on the page
    #   browser.forms.length                              # show how many forms are on the page.
    #
    def forms
      Forms.new(self)
    end

    # This method is used to get a table from the page.
    # :index (1 based counting) and :id are supported.
    #  NOTE :name is not supported, as the table tag does not have a name attribute. It is not part of the DOM.
    # :index can be used when there are multiple tables on a page.
    # :xpath can be used to select table using XPath query.
    # The first form can be accessed with :index 1, the second :index 2, etc.
    #   * how   - symbol - how we access the table, :index, :id, :xpath etc
    #   * what  - string the thing we are looking for, ex. id, index or xpath query, of the object we are looking for
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Table object
    def table(how, what=nil)
      Table.new(self, how, what)
    end 
    
    # this is the main method for accessing the tables iterator. It returns a Tables object
    #
    # Typical usage:
    #
    #   browser.tables.each { |t| puts t.to_s }            # iterate through all the tables on the page
    #   browser.tables[1].to_s                             # goto the first table on the page
    #   browser.tables.length                              # show how many tables are on the page. Tables that are nested will be included in this
    def tables
      Tables.new(self)
    end
    
    # this method accesses a table cell.
    # how - symbol - how we access the cell, valid values are
    #    :id       - find the table cell with given id.
    #    :xpath    - find the table cell using xpath query.
    #
    # returns a TableCell Object
    def cell(how, what=nil)
      TableCell.new(self, how, what)
    end
    def cells
      TableCells.new(self)
    end
    
    # this method accesses a table row.
    # how - symbol - how we access the row, valid values are
    #    :id       - find the table row with given id.
    #    :xpath    - find the table row using xpath query.
    #
    # returns a TableRow object
    def row(how, what=nil)
      TableRow.new(self, how, what)
    end
    def rows
      TableRows.new(self)
    end
    
    # Access a modal web dialog, which is a PageContainer, like IE or Frame. 
    # Returns a ModalDialog object.
    #
    # Typical Usage
    #    browser.modal_dialog                  # access the modal dialog of ie
    #    browser.modal_dialog(:title, 'Title') # access the modal dialog by title
    #    browser.modal_dialog.modal_dialog     # access a modal dialog's modal dialog XXX untested!
    #
    # This method will not work when
    # Watir/Ruby is run under a service (instead of a user).
    # Note: unlike Watir.attach, this returns before the page is assured to have 
    # loaded.
    
    def modal_dialog(how=nil, what=nil)
      ModalDialog.new(self, how, what)
    end

    # This is the main method for accessing a button. Often declared as an <tt><input type = submit></tt> tag.
    #  *  how   - symbol - how we access the button, :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # Returns a Button object.
    #
    # Typical usage
    #
    #    browser.button(:id,    'b_1')                             # access the button with an ID of b_1
    #    browser.button(:name,  'verify_data')                     # access the button with a name of verify_data
    #    browser.button(:value, 'Login')                           # access the button with a value (the text displayed on the button) of Login
    #    browser.button(:caption, 'Login')                         # same as above
    #    browser.button(:value, /Log/)                             # access the button that has text matching /Log/
    #    browser.button(:index, 2)                                 # access the second button on the page (1 based, so the first button is accessed with :index,1)
    #    browser.button(:class, 'my_custom_button_class')          # access the button with a class of my_custom_button_class
    #    browser.button(:xpath, "//input[@value='Click Me']/")     # access the button with a value of Click Me
    #
    # Accessing a Button nested within another element
    #    browser.div(:class, 'xyz').button(:index, 2)              # access a div of class xyz, and the 2nd button within that div
    #
    # If only a single parameter is supplied, then :value is used
    #    browser.button('Click Me')                                # access the button with a value of Click Me
    def button(how, what=nil)
      how, what = process_default :value, how, what
      Button.new(self, how, what)
    end
    
    # this is the main method for accessing the buttons iterator. It returns a Buttons object
    #
    # Typical usage:
    #
    #   browser.buttons.each { |b| puts b.to_s }                   # iterate through all the buttons on the page
    #   browser.buttons[1].to_s                                    # goto the first button on the page
    #   browser.buttons.length                                     # show how many buttons are on the page.
    def buttons
      Buttons.new(self)
    end
    
    # This is the main method for accessing a file field. Usually an <tt><input type = file></tt> HTML tag.
    #  *  how   - symbol - how we access the field, valid values are
    #    :index      - find the file field using index
    #    :id         - find the file field using id attribute
    #    :name       - find the file field using name attribute
    #    :xpath      - find the file field using xpath query
    #  *  what  - string, integer, regular expression, or xpath query - what we are looking for,
    #
    # returns a FileField object
    #
    # Typical Usage
    #
    #    browser.file_field(:id,   'up_1')                     # access the file upload field with an ID of up_1
    #    browser.file_field(:name, 'upload')                   # access the file upload field with a name of upload
    #    browser.file_field(:index, 2)                         # access the second file upload on the page (1 based, so the first field is accessed with :index,1)
    #
    def file_field(how, what=nil)
      FileField.new(self, how, what)
    end
    
    # this is the main method for accessing the file_fields iterator. It returns a FileFields object
    #
    # Typical usage:
    #
    #   browser.file_fields.each { |f| puts f.to_s }            # iterate through all the file fields on the page
    #   browser.file_fields[1].to_s                             # goto the first file field on the page
    #   browser.file_fields.length                              # show how many file fields are on the page.
    def file_fields
      FileFields.new(self)
    end
    
    # This is the main method for accessing a text field. Usually an <tt><input type=text></tt> HTML tag.
    # or a text area - a  <tt><textarea></tt> tag
    #  *  how   - symbol - how we access the field, :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a TextField object
    #
    # Typical Usage
    #
    #    browser.text_field(:id,   'user_name')                 # access the text field with an ID of user_name
    #    browser.text_field(:name, 'address')                   # access the text field with a name of address
    #    browser.text_field(:index, 2)                          # access the second text field on the page (1 based, so the first field is accessed with :index,1)
    #    browser.text_field(:xpath, "//textarea[@id='user_name']/")    # access the text field with an ID of user_name
    def text_field(how, what=nil)
      TextField.new(self, how, what)
    end
    
    # this is the method for accessing the text_fields iterator. It returns a Text_Fields object
    #
    # Typical usage:
    #
    #   browser.text_fields.each { |t| puts t.to_s }            # iterate through all the text fields on the page
    #   browser.text_fields[1].to_s                             # goto the first text field on the page
    #   browser.text_fields.length                              # show how many text field are on the page.
    def text_fields
      TextFields.new(self)
    end
    
    # This is the main method for accessing a hidden field. Usually an <tt><input type = hidden></tt> HTML tag
    #
    #  *  how   - symbol - how we access the hidden field, :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Hidden object
    #
    # Typical usage
    #
    #    browser.hidden(:id, 'session_id')                 # access the hidden field with an ID of session_id
    #    browser.hidden(:name, 'temp_value')               # access the hidden field with a name of temp_value
    #    browser.hidden(:index, 2)                         # access the second hidden field on the page (1 based, so the first field is accessed with :index,1)
    #    browser.hidden(:xpath, "//input[@type='hidden' and @id='session_value']/")    # access the hidden field with an ID of session_id
    def hidden(how, what=nil)
      Hidden.new(self, how, what)
    end
    
    # this is the method for accessing the hiddens iterator. It returns a Hiddens object
    #
    # Typical usage:
    #
    #   browser.hiddens.each { |t| puts t.to_s }            # iterate through all the hidden fields on the page
    #   browser.hiddens[1].to_s                             # goto the first hidden field on the page
    #   browser.hiddens.length                              # show how many hidden fields are on the page.
    def hiddens
      Hiddens.new(self)
    end
    
    # This is the main method for accessing a selection list. Usually a <tt><select></tt> HTML tag.
    #  *  how   - symbol - how we access the selection list, :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a SelectList object
    #
    # Typical usage
    #
    #    browser.select_list(:id, 'currency')                   # access the select box with an id of currency
    #    browser.select_list(:name, 'country')                  # access the select box with a name of country
    #    browser.select_list(:name, /n_/)                       # access the first select box whose name matches n_
    #    browser.select_list(:index, 2)                         # access the second select box on the page (1 based, so the first field is accessed with :index,1)
    #    browser.select(:xpath, "//select[@id='currency']/")    # access the select box with an id of currency
    def select_list(how, what=nil)
      SelectList.new(self, how, what)
    end
    
    # this is the method for accessing the select lists iterator. Returns a SelectLists object
    #
    # Typical usage:
    #
    #   browser.select_lists.each { |s| puts s.to_s }            # iterate through all the select boxes on the page
    #   browser.select_lists[1].to_s                             # goto the first select boxes on the page
    #   browser.select_lists.length                              # show how many select boxes are on the page.
    def select_lists
      SelectLists.new(self)
    end
    
    # This is the main method for accessing a check box. Usually an <tt><input type = checkbox></tt> HTML tag.
    #
    #  *  how   - symbol - how we access the check box - :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #  *  value - string - when there are multiple objects with different value attributes, this can be used to find the correct object
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a CheckBox object
    #
    # Typical usage
    #
    #   browser.checkbox(:id, 'send_email')                    # access the check box with an id of send_mail
    #   browser.checkbox(:name, 'send_copy')                   # access the check box with a name of send_copy
    #   browser.checkbox(:name, /n_/)                          # access the first check box whose name matches n_
    #   browser.checkbox(:index, 2)                            # access the second check box on the page (1 based, so the first field is accessed with :index,1)
    #
    # In many instances, checkboxes on an html page have the same name, but are identified by different values. An example is shown next.
    #
    #   <input type = checkbox name = email_frequency value = 'daily' > Daily Email
    #   <input type = checkbox name = email_frequency value = 'Weekly'> Weekly Email
    #   <input type = checkbox name = email_frequency value = 'monthly'>Monthly Email
    #
    # Watir can access these using the following:
    #
    #    browser.checkbox(:id, 'day_to_send', 'monday')         # access the check box with an id of day_to_send and a value of monday
    #    browser.checkbox(:name,'email_frequency', 'weekly')    # access the check box with a name of email_frequency and a value of 'weekly'
    #    browser.checkbox(:xpath, "//input[@name='email_frequency' and @value='daily']/")     # access the checkbox with a name of email_frequency and a value of 'daily'
    def checkbox(how, what=nil, value=nil) # should be "check_box" ?
      CheckBox.new(self, how, what, value)
    end
    
    # this is the method for accessing the check boxes iterator. Returns a CheckBoxes object
    #
    # Typical usage:
    #
    #   browser.checkboxes.each { |c| puts c.to_s }             # iterate through all the check boxes on the page
    #   browser.checkboxes[1].to_s                              # goto the first check box on the page
    #   browser.checkboxes.length                               # show how many check boxes are on the page.
    def checkboxes
      CheckBoxes.new(self)
    end
    
    # This is the main method for accessing a radio button. Usually an <tt><input type = radio></tt> HTML tag.
    #  *  how   - symbol - how we access the radio button, :index, :id, :name etc
    #  *  what  - string, integer or regular expression - what we are looking for,
    #  *  value - string - when  there are multiple objects with different value attributes, this can be used to find the correct object
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Radio object
    #
    # Typical usage
    #
    #    browser.radio(:id, 'send_email')                   # access the radio button with an id of currency
    #    browser.radio(:name, 'send_copy')                  # access the radio button with a name of country
    #    browser.radio(:name, /n_/)                        # access the first radio button whose name matches n_
    #    browser.radio(:index, 2)                           # access the second radio button on the page (1 based, so the first field is accessed with :index,1)
    #
    # In many instances, radio buttons on an html page have the same name, but are identified by different values. An example is shown next.
    #
    #  <input type="radio" name="email_frequency" value="daily">Daily Email</input>
    #  <input type="radio" name="email_frequency" value="weekly">Weekly Email</input>
    #  <input type="radio" name="email_frequency" value="monthly">Monthly Email</input>
    #
    # Watir can access these using the following:
    #
    #    browser.radio(:id, 'day_to_send', 'monday')         # access the radio button with an id of day_to_send and a value of monday
    #    browser.radio(:name,'email_frequency', 'weekly')     # access the radio button with a name of email_frequency and a value of 'weekly'
    #    browser.radio(:xpath, "//input[@name='email_frequency' and @value='daily']/")     # access the radio button with a name of email_frequency and a value of 'daily'
    def radio(how, what=nil, value=nil)
      Radio.new(self, how, what, value)
    end
    
    # This is the method for accessing the radio buttons iterator. Returns a Radios object
    #
    # Typical usage:
    #
    #   browser.radios.each { |r| puts r.to_s }            # iterate through all the radio buttons on the page
    #   browser.radios[1].to_s                             # goto the first radio button on the page
    #   browser.radios.length                              # show how many radio buttons are on the page.
    #
    def radios
      Radios.new(self)
    end
    
    # This is the main method for accessing a link.
    #  *  how   - symbol - how we access the link, :index, :id, :name, :title, :text, :url
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a Link object
    #
    # Typical Usage
    #
    #   browser.link(:url, /login/)              # access the first link whose url matches login. We can use a string in place of the regular expression
    #                                       # but the complete path must be used, browser.link(:url, 'http://myserver.com/my_path/login.asp')
    #   browser.link(:index,2)                   # access the second link on the page
    #   browser.link(:title, "Picture")         # access a link using the tool tip
    #   browser.link(:text, 'Click Me')          # access the link that has Click Me as its text
    #   browser.link(:xpath, "//a[contains(.,'Click Me')]/")      # access the link with Click Me as its text
    def link(how, what=nil)
      Link.new(self, how, what)
    end
    
    # This is the main method for accessing the links collection. Returns a Links object
    #
    # Typical usage:
    #
    #   browser.links.each { |l| puts l.to_s }            # iterate through all the links on the page
    #   browser.links[1].to_s                             # goto the first link on the page
    #   browser.links.length                              # show how many links are on the page.
    #
    def links
      Links.new(self)
    end
    
    # This is the main method for accessing li tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/map.asp?frame=true
    #  *  how   - symbol - how we access the li, 
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a li object
    #
    # Typical Usage
    #
    #   browser.li(:id, /list/)                 # access the first li that matches list.
    #   browser.li(:index,2)                    # access the second li on the page
    #   browser.li(:title, "A Picture")        # access a li using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
    #   
    #    def li(how, what=nil)
    #      return Li.new(self, how, what)
    #    end
    
    # this is the main method for accessing the lis iterator.
    #
    # Returns a lis object
    #
    # Typical usage:
    #
    #   browser.lis.each { |s| puts s.to_s }            # iterate through all the lis on the page
    #   browser.lis[1].to_s                             # goto the first li on the page
    #   browser.lis.length                              # show how many lis are on the page.
    #
    def lis
      return Lis.new(self)
    end
    

    # This is the main method for accessing map tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/map.asp?frame=true
    #  *  how   - symbol - how we access the map,
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a map object
    #
    # Typical Usage
    #
    #   browser.map(:id, /list/)                 # access the first map that matches list.
    #   browser.map(:index,2)                    # access the second map on the page
    #   browser.map(:title, "A Picture")         # access a map using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
    #    
    def map(how, what=nil)
      return Map.new(self, how, what)
    end
    
    # this is the main method for accessing the maps iterator.
    #
    # Returns a maps object
    #
    # Typical usage:
    #
    #   browser.maps.each { |s| puts s.to_s }            # iterate through all the maps on the page
    #   browser.maps[1].to_s                             # goto the first map on the page
    #   browser.maps.length                              # show how many maps are on the page.
    #
    def maps
      return Maps.new(self)
    end

    # This is the main method for accessing area tags - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/area.asp?frame=true
    #  *  how   - symbol - how we access the area
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns a area object
    #
    # Typical Usage
    #
    #   browser.area(:id, /list/)                 # access the first area that matches list.
    #   browser.area(:index,2)                    # access the second area on the page
    #   browser.area(:title, "A Picture")         # access a area using the tooltip text. See http://msdn.microsoft.com/workshop/author/dhtml/reference/properties/title_1.asp?frame=true
    #    
    def area(how, what=nil)
      return Area.new(self, how, what)
    end
    
    # this is the main method for accessing the areas iterator.
    #
    # Returns a areas object
    #
    # Typical usage:
    #
    #   browser.areas.each { |s| puts s.to_s }            # iterate through all the areas on the page
    #   browser.areas[1].to_s                             # goto the first area on the page
    #   browser.areas.length                              # show how many areas are on the page.
    #
    def areas
      return Areas.new(self)
    end
    
    # This is the main method for accessing images - normally an <tt><img src="image.gif"></tt> HTML tag.
    #  *  how   - symbol - how we access the image, :index, :id, :name, :src, :title or :alt are supported
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns an Image object
    #
    # Typical Usage
    #
    #   browser.image(:src, /myPic/)             # access the first image that matches myPic. We can use a string in place of the regular expression
    #                                       # but the complete path must be used, browser.image(:src, 'http://myserver.com/my_path/my_image.jpg')
    #   browser.image(:index,2)                  # access the second image on the page
    #   browser.image(:alt, "A Picture")         # access an image using the alt text
    #   browser.image(:xpath, "//img[@alt='A Picture']/")    # access an image using the alt text
    #
    def image(how, what=nil)
      Image.new(self, how, what)
    end
    
    # This is the main method for accessing the images collection. Returns an Images object
    #
    # Typical usage:
    #
    #   browser.images.each { |i| puts i.to_s }            # iterate through all the images on the page
    #   browser.images[1].to_s                             # goto the first image on the page
    #   browser.images.length                              # show how many images are on the page.
    #
    def images
      Images.new(self)
    end
    
    # This is the main method for accessing JavaScript popups.
    # returns a PopUp object
    def popup         # BUG this should not be on the container object!
      PopUp.new(self)
    end
    
    
    # this is the main method for accessing the divs iterator. Returns a Divs collection
    #
    # Typical usage:
    #
    #   browser.divs.each { |d| puts d.to_s }            # iterate through all the divs on the page
    #   browser.divs[1].to_s                             # goto the first div on the page
    #   browser.divs.length                              # show how many divs are on the page.
    #
    def divs
      Divs.new(self)
    end
    
    # this is the main method for accessing the dls iterator. Returns a Dls collection
    #
    # Typical usage:
    #
    #   browser.dls.each { |d| puts d.to_s }            # iterate through all the dls on the page
    #   browser.dls[1].to_s                             # goto the first dl on the page
    #   browser.dls.length                              # show how many dls are on the page.
    #
    def dls
      Dls.new(self)
    end
    
    # this is the main method for accessing the dds iterator. Returns a Dds collection
    #
    # Typical usage:
    #
    #   browser.dds.each { |d| puts d.to_s }            # iterate through all the dds on the page
    #   browser.dds[1].to_s                             # goto the first dd on the page
    #   browser.dds.length                              # show how many dds are on the page.
    #
    def dds
      Dds.new(self)
    end
    
    # this is the main method for accessing the dts iterator. Returns a Dts collection
    #
    # Typical usage:
    #
    #   browser.dts.each { |d| puts d.to_s }            # iterate through all the dts on the page
    #   browser.dts[1].to_s                             # goto the first dt on the page
    #   browser.dts.length                              # show how many dts are on the page.
    #
    def dts
      Dts.new(self)
    end
        
    # this is the main method for accessing the ems iterator. Returns a Ems collection
    #
    # Typical usage:
    #
    #   browser.ems.each { |d| puts d.to_s }            # iterate through all the ems on the page
    #   browser.ems[1].to_s                             # goto the first em on the page
    #   browser.ems.length                              # show how many ems are on the page.
    #
    def ems
      Ems.new(self)
    end
        
    # this is the main method for accessing the spans iterator.
    #
    # Returns a Spans object
    #
    # Typical usage:
    #
    #   browser.spans.each { |s| puts s.to_s }            # iterate through all the spans on the page
    #   browser.spans[1].to_s                             # goto the first span on the page
    #   browser.spans.length                              # show how many spans are on the page.
    #
    def spans
      Spans.new(self)
    end
    
    # this is the main method for accessing the Strongs iterator.
    #
    # Returns a Strongs object
    #
    # Typical usage:
    #
    #   browser.strongs.each { |s| puts s.to_s }            # iterate through all the strongs on the page
    #   browser.strongs[1].to_s                             # goto the first strong on the page
    #   browser.strongs.length                              # show how many strongs are on the page.
    #
    def strongs
      return Strongs.new(self)
    end

    
    # this is the main method for accessing the ps iterator.
    #
    # Returns a Ps object
    #
    # Typical usage:
    #
    #   browser.ps.each { |p| puts p.to_s }            # iterate through all the p tags on the page
    #   browser.ps[1].to_s                             # goto the first p tag on the page
    #   browser.ps.length                              # show how many p tags are on the page.
    #
    def ps
      Ps.new(self)
    end
        
    # this is the main method for accessing the ps iterator.
    #
    # Returns a Pres object
    #
    # Typical usage:
    #
    #   browser.pres.each { |pre| puts pre.to_s }        # iterate through all the pre tags on the page
    #   browser.pres[1].to_s                             # goto the first pre tag on the page
    #   browser.pres.length                              # show how many pre tags are on the page.
    #
    def pres
      Pres.new(self)
    end
        
    # this is the main method for accessing the labels iterator. It returns a Labels object
    #
    # Returns a Labels object
    #
    # Typical usage:
    #
    #   browser.labels.each { |l| puts l.to_s }            # iterate through all the labels on the page
    #   browser.labels[1].to_s                             # goto the first label on the page
    #   browser.labels.length                              # show how many labels are on the page.
    #
    def labels
      Labels.new(self)
    end
    
    
    # This is the main method for accessing a generic element with a given attibute
    #  *  how   - symbol - how we access the element. Supports all values except :index and :xpath
    #  *  what  - string, integer or regular expression - what we are looking for,
    #
    # Valid values for 'how' are listed in the Watir Wiki - http://wiki.openqa.org/display/WTR/Methods+supported+by+Element
    #
    # returns an Watir::Element object
    #
    # Typical Usage
    #
    #   ie.element(:class, /foo/)      # access the first element with class 'foo'. We can use a string in place of the regular expression
    #   ie.element(:id, "11")          # access the first element that matches an id
    def element(how, what)
      return HTMLElement.new(self, how, what)  
    end
    
    # this is the main method for accessing generic html elements by an attribute
    #
    # Returns a HTMLElements object
    #
    # Typical usage:
    #
    #   ie.elements(:class, 'test').each { |l| puts l.to_s }  # iterate through all elements of a given attribute
    #   ie.elements(:alt, 'foo')[1].to_s                       # get the first element of a given attribute
    #   ie.elements(:id, 'foo').length                        # show how many elements are foung in the collection
    #
    def elements(how, what)
      return HTMLElements.new(self, how, what)  
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
      puts "-----------Objects in page -------------"
      doc = document
      s = ""
      props = ["name", "id", "value", "alt", "src"]
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
    def locate_input_element(how, what, types, value=nil, klass=nil)
      case how
      when :xpath
        return element_by_xpath(what)
      when :css
        return element_by_css(what)
      when :ole_object
        return what
      end
      # else:
      
      locator = InputElementLocator.new self, types
      locator.specifier = [how, what, value]
      locator.document = document
      return locator.element if locator.fast_locate
      # todo: restrict search to elements.getElementsByTag('INPUT'); faster
      locator.elements = ole_inner_elements if locator.elements.nil?
      locator.klass = klass if klass 
      locator.locate
    end
    
    # abstract method for locating an element using a CSS selector expression
    def element_by_css(selector)
      raise MissingWayOfFindingObjectException, "CSS selectors not yet supported for #{self.class.name}"
    end
    
    # returns the ole object for the specified element
    def locate_tagged_element(tag, how, what)
      locator = TaggedElementLocator.new(self, tag)
      locator.set_specifier(how, what)
      locator.locate
    end
    
    # returns the the locator object so you can iterate 
    # over the elements using #each
    def locate_all_elements(how, what)
      locator = ElementLocator.new(self)
      locator.set_specifier(how, what)
      locator
    end
    
  end # module
end

=begin
    #
    # This module contains the factory methods that are used to access most html objects
    #
    # For example, to access a button on a web page that has the following html
    #  <input type = button name= 'b1' value='Click Me' onClick='javascript:doSomething()'>
    #
    # the following Firewatir code could be used
    #
    #  ff.button(:name, 'b1').click
    #
    # or
    #
    #  ff.button(:value, 'Click Me').to_s
    # 
    # One can use any attribute to uniquely identify an element including the user defined attributes
    # that is rendered on the HTML screen. Though, Attribute used to access an element depends on the type of element,
    # attributes used frequently to address an element are listed below
    #
    #    :index      - find the item using the index in the container ( a container can be a document, 
    #    		a TableCell, a Span, a Div or a P)
    #                  index is 1 based
    #    :name       - find the item using the name attribute
    #    :id         - find the item using the id attribute
    #    :value      - find the item using the value attribute
    #    :caption    - same as value
    #    :xpath      - finds the item using xpath query
    #
    # Typical Usage
    #
    #    ff.button(:id,    'b_1')                       # access the button with an ID of b_1
    #    ff.button(:name,  'verify_data')               # access the button with a name of verify_data
    #    ff.button(:value, 'Login')                     # access the button with a value (the text displayed on the button) of Login
    #    ff.button(:caption, 'Login')                   # same as above
    #    ff.button(:value, /Log/)                       # access the button that has text matching /Log/
    #    ff.button(:index, 2)                           # access the second button on the page ( 1 based, so the first button is accessed with :index,1)
    #
=end

require 'firewatir/exceptions'

module FireWatir
  module Container 
    include FireWatir
    include Watir::Exception
    include JsshSocket
    
    # IP Address of the machine where the script is to be executed. Default to localhost.
    MACHINE_IP = "127.0.0.1"
        
    # The default color for highlighting objects as they are accessed.
    DEFAULT_HIGHLIGHT_COLOR = "yellow"
    
    public
    #
    # Description:
    #    Used to access a frame element. Usually an <frame> or <iframe> HTML tag.
    #
    # Input:
    #   - how - The attribute used to identify the framet.
    #   - what - The value of that attribute. 
    #   If only one parameter is supplied, "how" is by default taken as name and the 
    #   parameter supplied becomes the value of the name attribute.
    #
    # Typical usage:
    #
    #   ff.frame(:index, 1) 
    #   ff.frame(:name , 'main_frame')
    #   ff.frame('main_frame')        # in this case, just a name is supplied.
    #
    # Output:
    #   Frame object.
    #
    def frame(how, what = nil)
      locate if respond_to?(:locate)
      if(what == nil)
        what = how
        how = :name
      end
      Frame.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access a form element. Usually an <form> HTML tag.
    #
    # Input:
    #   - how - The attribute used to identify the form.
    #   - what - The value of that attribute. 
    #   If only one parameter is supplied, "how" is by default taken as name and the 
    #   parameter supplied becomes the value of the name attribute.
    #
    # Typical usage:
    #
    #   ff.form(:index, 1) 
    #   ff.form(:name , 'main_form')
    #   ff.form('main_form')        # in this case, just a name is supplied.
    #
    # Output:
    #   Form object.
    #
    def form(how, what=nil)   
      locate if respond_to?(:locate)
      if(what == nil)
        what = how
        how = :name
      end    
      Form.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access a table. Usually an <table> HTML tag. 
    #
    # Input:
    #   - how - The attribute used to identify the table.
    #   - what - The value of that attribute. 
    #
    # Typical usage:
    #
    #   ff.table(:index, 1) #index starts from 1.
    #   ff.table(:id, 'main_table')
    #
    # Output:
    #   Table object.
    #
    def table(how, what=nil)
      locate if respond_to?(:locate)
      Table.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access a table cell. Usually an <td> HTML tag. 
    #
    # Input:
    #   - how - The attribute used to identify the cell.
    #   - what - The value of that attribute. 
    # 
    # Typical Usage:
    #   ff.cell(:id, 'tb_cell')
    #   ff.cell(:index, 1)
    #
    # Output:
    #    TableCell Object
    #
    def cell(how, what=nil)
      locate if respond_to?(:locate)
      TableCell.new(self, how, what)
    end
    
    # 
    # Description:
    #   Used to access a table row. Usually an <tr> HTML tag. 
    # 
    # Input:
    #   - how - The attribute used to identify the row.
    #   - what - The value of that attribute. 
    #
    # Typical Usage:
    #   ff.row(:id, 'tb_row')
    #   ff.row(:index, 1)
    #
    # Output: 
    #   TableRow object
    #
    def row(how, what=nil)
      locate if respond_to?(:locate)
      TableRow.new(self, how, what)
    end
    
    # 
    # Description:
    #   Used to access a button element. Usually an <input type = "button"> HTML tag.
    # 
    # Input:
    #   - how - The attribute used to identify the row.
    #   - what - The value of that attribute. 
    # 
    # Typical Usage:
    #    ff.button(:id,    'b_1')                       # access the button with an ID of b_1
    #    ff.button(:name,  'verify_data')               # access the button with a name of verify_data
    #
    #    if only a single parameter is supplied,  then :value is used as 'how' and parameter supplied is used as what. 
    #
    #    ff.button('Click Me')                          # access the button with a value of Click Me
    #
    # Output:
    #   Button element.
    #
    def button(how, what=nil)
      locate if respond_to?(:locate)
      if what.nil? && String === how
        what = how
        how = :value
      end    
      Button.new(self, how, what)
    end    
    
    # 
    # Description:
    #   Used for accessing a file field. Usually an <input type = file> HTML tag.  
    #  
    # Input:
    #   - how - Attribute used to identify the file field element
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #    ff.file_field(:id,   'up_1')                     # access the file upload fff.d with an ID of up_1
    #    ff.file_field(:name, 'upload')                   # access the file upload fff.d with a name of upload
    #
    # Output:
    #   FileField object
    #
    def file_field(how, what = nil)
      locate if respond_to?(:locate)
      FileField.new(self, how, what)
    end    
    
    #
    # Description:
    #   Used for accessing a text field. Usually an <input type = text> HTML tag. or a text area - a  <textarea> tag
    #
    # Input:
    #   - how - Attribute used to identify the text field element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #    ff.text_field(:id,   'user_name')                 # access the text field with an ID of user_name
    #    ff.text_field(:name, 'address')                   # access the text field with a name of address
    #
    # Output:
    #   TextField object.
    #
    def text_field(how, what = nil)
      locate if respond_to?(:locate)
      TextField.new(self, how, what)
    end    
    
    # 
    # Description:
    #   Used to access hidden field element. Usually an <input type = hidden> HTML tag
    #
    # Input:
    #   - how - Attribute used to identify the hidden element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #    ff.hidden(:id,   'user_name')                 # access the hidden element with an ID of user_name
    #    ff.hidden(:name, 'address')                   # access the hidden element with a name of address
    #
    # Output:
    #   Hidden object.
    #
    def hidden(how, what=nil)
      locate if respond_to?(:locate)
      return Hidden.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access select list element. Usually an <select> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the select element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #    ff.select_list(:id,   'user_name')                 # access the select list with an ID of user_name
    #    ff.select_list(:name, 'address')                   # access the select list with a name of address
    #
    # Output:
    #   Select List object.
    #
    def select_list(how, what=nil) 
      locate if respond_to?(:locate)
      return SelectList.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access checkbox element. Usually an <input type = checkbox> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the check box element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #   ff.checkbox(:id,   'user_name')                 # access the checkbox element with an ID of user_name
    #   ff.checkbox(:name, 'address')                   # access the checkbox element with a name of address
    #   In many instances, checkboxes on an html page have the same name, but are identified by different values. An example is shown next.
    #
    #   <input type = checkbox name = email_frequency value = 'daily' > Daily Email
    #   <input type = checkbox name = email_frequency value = 'Weekly'> Weekly Email
    #   <input type = checkbox name = email_frequency value = 'monthly'>Monthly Email
    #
    #   FireWatir can access these using the following:
    #
    #   ff.checkbox(:id, 'day_to_send' , 'monday' )         # access the check box with an id of day_to_send and a value of monday
    #   ff.checkbox(:name ,'email_frequency', 'weekly')     # access the check box with a name of email_frequency and a value of 'weekly'
    #
    # Output:
    #   Checkbox object.
    #
    def checkbox(how, what=nil, value = nil) 
      locate if respond_to?(:locate)
      return CheckBox.new(self, how, what, value) 
    end
    
    #
    # Description:
    #   Used to access radio button element. Usually an <input type = radio> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the radio button element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #   ff.radio(:id,   'user_name')                 # access the radio button element with an ID of user_name
    #   ff.radio(:name, 'address')                   # access the radio button element with a name of address
    #   In many instances, radio buttons on an html page have the same name, but are identified by different values. An example is shown next.
    #
    #   <input type = radio name = email_frequency value = 'daily' > Daily Email
    #   <input type = radio name = email_frequency value = 'Weekly'> Weekly Email
    #   <input type = radio name = email_frequency value = 'monthly'>Monthly Email
    #
    #   FireWatir can access these using the following:
    #
    #   ff.radio(:id, 'day_to_send' , 'monday' )         # access the radio button with an id of day_to_send and a value of monday
    #   ff.radio(:name ,'email_frequency', 'weekly')     # access the radio button with a name of email_frequency and a value of 'weekly'
    #
    # Output:
    #   Radio button object.
    #
    def radio(how, what=nil, value = nil) 
      locate if respond_to?(:locate)
      return Radio.new(self, how, what, value) 
    end
    
    #
    # Description:
    #   Used to access link element. Usually an <a> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the link element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #    ff.link(:id,   'user_name')                 # access the link element with an ID of user_name
    #    ff.link(:name, 'address')                   # access the link element with a name of address
    #
    # Output:
    #   Link object.
    #
    def link(how, what=nil) 
      locate if respond_to?(:locate)
      return Link.new(self, how, what)
    end
    
    #
    # Description:
    #   Used to access image element. Usually an <img> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the image element.
    #   - what - Value of that attribute. 
    #
    # Typical Usage:
    #
    #    ff.image(:id,   'user_name')                 # access the image element with an ID of user_name
    #    ff.image(:name, 'address')                   # access the image element with a name of address
    #
    # Output:
    #   Image object.
    #
    def image(how, what = nil)
      locate if respond_to?(:locate)
      Image.new(self, how, what)
    end    
    
    
    #
    # Description:
    #   Used to access a definition list element - a <dl> HTML tag.
    #
    # Input:
    #   - how - Attribute used to identify the definition list element.
    #   - what - Value of that attribute.
    #
    # Typical Usage:
    #
    #    ff.dl(:id, 'user_name')                    # access the dl element with an ID of user_name
    #    ff.dl(:title, 'address')                   # access the dl element with a title of address
    #
    # Returns:
    #   Dl object.
    #
    def dl(how, what = nil)
      locate if respond_to?(:locate)
      Dl.new(self, how, what)
    end

    #
    # Description:
    #   Used to access a definition term element - a <dt> HTML tag.
    #
    # Input:
    #   - how  - Attribute used to identify the image element.
    #   - what - Value of that attribute.
    #
    # Typical Usage:
    #
    #    ff.dt(:id, 'user_name')                    # access the dt element with an ID of user_name
    #    ff.dt(:title, 'address')                   # access the dt element with a title of address
    #
    # Returns:
    #   Dt object.
    #
    def dt(how, what = nil)
      locate if respond_to?(:locate)
      Dt.new(self, how, what)
    end

    #
    # Description:
    #   Used to access a definition description element - a <dd> HTML tag.
    #
    # Input:
    #   - how  - Attribute used to identify the image element.
    #   - what - Value of that attribute.
    #
    # Typical Usage:
    #
    #    ff.dd(:id, 'user_name')                    # access the dd element with an ID of user_name
    #    ff.dd(:title, 'address')                   # access the dd element with a title of address
    #
    # Returns:
    #   Dd object.
    #
    def dd(how, what = nil)
      locate if respond_to?(:locate)
      Dd.new(self, how, what)
    end

    # Description:
    #	Searching for Page Elements. Not for external consumption.
    #        
    # def ole_inner_elements
    # return document.body.all 
    # end
    # private :ole_inner_elements
    
    
    # 
    # Description:
    #   This method shows the available objects on the current page.
    #   This is usually only used for debugging or writing new test scripts.
    #   This is a nice feature to help find out what HTML objects are on a page
    #   when developing a test case using FireWatir.
    #
    # Typical Usage:
    #   ff.show_all_objects
    #
    # Output:
    #   Prints all the available elements on the page.
    #
    def show_all_objects(output = true)
      locate if respond_to?(:locate)
      elements = Document.new(self).all
      if output
        puts "-----------Objects in the current context-------------"
        puts elements.length
        elements.each  do |n|
          puts n.tagName
          puts n.to_s
          puts "------------------------------------------"
        end
        puts "Total number of objects in the current context :	#{elements.length}"
      end
      return elements
      # Test the index access. 
      # puts doc[35].to_s
    end
    
  end
end # module 


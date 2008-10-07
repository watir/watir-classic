=begin
#
# Contains class definition of each HTML element that FireWatir can address.
# All classes inehrit from Element base class defined in MozillaBaseElement.rb
# User should not create instance of these classes. As they are created by using
# container#element methods. For e.g. container#button, container#link etc.
#
# All the methods in the classes first checks if element exists or not. If not then
# raises UnknownObjectException.
#
=end

require 'activesupport'
module FireWatir
  
  class Frame < Element 
    
    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of frame or iframe object.
    #
    # Input:
    #   - how - Attribute to identify the frame element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end
    
    def locate
      if(@how == :jssh_name)
        @element_name = @what
      else    
        @element_name = locate_frame(@how, @what)
      end    
      #puts @element_name
      @o = self
      
      unless @element_name
        raise UnknownFrameException, "Unable to locate a frame using #{@how} and #{@what}. "
      end    
    end
    
    def html
      assert_exists
      get_frame_html
    end
  end
  
  class Form < Element
    
    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of form object.
    #
    # Input:
    #   - how - Attribute to identify the form element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end
    
    def locate
      # Get form using xpath.
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath    
        @element_name = element_by_xpath(container, @what)
      else
        @element_name = locate_tagged_element("form", @how, @what)
      end
      @o = self
    end
    
    # Submit the form. Equivalent to pressing Enter or Return to submit a form. 
    def submit
      assert_exists
      submit_form 
      @o.wait
    end   
    
  end # class Form
  
  # Base class containing items that are common between the span, div, label, p and pre classes.
  class NonControlElement < Element
    def self.inherited subclass
      class_name = subclass.to_s.demodulize
      method_name = class_name.underscore
      FireWatir::Container.module_eval "def #{method_name}(how, what=nil)
      locate if defined?(locate)
      return #{class_name}.new(self, how, what); end"
    end
    
    attr_accessor :element_name
    #def get_element_name
    #    return @element_name
    #end
    #
    # Description:
    #   Locate the element on the page. Element can be a span, div, label, p or pre HTML tag.
    #
    def locate
      if(@how == :jssh_name)
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element(self.class::TAG, @how, @what)
      end
      @o = self
    end            

    #   - how - Attribute to identify the element.
    #   - what - Value of that attribute.
    def initialize(container, how, what)
      #@element = Element.new(nil)
      @how = how
      @what = what
      @container = container
      @o = nil
    end
    
    # Returns a string of properties of the object.
    def to_s(attributes = nil)
      assert_exists
      hash_properties = {"text"=>"innerHTML"}
      hash_properties.update(attributes) if attributes != nil
      r = super(hash_properties)
      #r = string_creator
      #r += span_div_string_creator
      return r.join("\n")
    end
    
  end
  
  class Pre < NonControlElement
    TAG = 'PRE'
  end
  
  class P < NonControlElement 
    TAG = 'P'
  end
  
  class Div < NonControlElement 
    TAG = 'DIV'
  end
  
  class Span < NonControlElement 
    TAG = 'SPAN'
  end
  
  class Label < NonControlElement
    TAG = 'LABEL'
    
    #
    # Description:
    #   Used to populate the properties in the to_s method.
    #
    #def label_string_creator
    #    n = []
    #    n <<   "for:".ljust(TO_S_SIZE) + self.for
    #    n <<   "inner text:".ljust(TO_S_SIZE) + self.text
    #    return n
    #end
    #private :label_string_creator
    
    #
    # Description:
    #   Creates string of properties of the object.
    #
    def to_s
      assert_exists
      super({"for" => "htmlFor","text" => "innerHTML"})
      #   r=r + label_string_creator
    end
  end
  
  class Table < Element
    attr_accessor :element_name
    TAG = 'TABLE'
    
    #   - how - Attribute to identify the table element.
    #   - what - Value of that attribute.
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
      @o = nil
      #super nil
    end
    
    #
    # Description:
    #   Locate the table element.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('TABLE', @how, @what)
      end
      @o = self
    end
    
    #
    # Description:
    #   Override the highlight method, as if the tables rows are set to have a background color, 
    #   this will override the table background color,  and the normal flash method wont work
    #
    def highlight(set_or_clear )
      
      if set_or_clear == :set
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
    
    #
    # Description:
    #   Used to populate the properties in the to_s method.
    #
    #def table_string_creator
    #    n = []
    #    n <<   "rows:".ljust(TO_S_SIZE) + self.row_count.to_s
    #    n <<   "cols:".ljust(TO_S_SIZE) + self.column_count.to_s
    #    return n
    #end
    #private :table_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    # TODO: Implement to_s method for this class.
    
    def to_s
      assert_exists
      r = super({"rows" => "rows.length","columns" => "columnLength", "cellspacing" => "cellspacing", "cellpadding" => "cellpadding", "border" => "border"})
      # r += self.column_count.to_s
    end
    
    #
    # Description:
    #   Gets the number of rows in the table.
    #
    # Output:
    #   Number of rows.
    #
    def row_count 
      assert_exists
      return rows.length
    end
    
    #
    # Description:
    #   Gets the table as a 2 dimensional array. Dont expect too much if there are nested tables, colspan etc.
    #
    # Output:
    #   2D array with rows and column text of the table.
    #
    def to_a
      assert_exists
      y = []
      table_rows = rows
      for row in table_rows
        x = []
        row.each do |td|
          x << td.to_s.strip
        end
        y << x
      end
      return y
    end
    
    #
    # Description:
    #   Gets the array of rows in the table.
    #
    # Output:
    #   Array of rows.
    #
    def rows
      assert_exists
      arr_rows = get_rows
      table_rows = Array.new(arr_rows.length)
      for i in 0..arr_rows.length - 1 do
        table_rows[i] = TableRow.new(@container, :jssh_name, arr_rows[i])
      end
      return table_rows
    end
    
    #
    # Description:
    #   Get row at particular index in table.
    #
    # Input:
    #   key - row index
    #
    # Output:
    #   Table Row element
    #
    def [](key)
      assert_exists
      arr_rows = rows
      return arr_rows[key - 1]
    end
    
    #
    # Desription:
    #   Iterate over each table row element.
    #
    def each
      assert_exists
      arr_rows = rows
      for i in 0..arr_rows.length - 1 do
        yield arr_rows[i]
      end
    end
    
    #
    # Description:
    #   Get column count of first row in the table.
    #
    # Output:
    #   Number of columns in first row.
    #
    def column_count
      assert_exists
      arr_rows = rows
      return arr_rows[0].column_count
    end
    
    #
    # Description:
    #   Get values of specified column in each row.
    #
    # Input:
    #   Column number
    #
    # Output:
    #   Values of column (specified as input) in each row
    #
    def column_values(column)
      assert_exists
      arr_rows = rows
      values = Array.new(arr_rows.length)
      for i in 0..arr_rows.length - 1 do
        values[i] = arr_rows[i][column].to_s 
      end
      return values
    end
    
    #
    # Description:
    #   Get values of all the column in specified row.
    #
    # Input:
    #   Row number.
    #
    # Output:
    #   Value of all columns present in the row.
    #
    def row_values(row)
      assert_exists
      arr_rows = rows
      cells = arr_rows[row - 1].cells
      values = Array.new(cells.length)
      for i in 0..cells.length - 1 do
        values[i] = cells[i].to_s
      end
      return values
    end
  end
  
  # this class is a collection of the table body objects that exist in the table
  # it wouldnt normally be created by a user, but gets returned by the bodies method of the Table object
  # many of the methods available to this object are inherited from the Element class
  # TODO: Implement TableBodies class.
  #class TableBodies < Element 
  #
  # Description:
  #   Initializes the form element.
  #
  # Input:
  #   - how - Attribute to identify the form element.
  #   - what - Value of that attribute.
  #
  #def initialize( parent_table)
  #    element = container
  #    @o = parent_table     # in this case, @o is the parent table
  #end
  
  # returns the number of TableBodies that exist in the table
  #def length
  #    assert_exists
  #    return @o.tBodies.length
  #end
  
  # returns the n'th Body as a FireWatir TableBody object
  #def []n
  #    assert_exists
  #    return TableBody.new(element, :direct, ole_table_body_at_index(n))
  #end
  
  # returns an ole table body
  #def ole_table_body_at_index(n)
  #    return @o.tBodies[(n-1).to_s]
  #end
  
  # iterates through each of the TableBodies in the Table. Yields a TableBody object
  #def each
  #    1.upto( @o.tBodies.length ) { |i| yield TableBody.new(element, :direct, ole_table_body_at_index(i)) }
  #end
  
  #end
  
  # this class is a table body
  # TODO: Implement TableBody class
  #class TableBody < Element
  #def locate
  #    @o = nil
  #    if @how == :direct
  #        @o = @what     # in this case, @o is the table body
  #    elsif @how == :index
  #        @o = @parent_table.bodies.ole_table_body_at_index(@what)
  #    end
  #    @rows = []
  #    if @o
  #        @o.rows.each do |oo|
  #            @rows << TableRow.new(element, :direct, oo)
  #        end
  #    end
  #end            
  
  #
  # Description:
  #   Initializes the form element.
  #
  # Input:
  #   - how - Attribute to identify the form element.
  #   - what - Value of that attribute.
  #
  #def initialize( how, what, parent_table = nil)
  #    element = container
  #    @how = how
  #    @what = what
  #    @parent_table = parent_table
  #    super nil
  #end
  
  # returns the specified row as a TableRow object
  #def [](n)
  #    assert_exists
  #    return @rows[n - 1]
  #end
  
  # iterates through all the rows in the table body
  #def each
  #    locate
  #    0.upto(@rows.length - 1) { |i| yield @rows[i] }
  #end
  
  # returns the number of rows in this table body.
  #def length
  #    return @rows.length
  #end
  #end
  
  
  #
  # Description:
  # Class for Table row element.
  #
  class TableRow < Element
    attr_accessor :element_name
    
    #
    # Description:
    #   Locate the table row element on the page.
    #
    def locate
      @o = nil
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("TR", @how, @what)   
      end
      @o = self
    end
    
    #
    # Description:
    #   Initializes the instance of table row object.
    #
    # Input:
    #   - how - Attribute to identify the table row element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how   
      @what = what   
      @container = container
      #super nil
    end
    
    #
    # Description:
    #   Gets the length of columns in table row.
    #
    # Output:
    #   Length of columns in table row.
    #
    def column_count
      assert_exists
      arr_cells = cells
      return arr_cells.length
    end
    
    #
    # Description:
    #   Get cell at specified index in a row.
    #
    # Input:
    #   key - column index.
    #
    # Output:
    #   Table cell element at specified index.
    #
    def [] (key)
      assert_exists
      arr_cells = cells
      return arr_cells[key - 1]
    end
    
    #
    # Description:
    #   Iterate over each cell in a row.
    #
    def each
      assert_exists
      arr_cells = cells
      for i in 0..arr_cells.length - 1 do
        yield arr_cells[i]
      end
    end    
    
    #
    # Description:
    #   Get array of all cells in Table Row
    #
    # Output:
    #   Array containing Table Cell elements.
    #
    def cells
      assert_exists        
      arr_cells = get_cells
      row_cells = Array.new(arr_cells.length)
      for i in 0..arr_cells.length - 1 do
        row_cells[i] = TableCell.new(@container, :jssh_name, arr_cells[i])
      end
      return row_cells
    end
  end
  
  #
  # Description:
  # Class for Table Cell.
  #
  class TableCell < Element
    attr_accessor :element_name
    
    # Description:
    #   Locate the table cell element on the page.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("TD", @how, @what)   
      end
      @o = self
    end
    
    #
    # Description:
    #   Initializes the instance of table cell object.
    #
    # Input:
    #   - how - Attribute to identify the table cell element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)   
      @how = how   
      @what = what   
      @container = container
      #super nil   
    end 
    
    alias to_s text
    
    #
    # Description:
    #   Gets the col span of table cell.
    #
    # Output:
    #   Colspan of table cell.
    #
    def colspan
      assert_exists
      @o.colSpan
    end
    
  end
  
  #
  # Description:
  #   Class for Image element.
  #
  class Image < Element
    attr_accessor :element_name
    TAG = 'IMG'
    #
    # Description:
    #   Initializes the instance of image object.
    #
    # Input:
    #   - how - Attribute to identify the image element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end
    
    # Description:
    #   Locate the image element on the page.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('IMG', @how, @what)
      end
      @o = self
    end            
    
    #
    # Description:
    #   Used to populate the properties in to_s method. Not used anymore
    #
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
      super({"src" => "src","width" => "width","height" => "height","alt" => "alt"})
    end
    
    # this method returns the file created date of the image
    #def fileCreatedDate
    #    assert_exists
    #    return @o.invoke("fileCreatedDate")
    #end
    
    # this method returns the filesize of the image
    #def fileSize
    #    assert_exists
    #    return @o.invoke("fileSize").to_s
    #end
    
    #
    # Description:
    #   Gets the width of the image in pixels, as a string.
    #
    # Output:
    #   Width of image (in pixels).
    #
    def width
      assert_exists
      return @o.invoke("width").to_s
    end
    
    #
    # Description:
    #   Gets the height of the image in pixels, as a string.
    #
    # Output:
    #   Height of image (in pixels).
    #
    def height
      assert_exists
      return @o.invoke("height").to_s
    end
    
    # This method attempts to find out if the image was actually loaded by the web browser. 
    # If the image was not loaded, the browser is unable to determine some of the properties. 
    # We look for these missing properties to see if the image is really there or not. 
    # If the Disk cache is full ( tools menu -> Internet options -> Temporary Internet Files) , it may produce incorrect responses.
    #def hasLoaded?
    #    locate
    #    raise UnknownObjectException, "Unable to locate image using #{@how} and #{@what}" if @o == nil
    #    return false if @o.fileCreatedDate == "" and  @o.fileSize.to_i == -1
    #    return true
    #end
    
    #
    # Description:
    #   Highlights the image ( in fact it adds or removes a border around the image)
    #
    # Input:
    #   - set_or_clear - :set to set the border, :clear to remove it
    #
    def highlight( set_or_clear )
      if set_or_clear == :set
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
    private :highlight
  end                                                      
  
  
  #
  # Description:
  #   Class for Link element.
  #
  class Link < Element
    attr_accessor :element_name
    TAG = 'A'
    #
    # Description:
    #   Initializes the instance of link element.
    #
    # Input:
    #   - how - Attribute to identify the link element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
    end
    
    #
    # Description:
    #   Locate the link element on the page.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element('A', @how, @what)
      end
      @o = self
    end
    
    #TODO: if an image is used as part of the link, this will return true      
    #def link_has_image
    #    assert_exists
    #    return true  if @o.getElementsByTagName("IMG").length > 0
    #    return false
    #end
    
    #TODO: this method returns the src of an image, if an image is used as part of the link
    #def src # BUG?
    #    assert_exists
    #    if @o.getElementsByTagName("IMG").length > 0
    #        return  @o.getElementsByTagName("IMG")[0.to_s].src
    #    else
    #        return ""
    #    end
    #end
    
    #
    # Description:
    #   Used to populate the properties in to_s method.
    #
    #def link_string_creator
    #    n = []
    #    n <<   "href:".ljust(TO_S_SIZE) + self.href
    #    n <<   "inner text:".ljust(TO_S_SIZE) + self.text
    #    n <<   "img src:".ljust(TO_S_SIZE) + self.src if self.link_has_image
    #    return n
    #    end
    
    # returns a textual description of the link
    
    def to_s
      assert_exists
      super({"href" => "href","inner text" => "text"})
    end
  end
  
  #
  # Description:    
  #   Base class containing items that are common between select list, text field, button, hidden, file field classes.
  #
  class InputElement < Element
    attr_accessor :element_name
    #
    # Description:
    #   Locate the element on the page. Element can be a select list, text field, button, hidden, file field.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        if(self.class::INPUT_TYPES.include?("select-one"))
          @element_name = locate_tagged_element("select", @how, @what, self.class::INPUT_TYPES)
        else    
          @element_name = locate_tagged_element("input", @how, @what, self.class::INPUT_TYPES)
        end    
      end
      @o = self
    end
    #
    # Description:
    #   Initializes the instance of element.
    #
    # Input:
    #   - how - Attribute to identify the element.
    #   - what - Value of that attribute.
    #
    def initialize(container, how, what)
      @how = how
      @what = what
      @container = container
      @element_name = ""
      #super(nil)
    end
  end
  
  #
  # Description:
  #   Class for SelectList element.
  #
  class SelectList < InputElement
    INPUT_TYPES = ["select-one", "select-multiple"]
    
    attr_accessor :o
    
    #
    # Description:
    #   Clears the selected items in the select box.
    #
    def clearSelection
      assert_exists
      #highlight( :set)
      wait = false
      @o.each do |selectBoxItem|
        if selectBoxItem.selected
          selectBoxItem.selected = false
          wait = true
        end
      end
      @o.wait if wait
      #highlight( :clear)
    end
    
    def each
      assert_exists
      arr_options = options 
      #puts arr_options[0]#.length
      for i in 0..arr_options.length - 1 do
        yield Option.new(self, :jssh_name, arr_options[i])
      end
    end
    
    #
    # Description:
    #   Get option element at specified index in select list.
    #
    # Input:
    #   key - option index
    #
    # Output:
    #   Option element at specified index
    #
    def [] (key)
      assert_exists
      arr_options = options
      return Option.new(self, :jssh_name, arr_options[key - 1])
    end
    
    #
    # Description:
    #   Selects an item by text. If you need to select multiple items you need to call this function for each item.
    # 
    # Input:
    #   - item - Text of item to be selected.
    #
    def select( item )
      select_item_in_select_list(:text, item)
    end
    
    #
    # Description:
    #   Selects an item by value. If you need to select multiple items you need to call this function for each item.
    #
    # Input:
    # - item - Value of the item to be selected.
    #
    def select_value( item )
      select_item_in_select_list( :value , item )
    end
    
    # Description:
    #   Selects item from the select box.
    #
    # Input:
    #   - name  - :value or :text - how we find an item in the select box
    #   - item  - value of either item text or item value.
    #
    def select_item_in_select_list(attribute, value)
      assert_exists
      highlight( :set )
      doBreak = false
      #element.log "Setting box #{@o.name} to #{attribute} #{value} "
      @o.each do |option| # items in the list
        if value.matches( option.invoke(attribute.to_s))
          if option.selected
            doBreak = true
            break
          else
            option.selected = true
            @o.fireEvent("onChange")
            @o.wait
            doBreak = true
            break
          end
        end
      end
      unless doBreak
        raise NoValueFoundException, 
                    "No option with #{attribute.to_s} of #{value} in this select element"  
      end
      highlight( :clear )
    end
    private :select_item_in_select_list
    
    #
    # Description:
    #   Gets all the items in the select list as an array. 
    #   An empty array is returned if the select box has no contents.
    #
    # Output:
    #   Array containing the items of the select list.
    #
    def getAllContents() # BUG: camel_case.rb
      assert_exists
      #element.log "There are #{@o.length} items"
      returnArray = []
      @o.each { |thisItem| returnArray << thisItem.text }
      return returnArray 
    end
    
    #
    # Description:
    #   Gets all the selected items in the select list as an array. 
    #   An empty array is returned if the select box has no selected item.
    #
    # Output:
    #   Array containing the selected items of the select list.
    #
    def getSelectedItems
      assert_exists
      returnArray = []
      #element.log "There are #{@o.length} items"
      @o.each do |thisItem|
        #puts "#{thisItem.selected}"
        if thisItem.selected
          #element.log "Item ( #{thisItem.text} ) is selected"
          returnArray << thisItem.text 
        end
      end
      return returnArray 
    end
    
    #
    # Description:
    #   Get the option using attribute and its value.
    #
    # Input:
    #   - attribute - Attribute used to find the option.
    #   - value - value of that attribute.
    #
    def option (attribute, value)
      assert_exists
      Option.new(self, attribute, value)
    end
  end
  
  #
  # Description:
  #   Class for Option element.
  #
  class Option < SelectList
    #
    # Description:
    #   Initializes the instance of option object.
    #
    # Input:
    #   - select_list - instance of select list element.
    #   - attribute - Attribute to identify the option.
    #   - value - Value of that attribute.
    #
    def initialize (select_list, attribute, value)
      @select_list = @container = select_list
      @how = attribute
      @what = value
      @option = nil
      @element_name = ""
      
      unless [:text, :value, :jssh_name].include? attribute 
        raise MissingWayOfFindingObjectException,
                "Option does not support attribute #{@how}"
      end
      #puts @select_list.o.length
      #puts "what is : #{@what}, how is #{@how}, list name is : #{@select_list.element_name}"
      if(attribute == :jssh_name)
        @element_name = @what
        @option = self
      else    
        @select_list.o.each do |option| # items in the list
          #puts "option is : #{option}"
          if(attribute == :value)
            match_value = option.value
          else    
            match_value = option.text
          end    
          #puts "value is #{match_value}"
          if value.matches( match_value) #option.invoke(attribute))
            @option = option
            @element_name = option.element_name
            break
          end
        end
      end    
    end
    
    #
    # Description:
    #   Checks if option exists or not.
    #
    def assert_exists
      unless @option
        raise UnknownObjectException,  
                "Unable to locate an option using #{@how} and #{@what}"
      end
    end
    private :assert_exists
    
    #
    # Description:
    #   Selects the option.
    #
    def select
      assert_exists
      if(@how == :text)
        @select_list.select(@what)
      elsif(@how == :value)
        @select_list.select_value(@what)
      end    
    end
    
    #
    # Description:
    #   Gets the class name of the option.
    #
    # Output:
    #   Class name of the option.
    #
    def class_name
      assert_exists
      option_class_name
    end
    
    #
    # Description:
    #   Gets the text of the option.
    #
    # Output:
    #   Text of the option.
    #
    def text
      assert_exists
      option_text
    end
    
    #
    # Description:
    #   Gets the value of the option.
    #
    # Output:
    #   Value of the option.
    #
    def value
      assert_exists
      option_value
    end
    
    #
    # Description:
    #   Gets the status of the option; whether it is selected or not.
    #
    # Output:
    #   True if option is selected, false otherwise.
    #
    def selected
      assert_exists
      #@option.selected
      option_selected
    end
  end    
  
  #
  # Description:
  #   Class for Button element.
  #
  class Button < InputElement
    INPUT_TYPES = ["button", "submit", "image", "reset"] 
    def locate
      super
      @o = @element.locate_tagged_element("button", @how, @what, self.class::INPUT_TYPES) unless @o
    end
  end
  
  #
  # Description:
  # Class for Text Field element.
  #
  class TextField < InputElement
    INPUT_TYPES = ["text", "password", "textarea"] 
    
    # Gets the size of the text field element.
    def_wrap :size
    # Gets max length of the text field element.
    def_wrap :maxlength
    # Returns true if the text field is read only, false otherwise.
    def_wrap :readonly?, :readOnly
    
    #
    # Description:
    #   Used to populate the properties in to_s method
    #
    #def text_string_creator
    #    n = []
    #    n <<   "length:".ljust(TO_S_SIZE) + self.size.to_s
    #    n <<   "max length:".ljust(TO_S_SIZE) + self.maxlength.to_s
    #    n <<   "read only:".ljust(TO_S_SIZE) + self.readonly?.to_s
    #
    #    return n
    #end
    #private :text_string_creator
    
    # TODO: Impelement the to_s method.
    def to_s
      assert_exists
      super({"length" => "size","max length" => "maxLength","read only" => "readOnly" })
    end
    
    #
    # Description:
    #   Checks if object is read-only or not.
    #
    def assert_not_readonly
      raise ObjectReadOnlyException, "Textfield #{@how} and #{@what} is read only." if self.readonly?
    end                
    
    #
    # Description:
    #   Checks if the provided text matches with the contents of text field. Text can be a string or regular expression.
    #
    # Input:
    #   - containsThis - Text to verify. 
    #
    # Output:
    #   True if provided text matches with the contents of text field, false otherwise.
    #
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
    # TODO: Can we have support for this in Firefox.
    #def dragContentsTo( destination_how , destination_what)
    #    assert_exists
    #    destination = element.text_field(destination_how, destination_what)
    #    raise UnknownObjectException ,  "Unable to locate destination using #{destination_how } and #{destination_what } "   if destination.exists? == false
    
    #    @o.focus
    #    @o.select()
    #    value = self.value
    
    #   @o.fireEvent("onSelect")
    #    @o.fireEvent("ondragstart")
    #    @o.fireEvent("ondrag")
    #    destination.fireEvent("onDragEnter")
    #    destination.fireEvent("onDragOver")
    #    destination.fireEvent("ondrop")
    
    #    @o.fireEvent("ondragend")
    #    destination.value= ( destination.value + value.to_s  )
    #    self.value = ""
    #end
    
    #
    # Description:
    #   Clears the contents of the text field.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    def clear
      assert_exists
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      
      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      @o.fireEvent("onChange")
      @container.wait()
      highlight(:clear)
    end
    
    #
    # Description:
    #   Append the provided text to the contents of the text field.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    # Input:
    #   - setThis - Text to be appended.
    #
    def append( setThis)
      assert_exists
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus
      doKeyPress( setThis )
      highlight(:clear)
    end
    
    #
    # Description:
    #   Sets the contents of the text field to the provided text. Overwrite the existing contents.
    #   Raises ObjectDisabledException if text field is disabled.
    #   Raises ObjectReadOnlyException if text field is read only.
    #
    # Input:
    #   - setThis - Text to be set.
    #
    def set( setThis )
      assert_exists
      assert_enabled
      assert_not_readonly
      
      highlight(:set)
      @o.scrollIntoView
      @o.focus
      @o.select()
      @o.fireEvent("onSelect")
      @o.value = ""
      @o.fireEvent("onKeyPress")
      doKeyPress( setThis )
      highlight(:clear)
      @o.fireEvent("onChange")
      @o.fireEvent("onBlur")
    end
    
    #
    # Description:
    #   Sets the text of the text field withoud firing the events like onKeyPress, onKeyDown etc. This should not be used generally, but it
    #   is useful in situations where you need to set large text to the text field and you know that you don't have any event to be
    #   fired.
    #
    # Input:
    #   - v - Text to be set.
    #
    #def value=(v)
    #    assert_exists
    #    @o.value = v.to_s
    #end
    
    # 
    # Description:
    #   Used to set the value of text box and fires the event onKeyPress, onKeyDown, onKeyUp after each character.
    #   Shouldnot be used externally. Used internally by set and append methods.
    #
    # Input:
    #   - value - The string to enter into the text field
    #
    def doKeyPress( value )
      begin
        maxLength = @o.maxLength
        if (maxLength != -1 && value.length > maxLength)
          original_value = value
          value = original_value[0..maxLength]
          element.log " Supplied string is #{suppliedValue.length} chars, which exceeds the max length (#{maxLength}) of the field. Using value: #{value}"
        end
      rescue
        # probably a text area - so it doesnt have a max Length
        maxLength = -1
      end
      for i in 0..value.length-1   
        #sleep element.typingspeed   # typing speed
        c = value[i,1]
        #element.log  " adding c.chr " + c  #.chr.to_s
        @o.value = "#{(@o.value.to_s + c)}"   #c.chr
        @o.fireEvent("onKeyDown")
        @o.fireEvent("onKeyPress")
        @o.fireEvent("onKeyUp")
      end
      
    end
    private :doKeyPress
    
    alias readOnly? :readonly?
    alias getContents value
    alias maxLength maxlength
    
  end
  
  #
  # Description:
  #   Class for Hidden Field element.
  #
  class Hidden < TextField 
    INPUT_TYPES =  ["hidden"]
    
    #
    # Description:
    #   Sets the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    # Input:
    #   n - Value to be set.
    #
    def set(n)
      self.value=n
    end
    
    #
    # Description:
    #   Appends the value to the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    # Input:
    #   n - Value to be appended.
    #
    def append(n)
      self.value = self.value.to_s + n.to_s
    end
    
    #
    # Description:
    #   Clears the value of the hidden field. Overriden in this class, as there is no way to set focus to a hidden field
    #
    def clear
      self.value = ""
    end
    
    #
    # Description:
    #   Does nothing, as you cant set focus to a hidden field. Overridden here so that exception doesn't occurs.
    #
    def focus
    end
    
  end
  
  #
  # Description:
  #   Class for FileField element.
  #
  class FileField < InputElement
    INPUT_TYPES = ["file"]
    
    #
    # Description:
    #   Sets the path of the file in the textbox.
    #
    # Input:
    #   setPath - Path of the file.
    #
    def set(setPath)
      assert_exists
      
      setFileFieldValue(setPath)
    end
  end
  
  #
  # Description:
  #   Base class for checkbox and radio button elements.
  #
  class RadioCheckCommon < Element
    attr_accessor :element_name
    #
    # Description:
    #   Initializes the instance of element object. Element can be checkbox or radio button.
    #
    # Input:
    #   - how - Attribute to identify the element.
    #   - what - Value of that attribute.
    #   - value - value of the element.
    #
    def initialize(container, how, what, value = nil)
      @how = how
      @what = what
      @value = value
      @container = container
    end

    #
    # Description:
    #   Locate the element on the page. Element can be a checkbox or radio button.
    #
    def locate
      if @how == :jssh_name
        @element_name = @what
      elsif @how == :xpath
        @element_name = element_by_xpath(@container, @what)
      else
        @element_name = locate_tagged_element("input", @how, @what, @type, @value)
      end
      @o = self
    end
    
    #
    # Description:
    #   Checks if element i.e. radio button or check box is checked or not.
    #
    # Output:
    #   True if element is checked, false otherwise.
    #
    def isSet?
      assert_exists
      return @o.checked
    end
    alias getState isSet?
    
    #
    # Description:
    #   Unchecks the radio button or check box element.
    #   Raises ObjectDisabledException exception if element is disabled.
    #
    def clear
      assert_exists
      assert_enabled
      #highlight(:set)
      set_clear_item(false)
      #highlight(:clear)
    end
    
    #
    # Description:
    #   Checks the radio button or check box element.
    #   Raises ObjectDisabledException exception if element is disabled.
    #
    def set
      assert_exists
      assert_enabled
      #highlight(:set)
      set_clear_item(true)
      #highlight(:clear)
    end
    
    #
    # Description:
    #   Used by clear and set method to uncheck and check radio button and checkbox element respectively.
    #
    def set_clear_item(set)
      if set != @o.isSet?
        @o.fire_event("onclick") 
        @container.wait
      end
    end
    private :set_clear_item
    
  end
  
  #
  # Description:
  #   Class for RadioButton element.
  #
  class Radio < RadioCheckCommon 
    def initialize *args
      super
      @type = ["radio"]
    end
    
    def clear
      assert_exists
      assert_enabled
      #higlight(:set)
      @o.checked = false
      #highlight(:clear)
    end
  end
  
  #
  # Description:
  # Class for Checkbox element.
  #
  class CheckBox < RadioCheckCommon 
    def initialize *args
      super
      @type = ["checkbox"]
    end
    
    #
    # Description:
    #   Checks or unchecks the checkbox. If no value is supplied it will check the checkbox.
    #   Raises ObjectDisabledException exception if the object is disabled 
    #
    # Input:
    #   - set_or_clear - Parameter indicated whether to check or uncheck the checkbox.
    #                    True to check the check box, false for unchecking the checkbox.
    #
    def set( set_or_clear=true )
      assert_exists
      assert_enabled
      highlight(:set)
      
      if set_or_clear == true
        if @o.checked == false
          set_clear_item( true )
        end
      else
        self.clear
      end
      highlight(:clear )
    end
    
    #
    # Description:
    #   Unchecks the checkbox.
    #   Raises ObjectDisabledException exception if the object is disabled 
    #
    def clear
      assert_exists
      assert_enabled
      highlight( :set)
      if @o.checked == true
        set_clear_item( false )
      end
      highlight( :clear)
    end
  end
  
  # this class is the super class for the iterator classes ( buttons, links, spans etc
  # it would normally only be accessed by the iterator methods ( spans , links etc) of IE
  
  #class ElementCollections
  #    include Enumerable
  #    include Container
  # Super class for all the iteractor classes
  #   * container  - an instance of an IE object
  #    def initialize( container)
  #        element = container
  #        @length = length() # defined by subclasses
  
  # set up the items we want to display when the show method s used
  #        set_show_items
  #    end
  
  #    private 
  #    def set_show_items
  #        @show_attributes = AttributeLengthPairs.new( "id" , 20)
  #        @show_attributes.add( "name" , 20)
  #    end
  
  #    public
  #    def get_length_of_input_objects(object_type) 
  #        object_types = 
  #            if object_type.kind_of? Array 
  #                object_type  
  #            else
  #                [ object_type ]
  #            end
  
  #        length = 0
  #        objects = element.document.getElementsByTagName("INPUT")
  #        if  objects.length > 0 
  #            objects.each do |o|
  #                length += 1 if object_types.include?(o.invoke("type").downcase )
  #            end
  #        end    
  #        return length
  #    end
  
  # iterate through each of the elements in the collection in turn
  #    def each
  #        0.upto( @length-1 ) { |i | yield iterator_object(i) }
  #    end
  
  # allows access to a specific item in the collection
  #    def [](n)
  #        return iterator_object(n-1)
  #    end
  
  # this method is the way to show the objects, normally used from irb
  #   def show
  #       s="index".ljust(6)
  #       @show_attributes.each do |attribute_length_pair| 
  #           s=s + attribute_length_pair.attribute.ljust(attribute_length_pair.length)
  #       end
  
  #        index = 1
  #        self.each do |o|
  #            s= s+"\n"
  #            s=s + index.to_s.ljust(6)
  #            @show_attributes.each do |attribute_length_pair| 
  #                begin
  #                    s=s  + eval( 'o.getOLEObject.invoke("#{attribute_length_pair.attribute}")').to_s.ljust( attribute_length_pair.length  )
  #                rescue=>e
  #                    s=s+ " ".ljust( attribute_length_pair.length )
  #                end
  #            end
  #            index+=1
  #        end
  #        puts s 
  #    end
  
  # this method creates an object of the correct type that the iterators use
  #    private
  #    def iterator_object(i)
  #        element_class.new(element, :index, i+1)
  #    end
  #end
  
  #--
  #   These classes are not for public consumption, so we switch off rdoc
  
  # presumes element_class or element_tag is defined
  # for subclasses of ElementCollections
  # module CommonCollection
  #    def element_tag
  #        element_class.tag
  #    end
  #    def length
  #        element.document.getElementsByTagName(element_tag).length
  #    end
  # end        
  
  # This class is used as part of the .show method of the iterators class
  # it would not normally be used by a user
  #class AttributeLengthPairs
  
  # This class is used as part of the .show method of the iterators class
  # it would not normally be used by a user
  #    class AttributeLengthHolder
  #        attr_accessor :attribute
  #        attr_accessor :length
  
  #        def initialize( attrib, length)
  #            @attribute = attrib
  #            @length = length
  #        end
  #    end
  
  #    def initialize( attrib=nil , length=nil)
  #        @attr=[]
  #        add( attrib , length ) if attrib
  #        @index_counter=0
  #    end
  
  #    # BUG: Untested. (Null implementation passes all tests.)
  #    def add( attrib , length)
  #        @attr <<  AttributeLengthHolder.new( attrib , length )
  #    end
  
  #    def delete(attrib)
  #        item_to_delete=nil
  #        @attr.each_with_index do |e,i|
  #            item_to_delete = i if e.attribute==attrib
  #        end
  #        @attr.delete_at(item_to_delete ) unless item_to_delete == nil
  #    end
  
  #    def next
  #        temp = @attr[@index_counter]
  #        @index_counter +=1
  #        return temp
  #    end
  
  #    def each
  #            0.upto( @attr.length-1 ) { |i | yield @attr[i]   }
  #    end
  #end
  
  #    resume rdoc
  #   
  
  #   Class for accessing all the button elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#buttons method
  class Buttons < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["button", "image", "submit", "reset"])      
    end
  end
    
  #   Class for accessing all the File Field elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#file_fields method
  class FileFields < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["file"])
    end
  end
    
  #   Class for accessing all the CheckBox elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#checkboxes method
  class CheckBoxes < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["checkbox"])
    end
  end
  module Container
    alias checkboxes check_boxes
  end
  
  #   Class for accessing all the Radio button elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#radios method
  class Radios < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["radio"])
    end
  end
  
  #   Class for accessing all the select list elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#select_lists method
  class SelectLists < ElementCollections
    def locate_elements
      locate_tagged_elements("select", ["select-one", "select-multiple"])      
    end
  end
  
  #   Class for accessing all the link elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#links method
  class Links < ElementCollections; end
  
  #   Class for accessing all the image elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#images method
  class Images < ElementCollections; end
  
  #   Class for accessing all the text field elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#text_fields method
  class TextFields < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["text", "textarea", "password"])
    end
  end
  
  #   Class for accessing all the hidden elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#hiddens method
  class Hiddens < ElementCollections
    def locate_elements
      locate_tagged_elements("input", ["hidden"])
    end
  end
  
  #   Class for accessing all the table elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#tables method
  class Tables < ElementCollections; end
  
  #   Class for accessing all the label elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#labels method
  class Labels < ElementCollections; end
  
  #   Class for accessing all the pre element in the document.
  #   It would normally only be accessed by the FireWatir::Container#pres method
  class Pres < ElementCollections; end
  
  #   Class for accessing all the paragraph elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#ps method
  class Ps < ElementCollections; end
  
  #   Class for accessing all the span elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#spans method
  class Spans < ElementCollections; end
  
  #   Class for accessing all the div elements in the document.
  #   It would normally only be accessed by the FireWatir::Container#divs method
  class Divs < ElementCollections; end
  
  class Ul < NonControlElement  
    TAG = 'UL'
  end
  class Uls < ElementCollections; end
    
  class Li < NonControlElement
    TAG = 'LI'
  end
  class Lis < ElementCollections; end
  
  class H1 < NonControlElement
    TAG = 'H1'
  end
  
  class H2 < NonControlElement
    TAG = 'H2'
  end
  
  class H3 < NonControlElement
    TAG = 'H3'
  end
  
  class H4 < NonControlElement
    TAG = 'H4'
  end
  
  class H5 < NonControlElement
    TAG = 'H5'
  end
  
  class H6 < NonControlElement
    TAG = 'H6'
  end
  
  class Map < NonControlElement
    TAG = 'MAP'
  end
  class Maps < ElementCollections; end
  
  class Area < NonControlElement
    TAG = 'AREA'
  end
  class Areas < ElementCollections; end
    
end
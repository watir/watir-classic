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
    
    def set_container container #:nodoc:
      @container = container 
      @page_container = container.page_container
    end
        
    public

    # this method accesses a table cell.
    # how - symbol - how we access the cell, valid values are
    #    :id       - find the table cell with given id.
    #    :xpath    - find the table cell using xpath query.
    #
    # returns a TableCell Object
    def cell(how={}, what=nil)
      TableCell.new(self, how, what)
    end

    def cells(how={}, what=nil)
      TableCells.new(self)
    end
    
    # this method accesses a table row.
    # how - symbol - how we access the row, valid values are
    #    :id       - find the table row with given id.
    #    :xpath    - find the table row using xpath query.
    #
    # returns a TableRow object
    def row(how={}, what=nil)
      TableRow.new(self, how, what)
    end
    def rows(how={}, what=nil)
      TableRows.new(self, how, what)
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
      ModalDialog.new(self)
    end

    def javascript_dialog(opts={})
      JavascriptDialog.new(opts)
    end
    alias :dialog :javascript_dialog

    # this is the method for accessing the check boxes iterator. Returns a CheckBoxes object
    #
    # Typical usage:
    #
    #   browser.checkboxes.each { |c| puts c.to_s }             # iterate through all the check boxes on the page
    #   browser.checkboxes[1].to_s                              # goto the first check box on the page
    #   browser.checkboxes.length                               # show how many check boxes are on the page.
    def checkboxes(how={}, what=nil)
      CheckBoxes.new(self, how, what)
    end

    def checkbox(how={}, what=nil)
      check_box(how, what)
    end
    
    # This is the main method for accessing JavaScript popups.
    # returns a PopUp object
    def popup         # BUG this should not be on the container object!
      PopUp.new(self)
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
    def element(how={}, what=nil)
      HTMLElement.new(self, how, what)  
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
    def elements(how={}, what=nil)
      HTMLElements.new(self, how, what)  
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
    def locate_input_element(how, what, types, klass=nil)
      locator = InputElementLocator.new self, types
      locator.set_specifier how, what
      locator.document = document
      return locator.element if locator.fast_locate
      # todo: restrict search to elements.getElementsByTag('INPUT'); faster
      locator.elements = ole_inner_elements if locator.elements.nil?
      locator.klass = klass if klass 
      locator
    end
    
    # returns the ole object for the specified element
    def locate_tagged_element(tag, how, what)
      locator = TaggedElementLocator.new(self, tag)
      locator.set_specifier(how, what)
      locator
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

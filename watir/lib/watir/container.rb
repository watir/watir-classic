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
  # Is includable for classes that have @container, document and __ole_inner_elements
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

    # Searching for Page Elements
    # Not for external consumption
    #
    #++
    def __ole_inner_elements
      return document.body.all
    end
    
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
    
    # Locator Methods
    #
    # Not for external use, but cannot set to private due to usages in Element
    # classes.

    def locator_for(locator_class, tags, how, what, klass)
      locator = locator_class.new self, tags, klass
      locator.set_specifier how, what
      locator
    end
    
  end # module
end

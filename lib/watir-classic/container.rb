module Watir
  # This module contains the factory methods that are used to access all html objects.
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
  # there are many methods available to the {Button} object
  module Container
    include Watir::Exception
    
    # Note: @container is the container of this object, i.e. the container
    # of this container.
    # In other words, for browser.table().this_thing().text_field().set,
    # container of this_thing is the table.
    
    # This is used to change the typing speed when entering text on a page.
    # @private
    attr_accessor :typingspeed

    # @private
    attr_accessor :type_keys

    # The color we want to use for the active object. This can be any valid web-friendly color.
    # @private
    attr_accessor :activeObjectHighLightColor

    # The {Browser} object containing this element.
    attr_accessor :page_container
    alias_method :browser, :page_container
    
    def copy_test_config(container) # only used by form and frame
      @typingspeed = container.typingspeed
      @type_keys = container.type_keys
      @activeObjectHighLightColor = container.activeObjectHighLightColor
    end
    private :copy_test_config
    
    # Wait until Browser has finished loading the page.
    #--
    # called explicitly by most click and set methods
    # @private
    def wait(no_sleep=false)
      @container.wait(no_sleep)
    end
    
    # @private
    def set_container(container)
      @container = container 
      @page_container = container.page_container
    end
        
    public

    # @return [ModalDialog] modal dialog instance.
    def modal_dialog
      ModalDialog.new(self)
    end

    # Retrieve the JavaScript dialog instance.
    # Supported dialogs are alert, confirm and prompt.
    # @return [Alert] JavaScript dialog instance.
    def alert
      Alert.new(self)
    end

    # Searching for Page Elements
    # Not for external consumption
    # @private
    def __ole_inner_elements
      document.body.all
    end
    
    # Locator Methods
    #
    # Not for external use, but cannot set to private due to usages in Element
    # classes.
    # @private
    def locator_for(locator_class, specifiers, klass)
      locator_class.new self, specifiers, klass
    end
    
  end
end

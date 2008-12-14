require 'active_support'    
module Watir
  
  # this class contains items that are common between the span, div, and pre objects
  # it would not normally be used directly
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class NonControlElement < Element
    def self.inherited subclass
      class_name = subclass.to_s.demodulize
      method_name = class_name.underscore
      Watir::Container.module_eval "def #{method_name}(how, what=nil)
      return #{class_name}.new(self, how, what); end"
    end
    include Watir::Exception
        
    def locate
      if @how == :xpath
        @o = @container.element_by_xpath(@what)
      else
        @o = @container.locate_tagged_element(self.class::TAG, @how, @what)
      end
    end
    
    def initialize(container, how, what)
      set_container container
      @how = how
      @what = what
      super nil
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
      r += span_div_string_creator
      return r.join("\n")
    end
  end

  
  class Pre < NonControlElement
    TAG = 'PRE'
  end
  
  class P < NonControlElement
    TAG = 'P'
  end
  
  # this class is used to deal with Div tags in the html page. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
  # It would not normally be created by users
  class Div < NonControlElement
    TAG = 'DIV'
  end
  
  # this class is used to deal with Span tags in the html page. It would not normally be created by users
  class Span < NonControlElement
    TAG = 'SPAN'
  end
  
  class Map < NonControlElement
    TAG = 'MAP'
  end

  class Area < NonControlElement
    TAG = 'AREA'
  end

  # Accesses Label element on the html page - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
  class Label < NonControlElement
    TAG = 'LABEL'
    
    # this method is used to populate the properties in the to_s method
    def label_string_creator
      n = []
      n <<   "for:".ljust(TO_S_SIZE) + self.for
      n <<   "text:".ljust(TO_S_SIZE) + self.text
      return n
    end
    private :label_string_creator
    
    # returns the properties of the object in a string
    # raises an ObjectNotFound exception if the object cannot be found
    def to_s
      assert_exists
      r = string_creator
      r += label_string_creator
      return r.join("\n")
    end
  end
  
  class Li < NonControlElement
    TAG = 'LI'
  end  
  class Ul < NonControlElement
    TAG = 'UL'
  end
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
  class Dl < NonControlElement
    TAG = 'DL'
  end
  class Dt < NonControlElement
    TAG = 'DT'
  end
  class Dd < NonControlElement
    TAG = 'DD'
  end

end
module Watir
  
  # this class contains items that are common between the span, div, and pre objects
  # it would not normally be used directly
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class NonControlElement < Element
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
  
end

module Watir
  class Ul < NonControlElement
    TAG = 'UL'
  end
  module Container
    def ul(how, what=nil)
      return Ul.new(self, how, what)
    end
  end
  
  class H1 < NonControlElement
    TAG = 'H1'
  end
  module Container
    def h1(how, what=nil)
      return H1.new(self, how, what)
    end
  end
  
  class H2 < NonControlElement
    TAG = 'H2'
  end
  module Container
    def h2(how, what=nil)
      return H2.new(self, how, what)
    end
  end

  class H3 < NonControlElement
    TAG = 'H3'
  end
  module Container
    def h3(how, what=nil)
      return H3.new(self, how, what)
    end
  end

  class H4 < NonControlElement
    TAG = 'H4'
  end
  module Container
    def h4(how, what=nil)
      return H4.new(self, how, what)
    end
  end

  class H5 < NonControlElement
    TAG = 'H5'
  end
  module Container
    def h5(how, what=nil)
      return H5.new(self, how, what)
    end
  end
  class H6 < NonControlElement
    TAG = 'H6'
  end

  module Container
    def h6(how, what=nil)
      return H6.new(self, how, what)
    end
  end

end
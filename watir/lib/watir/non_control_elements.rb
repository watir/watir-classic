module Watir

  # this class contains items that are common between the span, div, and pre objects
  # it would not normally be used directly
  #
  # many of the methods available to this object are inherited from the Element class
  #
  class NonControlElement < Element
    include Watir::Exception

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


  class Pre < NonControlElement; end

  class P < NonControlElement; end

  # this class is used to deal with Div tags in the html page. http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/div.asp?frame=true
  # It would not normally be created by users
  class Div < NonControlElement; end

  # this class is used to deal with Span tags in the html page. It would not normally be created by users
  class Span < NonControlElement; end

  class Map < NonControlElement; end

  class Area < NonControlElement; end

  # Accesses Label element on the html page - http://msdn.microsoft.com/workshop/author/dhtml/reference/objects/label.asp?frame=true
  class Label < NonControlElement

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

  class Li < NonControlElement; end
  class Ul < NonControlElement; end
  class H1 < NonControlElement; end
  class H2 < NonControlElement; end
  class H3 < NonControlElement; end
  class H4 < NonControlElement; end
  class H5 < NonControlElement; end
  class H6 < NonControlElement; end
  class Dl < NonControlElement; end
  class Dt < NonControlElement; end
  class Dd < NonControlElement; end
  class Strong < NonControlElement; end
  class Em < NonControlElement; end

end

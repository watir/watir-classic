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

  class Ins < NonControlElement
    Watir::Container.module_eval do
      remove_method :inss

      def inses(how={}, what=nil)
        Inses.new(self, how, what)
      end
    end
  end

  class FieldSet < NonControlElement
    Watir::Container.module_eval do
      alias_method :fieldset, :field_set
      alias_method :fieldsets, :field_sets
    end
  end

  %w[Pre P Div Span Map Area Li Ul H1 H2 H3 H4 H5 H6
     Dl Dt Dd Strong Em Del Ol Body Meta Font Frameset].each do |elem|
    module_eval %Q{
      class #{elem} < NonControlElement; end
    }
  end
  
end

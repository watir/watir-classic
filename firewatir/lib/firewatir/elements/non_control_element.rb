module FireWatir

  # Base class containing items that are common between the span, div, label, p and pre classes.
  class NonControlElement < Element
    def self.inherited subclass
      class_name = Watir::Util.demodulize(subclass.to_s)
      method_name = Watir::Util.underscore(class_name)
      FireWatir::Container.module_eval "def #{method_name}(how, what=nil)
      locate if respond_to?(:locate)
      return #{class_name}.new(self, how, what); end"
    end

    attr_accessor :element_name

    #
    # Description:
    #   Locate the element on the page. Element can be a span, div, label, p or pre HTML tag.
    #
    def locate
      case @how
      when :jssh_name
        @element_name = @what
      when :xpath
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

  end # NonControlElement
end # FireWatir

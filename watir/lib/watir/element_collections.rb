module Watir
  # this class is the super class for the iterator classes (buttons, links, spans etc
  # it would normally only be accessed by the iterator methods (spans, links etc) of IE
  class ElementCollections
    include Enumerable
    
    # Super class for all the iteractor classes
    #   * container - an instance of an IE object
    def initialize(container, how, what)
      if how == :index || (how.is_a?(Hash) && how[:index])
        raise MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute :index in #{@how.inspect}"
      end

      @container = container
      @how = how
      @what = what
      @length = length
      @page_container = container.page_container
    end
    
    def element_class
      Watir.const_get self.class.name.split("::").last.chop
    end

    def element_tag
      element_class.constants.include?("TAG") ? element_class::TAG : element_class.name.split("::").last
    end
    
    def length
      count = 0
      each {|element| count += 1 }
      count
    end
    alias :size :length

    public
    def get_length_of_input_objects(object_type)
      object_types =
      if object_type.kind_of? Array
        object_type
      else
        [object_type]
      end
      
      length = 0
      objects = @container.document.getElementsByTagName("INPUT")
      if objects.length > 0
        objects.each do |o|
          length += 1 if object_types.include?(o.invoke("type").downcase)
        end
      end
      return length
    end
    
    # iterate through each of the elements in the collection in turn
    def each
      @container.locate_tagged_element(element_tag, @how, @what, element_class).each {|element| yield element}
    end
    
    # allows access to a specific item in the collection
    def [](n)
      return iterator_object(n)
    end

    def first
      iterator_object(0)
    end

    def last
      iterator_object(length - 1)
    end

    def to_s
      map { |e| e.to_s }.join("\n")
    end

    def inspect
      '#<%s:0x%x length=%s container=%s>' % [self.class, hash*2, @length.inspect, @container.inspect]
    end

    # this method creates an object of the correct type that the iterators use
    private

    def iterator_object(i)
      count = 0
      each {|e| return e if count == i; count += 1}
    end
  end
end

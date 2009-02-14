module Watir
  # this class is the super class for the iterator classes (buttons, links, spans etc
  # it would normally only be accessed by the iterator methods (spans, links etc) of IE
  class ElementCollections
    include Enumerable
    
    # Super class for all the iteractor classes
    #   * container - an instance of an IE object
    def initialize(container)
      @container = container
      @page_container = container.page_container
      @length = length # defined by subclasses
      
      # set up the items we want to display when the show method is used
      set_show_items
    end
    
    private
    def set_show_items
      @show_attributes = AttributeLengthPairs.new("id", 20)
      @show_attributes.add("name", 20)
    end
    
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
      0.upto(@length-1) { |i| yield iterator_object(i) }
    end
    
    # allows access to a specific item in the collection
    def [](n)
      return iterator_object(n-1)
    end
    
    # this method is the way to show the objects, normally used from irb
    def show
      s = "index".ljust(6)
      @show_attributes.each do |attribute_length_pair|
        s += attribute_length_pair.attribute.ljust(attribute_length_pair.length)
      end
      
      index = 1
      self.each do |o|
        s += "\n"
        s += index.to_s.ljust(6)
        @show_attributes.each do |attribute_length_pair|
          begin
            s += eval('o.ole_object.invoke("#{attribute_length_pair.attribute}")').to_s.ljust(attribute_length_pair.length)
          rescue => e
            s += " ".ljust(attribute_length_pair.length)
          end
        end
        index += 1
      end
      puts s
    end
    
    # this method creates an object of the correct type that the iterators use
    private
    def iterator_object(i)
      element_class.new(@container, :index, i + 1)
    end
  end
end
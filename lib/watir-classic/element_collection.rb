module Watir
  # this class is the super class for the iterator classes (buttons, links, spans etc
  # it would normally only be accessed by the iterator methods (spans, links etc) of IE
  class ElementCollection
    include Enumerable

    # Super class for all the iterator classes
    #   * container - an instance of an IE object
    def initialize(container, specifiers)
      if specifiers[:index]
        raise Exception::MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute :index in #{specifiers.inspect}"
      end

      @container = container
      @specifiers = specifiers
      @page_container = container.page_container
    end

    def length
      count = 0
      each {|element| count += 1 }
      count
    end

    alias_method :size, :length

    # iterate through each of the elements in the collection in turn
    def each
      @container.locator_for(TaggedElementLocator, @specifiers, element_class).each {|element| yield element}
    end

    # allows access to a specific item in the collection
    def [](n)
      number = n - Watir::IE.base_index
      offset = Watir::IE.zero_based_indexing ? (length - 1) : length
      non_existing_element = element_class.new(@container, @specifiers.merge(:index => n))
      def non_existing_element.locate; nil end
      iterator_object(number) || non_existing_element
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
      '#<%s:0x%x length=%s container=%s>' % [self.class, hash*2, length.inspect, @container.inspect]
    end

    private

    def iterator_object(i)
      count = 0
      each do |e|
        return e if (i >= 0 && count == i) || (i < 0 && count == length + i)
        count += 1
      end
    end

    def element_class
      Watir.const_get self.class.name.split("::").last.scan(/(.*)Collection/).flatten.first
    end

  end

  class TableElementCollection < ElementCollection
    def initialize(container, specifiers, ole_collection=nil)
      super container, specifiers
      @ole_collection = ole_collection
    end

    def each
      if @ole_collection
        elements = []
        @ole_collection.each {|element| elements << element_class.new(@container, :ole_object => element)}
        super do |element|
          yield element if elements.include?(element)
        end
      else
        super
      end
    end
  end

  class TableRowCollection < TableElementCollection; end

  class TableCellCollection < TableElementCollection; end

  class InputElementCollection < ElementCollection
    def each
      @container.locator_for(InputElementLocator, @specifiers, element_class).each {|element| yield element}
    end    
  end

  class HTMLElementCollection < ElementCollection
    def each
      @container.locator_for(TaggedElementLocator, @specifiers, Element).each { |element| yield element }
    end
  end

end

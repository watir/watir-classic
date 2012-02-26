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
      @length = length
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
      iterator_object(number) || element_class.new(@container, :index => n)
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

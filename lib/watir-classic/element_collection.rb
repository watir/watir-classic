module Watir
  # This class is the super class for the iterator classes (buttons, links, spans etc).
  # It would normally only be accessed by the iterator methods (spans, links etc) of {Container}.
  class ElementCollection
    include Enumerable

    # Super class for all the iterator classes
    # @param [Element] container container element instance.
    # @param [Hash] specifiers locators for elements.
    def initialize(container, specifiers)
      if specifiers[:index]
        raise Exception::MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute :index in #{specifiers.inspect}"
      end

      @container = container
      @specifiers = specifiers
      @page_container = container.page_container
    end

    # @return [Fixnum] count of elements in this collection.
    def length
      count = 0
      each {|element| count += 1 }
      count
    end

    alias_method :size, :length

    # Iterate through each of the elements in the collection in turn.
    # @yieldparam [Element] element element instance.
    def each
      @container.locator_for(TaggedElementLocator, @specifiers, element_class).each {|element| yield element}
    end

    # Access a specific item in the collection.
    #
    # @note {Element} will be always returned even if the index is out of
    #   bounds. Use {Element#exists?} to verify if the element actually exists.
    # @param [Fixnum] n n-th element to retrieve.
    # @return [Element] element with specified index from this collection.
    def [](n)
      non_existing_element = element_class.new(@container, @specifiers.merge(:index => n))
      def non_existing_element.locate; nil end
      iterator_object(n) || non_existing_element
    end

    # @return [Element] first element from this collection.
    def first
      iterator_object(0)
    end

    # @return [Element] last element from this collection.
    def last
      iterator_object(length - 1)
    end

    # @return [String] String representation of each element in this collection
    #   separated by line-feed.
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

  # This class represents table elements collection.
  class TableElementCollection < ElementCollection
    def initialize(container, specifiers, ole_collection=nil)
      super container, specifiers
      @ole_collection = ole_collection
    end

    # @see ElementCollection#each
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

  # This class represents table row elements collection.
  class TableRowCollection < TableElementCollection; end

  # This class represents table cell elements collection.
  class TableCellCollection < TableElementCollection; end

  # This class represents input elements collection.  
  class InputElementCollection < ElementCollection
    # @see ElementCollection#each
    def each
      @container.locator_for(InputElementLocator, @specifiers, element_class).each {|element| yield element}
    end    
  end

  # This class represents general elements collection.
  class HTMLElementCollection < ElementCollection
    # @see ElementCollection#each
    def each
      @container.locator_for(TaggedElementLocator, @specifiers, Element).each { |element| yield element }
    end
  end

end

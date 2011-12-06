module Watir
  # this class is the super class for the iterator classes (buttons, links, spans etc
  # it would normally only be accessed by the iterator methods (spans, links etc) of IE
  class ElementCollections
    include Enumerable

    # Super class for all the iteractor classes
    #   * container - an instance of an IE object
    def initialize(container, how, what)
      if how == :index || (how.is_a?(Hash) && how[:index])
        _how = what ? "#{how.inspect}, #{what.inspect}" : "#{how.inspect}"
        raise Exception::MissingWayOfFindingObjectException,
                    "#{self.class} does not support attribute :index in #{_how}"
      end

      @container = container
      @how = how
      @what = what
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
      @container.tagged_element_locator(element_tag, @how, @what, element_class).each {|element| yield element}
    end

    # allows access to a specific item in the collection
    def [](n)
      number = n - Watir::IE.base_index
      offset = Watir::IE.zero_based_indexing ? (length - 1) : length

      unless number.abs.between?(0, offset)
        raise Exception::MissingWayOfFindingObjectException,
          "Can't find #{element_tag.downcase} with :index #{n} from #{self.class} with size of #{length}"
      end
      return iterator_object(number)
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
      Watir.const_get self.class.name.split("::").last.chop
    end

    def element_tag
      element_class.const_defined?(:TAG) ? element_class::TAG : element_class.name.split("::").last
    end
  end
end

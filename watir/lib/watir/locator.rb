module Watir
  class Locator
    include Watir
    include Watir::Exception

    def normalize_specifiers!(specifiers)
      specifiers.each do |how, what|
        case how
        when :index
          what = what.to_i
        when :url
          how = :href
        when :class
          how = :class_name
        when :caption
          how = :value
        when :method
          how = :form_method
        end

        @specifiers[how] = what
      end
    end

    def match_with_specifiers?(element)
      @specifiers.each do |how, what|
        next if how == :index
        return false unless match? element, how, what
      end
      return true
    end
  end

  class TaggedElementLocator < Locator
    def initialize(container, tag)
      @container = container
      @tag = tag
    end

    def set_specifier(how, what)
      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end

      @specifiers = {:index => 1} # default if not specified
      normalize_specifiers! specifiers
    end

    def each_element tag
      @container.document.getElementsByTagName(tag).each do |ole_element|
        yield Element.new(ole_element)
      end
    end

    def locate
      count = 0
      each_element(@tag) do |element|
        next unless match_with_specifiers?(element)
        count += 1
        return element.ole_object if count == @specifiers[:index]
      end # elements
      nil
    end

    def match?(element, how, what)
      begin
        method = element.method(how)
      rescue NameError
        raise MissingWayOfFindingObjectException,
          "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
      case method.arity
      when 0
        what.matches method.call
      when 1
       	method.call(what)
      else
        raise MissingWayOfFindingObjectException,
          "#{how} is an unknown way of finding a <#{@tag}> element (#{what})"
      end
    end

  end

  class FrameLocator < TaggedElementLocator
    attr_accessor :tag

    def initialize(container)
      @container = container
    end

    def each_element tag
      frames = @container.document.frames
      i = 0
      @container.document.getElementsByTagName(tag).each do |frame|
        element = Element.new(frame)
        document = frames.item(i)
        yield element, document
        i += 1
      end
    end

    def locate
      count = 0
      each_element(@tag) do |element, document|
        next unless match_with_specifiers?(element)
        count += 1
        return element.ole_object, document if count == @specifiers[:index]
      end # elements
      nil
    end
  end

  class FormLocator < TaggedElementLocator
    def each_element(tag)
      @container.document.forms.each do |form|
        yield FormElement.new(form)
      end
    end
  end

  class InputElementLocator < Locator

    attr_accessor :document, :element, :elements, :klass

    def initialize container, types
      @container = container
      @types = types
      @elements = nil
      @klass = Element
    end
    
    def specifier= arg
      how, what, value = arg

      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end

      @specifiers = {:index => 1} # default if not specified
      if value
        @specifiers[:value] = value.is_a?(Regexp) ? value : value.to_s
      end

      normalize_specifiers! specifiers
    end

    def locate
      count = 0
      @elements.each do |object|
        if @klass == Element
          element = Element.new(object)
        else
          element = @klass.new(@container, @specifiers, nil)
          element.ole_object = object
          def element.locate; @o; end
        end

        next unless @types.include?(element.type) && match_with_specifiers?(element)
        
        count += 1
        return object if count == @specifiers[:index]
      end
      nil
    end
    # return true if the element matches the provided how and what
    def match? element, how, what
      begin
        attribute = element.send(how)
      rescue NoMethodError
        raise MissingWayOfFindingObjectException,
          "#{how} is an unknown way of finding an <INPUT> element (#{what})"
      end

      what.matches(attribute)
    end

    def fast_locate
      # Searching through all elements returned by ole_inner_elements
      # is *significantly* slower than IE's getElementById() and
      # getElementsByName() calls when how is :id or :name.  However
      # IE doesn't match Regexps, so first we make sure what is a String.
      # In addition, IE's getElementById() will also return an element
      # where the :name matches, so we will only return the results of
      # getElementById() if the matching element actually HAS a matching
      # :id.

      the_id = @specifiers[:id]
      if the_id && the_id.class == String &&
          @specifiers[:index] == 1 && @specifiers.length == 2
        @element = @document.getElementById(the_id) rescue nil
        # Return if our fast match really HAS a matching :id
        return true if @element && @element.invoke('id') == the_id
      end

      the_name = @specifiers[:name]
      if the_name && the_name.class == String
        @elements = @document.getElementsByName(the_name) rescue nil
      end
      false
    end
  end

  # This is like the TaggedElementLocator but
  # get all the elements by forcing @tag to be '*'
  class ElementLocator < TaggedElementLocator
    def initialize(container)
      @container = container
    end
    
    def each
      count = 0
      each_element('*') do |element| 
        next unless match_with_specifiers?(element)
        yield element          
      end 
      nil
    end
    
  end  
end    

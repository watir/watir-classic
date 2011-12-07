module Watir
  class Locator
    include Watir
    include Watir::Exception

    def document
      @document ||= @container.document
    end

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
        when :value
          what = what.is_a?(Regexp) ? what : what.to_s
        end

        @specifiers[how] = what
      end
    end

    def match_with_specifiers?(element)
      return true if has_excluding_specifiers?
      @specifiers.all? {|how, what| how == :index || match?(element, how, what)}
    end

    def has_excluding_specifiers?
      @specifiers.keys.any? {|specifier| [:css, :xpath, :ole_object].include? specifier}
    end

    def set_specifier(how, what=nil)
      specifiers = what ? {how => what} : how
      @specifiers = {:index => Watir::IE.base_index} # default if not specified
      normalize_specifiers! specifiers
    end
    
    def locate_by_id
      # Searching through all elements returned by __ole_inner_elements
      # is *significantly* slower than IE's getElementById() and
      # getElementsByName() calls when how is :id.  However
      # IE doesn't match Regexps, so first we make sure what is a String.
      # In addition, IE's getElementById() will also return an element
      # where the :name matches, so we will only return the results of
      # getElementById() if the matching element actually HAS a matching
      # :id.

      the_id = @specifiers[:id]
      if the_id && the_id.class == String 
        element = document.getElementById(the_id) rescue nil
        # Return if our fast match really HAS a matching :id
        return element if element && element.invoke('id') == the_id 
      end

      nil
    end

    def locate_by_xpath_css_ole
      el = nil
      if @specifiers[:xpath]
        el = @container.send(:element_by_xpath, @specifiers[:xpath])
      elsif @specifiers[:css]
        el = @container.send(:element_by_css, @specifiers[:css])
      elsif @specifiers[:ole_object]
        el = @specifiers[:ole_object]
      end      

      return el if el && type_matches?(el)
    end
    
    def type_matches?(el)
      @tag == "*" || (@tag && el.type == @tag.downcase) || (@types && @types.include?(el.type))
    end

    def create_element ole_object
      if @klass == Element
        element = Element.new(ole_object)
      else
        element = @klass.new(@container, @specifiers, nil)
        element.ole_object = ole_object
        def element.locate; @o; end
      end
      element
    end
  end

  class TaggedElementLocator < Locator
    def initialize(container, tag, klass)
      @container = container
      @tag = tag
      @klass = klass || Element
    end

    def each_element tag
      document.getElementsByTagName(tag).each do |ole_object|
        yield create_element ole_object
      end
    end

    def each
      each_element(@tag) do |element| 
        next unless match_with_specifiers?(element)
        yield element          
      end 
      nil
    end    

    def locate
      el = locate_by_id
      return el if el
      return locate_by_xpath_css_ole if has_excluding_specifiers?

      count = Watir::IE.base_index - 1
      each do |element|
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
          "#{how} is an unknown way of finding a <#{@tag || @tags.join(", ")}> element (#{what})"
      end
      case method.arity
      when 0
        what.matches method.call
      when 1
        method.call(what)
      else
        raise MissingWayOfFindingObjectException,
          "#{how} is an unknown way of finding a <#{@tag || @tags.join(", ")}> element (#{what})"
      end
    end

  end

  class FrameLocator < TaggedElementLocator
    def initialize(container)
      super(container, Frame::TAG, Frame)
    end

    def each_element tag
      frames = document.frames
      i = 0
      document.getElementsByTagName(tag).each do |ole_object|
        frame = create_element ole_object
        frame.document = frames.item(i)
        yield frame
        i += 1
      end
    end

    def each
      @tag.each do |t|
        each_element(t) do |element| 
          next unless match_with_specifiers?(element)
          yield element          
        end 
      end
      nil
    end        

    def locate
      # do not locate frames by getElementById since can't get the correct
      # 'document' related with that ole_object like it's done in #each_element
      return locate_by_xpath_css_ole if has_excluding_specifiers?

      count = Watir::IE.base_index - 1
      each do |frame|
        count += 1
        return frame.ole_object, frame.document if count == @specifiers[:index]
      end
    end
  end

  class FormLocator < TaggedElementLocator
    def initialize(container)
      super(container, 'FORM', Form)
    end

    def each_element(tag)
      document.forms.each do |form|
        yield create_element form
      end
    end
  end

  class InputElementLocator < Locator
    def initialize container, types, klass
      @container = container
      @types = types
      @klass = klass || Element
    end

    def each_element
      elements = locate_by_name || @container.__ole_inner_elements
      elements.each do |object|
        yield create_element object
      end
      nil
    end    

    def locate
      el = locate_by_id
      return el if el
      return locate_by_xpath_css_ole if has_excluding_specifiers?

      count = Watir::IE.base_index - 1
      each do |element|
        count += 1
        return element.ole_object if count == @specifiers[:index]
      end
    end

    def each
      each_element do |element| 
        next unless @types.include?(element.type) && match_with_specifiers?(element)
        yield element
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

    private

    def locate_by_name
      the_name = @specifiers[:name]
      if the_name && the_name.class == String
        return document.getElementsByName(the_name) rescue nil
      end      
      nil
    end
  end

  # This is like the TaggedElementLocator but
  # get all the elements by forcing @tag to be '*'
  class ElementLocator < TaggedElementLocator
    def initialize(container)
      super(container, "*", Element)
    end
  end  
end    

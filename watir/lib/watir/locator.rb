module Watir
  class TaggedElementLocator
    include Watir
    include Watir::Exception

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

      specifiers.each do |how, what|  
        what = what.to_i if how == :index
        how = :href if how == :url
        how = :class_name if how == :class
        
        @specifiers[how] = what
      end

    end

    def each_element tag
      @container.document.getElementsByTagName(tag).each do |ole_element| 
        yield Element.new(ole_element) 
      end
    end    

    def locate
      index_target = @specifiers[:index]

      count = 0
      each_element(@tag) do |element|
        
        catch :next_element do
          @specifiers.each do |how, what|
            next if how == :index
            unless match? element, how, what
              throw :next_element
            end
          end
          count += 1
          unless index_target == count
            throw :next_element
          end
          return element.ole_object          
        end

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
  class InputElementLocator
    attr_accessor :document, :element, :elements
    def initialize container, types
      @container = container
      @types = types
      @elements = nil
    end
    def specifier= arg
      how, what, value = arg
      how = :value if how == :caption
      how = :class_name if how == :class
      what = what.to_i if how == :index
      value = value.to_s if value 
      @how = how
      @what = what
      @value = value
    end
    def locate
      object_index = 1
      @elements.each do |object|
        element = Element.new(object)
        if @types.include?(element.type)
          if @how == :index
            attribute = object_index
          else
            begin
              attribute = element.send(@how)
            rescue NoMethodError
              raise MissingWayOfFindingObjectException,
                "#{@how} is an unknown way of finding an <INPUT> element (#{@what})"
            end
          end
          if @what.matches(attribute)
            if @value
              if element.value == @value
                return object
              end
            else
              return object
            end
          end
          object_index += 1
        end
      end
      return nil
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
      return unless @what.class == String # Only use fast calls with String what.
      begin
        case @how
          when :id
            @element = @document.getElementById(@what)
            # Return if our fast match really HAS a matching :id
            return true if @element && @element.invoke('id') == what
          when :name
            @elements = @document.getElementsByName(@what)
        end
        false
      rescue
        false
      end      
    end
  end
end    

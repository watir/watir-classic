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
          unless count == @specifiers[:index]
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

      if how.class == Hash and what.nil?
        specifiers = how
      else
        specifiers = {how => what}
      end

      @specifiers = {:index => 1} # default if not specified
      @specifiers[:value] = value.to_s if value
      specifiers.each do | how, what |
        how = :value if how == :caption
        how = :class_name if how == :class
        what = what.to_i if how == :index
        @specifiers[how] = what
      end
    end

    def locate
      count = 0
      @elements.each do |object|
        element = Element.new(object)

        catch :next_element do
          throw :next_element unless @types.include?(element.type)
          @specifiers.each do |how, what|
            next if how == :index
            unless match? element, how, what
              throw :next_element
            end
          end
          count += 1
          throw :next_element unless count == @specifiers[:index]
          return object
        end

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
end    

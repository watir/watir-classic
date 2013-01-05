module Watir
  class Util
    class << self

      # @example
      #   Watir::Util.demodulize("Watir::Span") # => "Span"
      def demodulize(str)
        str.gsub(/^.*::/, '')
      end

      # @example
      #   Watir::Util.underscore("FooBar") # => "foo_bar"
      def underscore(str)
        str.gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
      end

      # @example
      #   Watir::Util.singularize("Checkboxes") # => "Checkbox"
      #   Watir::Util.singularize("Bodies") # => "Body"
      #   Watir::Util.singularize("Buttons") # => "Button"
      def singularize(str)
        case str.downcase
        when "checkboxes"
          str.chop.chop
        when "bodies"
          str.chop.chop.chop + "y"
        else
          str.chop
        end
      end
    end    
  end
end

module Watir
  class Util
    class << self
      #
      # "Watir::Span" => "Span"
      # 
      def demodulize(str)
        str.gsub(/^.*::/, '')
      end

      #
      # "FooBar" => "foo_bar"
      # 
      def underscore(str)
        str.gsub(/\B[A-Z][^A-Z]/, '_\&').downcase.gsub(' ', '_')
      end

      #
      # "Checkboxes" => "Checkbox"
      # "Bodies" => "Body"
      # "Buttons" => "Button"
      #
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

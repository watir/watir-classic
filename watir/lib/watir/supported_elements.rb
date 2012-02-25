module Watir
  module Container

    class << self
      def support_element method_name, args={}
        klass = args[:class] || method_name.capitalize

        unless Watir.const_defined? klass
          Watir.class_eval %Q[
            class #{klass} < Element
              def initialize(container, how)
                set_container container
                @how = how
                super nil
              end
            end
          ]
        end

        unless Watir.const_defined? "#{klass}Collection"
          Watir.class_eval %Q[class #{klass}Collection < ElementCollection; end]
        end

        tag_name = args[:tag_name] || method_name

        Watir::Container.module_eval %Q[
          def #{method_name}(how={}, what=nil)
            #{klass}.new(self, format_specifiers("#{tag_name}", how, what))
          end

          def #{args.delete(:plural) || method_name.to_s + "s"}(how={}, what=nil)
            specifiers = format_specifiers("#{tag_name}", how, what)
            specifiers.delete(:index)
            #{klass}Collection.new(self, specifiers)
          end
        ]
      end

      private :support_element
    end

    def format_specifiers(tag_name, how, what)
      defaults = {:tag_name => [tag_name].flatten, :index => Watir::IE.base_index}
      defaults.merge(what ? {how => what} : how)
    end

    private :format_specifiers

    support_element :div
    support_element :hidden
    support_element :element, :tag_name => "*", :class => :HTMLElement
  end
end

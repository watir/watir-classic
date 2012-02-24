module Watir
  module Container

    class << self
      def support_element args
        klass = args[:class] || args[:name].capitalize

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

        Watir::Container.module_eval %Q[
          def #{args[:name]}(how={}, what=nil)
            #{klass}.new(self, format_specifiers("#{args[:tag_name] || args[:name]}", how, what))
          end

          def #{args.delete(:plural) || args[:name].to_s + "s"}(how={}, what=nil)
            specifiers = format_specifiers("#{args[:tag_name] || args[:name]}", how, what)
            specifiers.delete(:index)
            #{klass}Collection.new(self, specifiers)
          end
        ]
      end

      private :support_element
    end

    def format_specifiers(tag_name, how, what)
      defaults = {:tag_name => tag_name, :index => Watir::IE.base_index}
      defaults.merge(what ? {how => what} : how)
    end

    private :format_specifiers

    support_element :name => :div
  end
end

module Watir
  module Container

    class << self
      def support_element args
        unless Watir.const_defined? args[:class]
          Watir.class_eval %Q[
            class #{args[:class]} < Element
              def initialize(container, how)
                set_container container
                @how = how
                super nil
              end
            end
          ]
        end

        unless Watir.const_defined? "#{args[:class]}Collection"
          Watir.class_eval %Q[class #{args[:class]}Collection; end]
        end

        Watir::Container.module_eval %Q[
          def #{args[:name]}(how={}, what=nil)
            #{args[:class]}.new(self, format_specifiers("#{args[:tag_name]}", how, what))
          end

          def #{args.delete(:plural) || args[:name].to_s + "s"}(how={}, what=nil)
            #{args[:class]}Collection.new(self, format_specifiers("#{args[:tag_name]}", how, what))
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

    support_element :name => :uga,  :class => :Ugas, :tag_name => "ummmm"
    #support_element :name => :link, :plural => :links, :class => :Link, :tag_name => "a"
    #alias_method :a, :link
    #alias_method :as, :links


  end
end

require 'timeclock/util/ruby-extensions'
require 'timeclock/client/html/Formatting'

# A template class for all the sketches of the various pages. A sketch
# is something that can be turned into an xhtml page with to_xhtml.

module Timeclock
  module Client
    module Html
      
      class PageSketch
        include Formatting

        attr_reader :page_name

        def initialize(page_name)
          @page_name = page_name
        end

        def to_xhtml
          Prolog +
            html(head(title(@page_name)),
                 body(h1(p(center, @page_name)),
                      *body_guts))
        end

        def body_guts
          []
        end

      end
    end
  end
end

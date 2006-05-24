require 'watir'

module Watir
  class IE
    def self.close_all
      catch :no_more do
        while true
          begin
            attach(:title, //).close
          rescue NoMatchingWindowFoundException
            throw :no_more
          end
        end
      end
    end
  end
end
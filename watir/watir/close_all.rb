require 'watir'

module Watir
  class IE
    def self.close_all
      while browser = find(:title, //)
        browser.close; sleep 0.5
      end
    end
  end
end
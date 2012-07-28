# include this module if there's a need to have wait_until and wait_while methods in some different scope
module Watir
  module WaitHelper
    def wait_until(*args, &blk)
      Wait.until(*args, &blk)
    end

    def wait_while(*args, &blk)
      Wait.while(*args, &blk)
    end
  end
end
module Timeclock
  module Client

    # This holds a set of items that can be referred to by (1-based)
    # numbers on the command line or from HTML tables.
    #
    # For convenience in setup, the tests use the command-line and
    # live in the command-line subdirectory.
    class ReferrableItems

      def build_index(items)
        @stashed_items = items.dup
      end

      def forget_index
        @stashed_items = nil
      end
      
      def [](index)  # Indices are 1-based.
        return nil if index <= 0   # This should return nil, not last element.
        @stashed_items[index-1]
      end

      def validate(indices)
        return indices.find_all { | num | not self[num].nil? },
          indices.find_all { | num | self[num].nil? }
      end

    end
  end
end

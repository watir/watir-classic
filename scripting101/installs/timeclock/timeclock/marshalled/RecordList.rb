module Timeclock
  module Marshalled

    class RecordList < Array

      attr_accessor :next_record_id

      def initialize()
        @next_record_id = 0
      end

      def add(record)
        push record
      end


      def <<(record)
        fail "<< is misleading for a sorted array. Use add."
        # Note that push is made private for same reason.
      end

      def []=(index, record)
        fail "Setting indexed value makes no sense for sorted array."
      end

      def record_with_id(id)
        matches = find_all { | rec | rec.persistent_id == id }
        assert(matches.length < 2, "Two matches in records list?")
        matches[0]
      end

      private
      def attach_persistent_id(record)
        unless record.persistent_id
          record.persistent_id = @next_record_id
          @next_record_id += 1
        end
      end


      def push(record)
        attach_persistent_id record
        assert(record_with_id(record.id).nil?)
        super
        sort!
        self
      end
    end
  end
end

require 'timeclock/util/misc'
module Timeclock
  module Marshalled


    class Job
      
      # Rather than having a null parent link, could have a master job.
      # That master job would have all top-level jobs as subjobs. But note
      # that would drag the whole job tree across the wire. Probably not a
      # big deal.
      attr_reader :name, :parent, :subjobs, :attributes
      private_class_method :new

      def initialize(name, parent=nil)
        @name = name
        @parent = parent
        @subjobs = {}
        @attributes={}
      end

      def self.named(name)
        new(name)
      end

      def self.named_with_parent(name, parent)
        subjob = new(name, parent)
        parent.add_subjob(subjob)
        subjob
      end

      def add_subjob(subjob)
        @subjobs[subjob.name] = subjob
      end

      def inspect
        "(Job #{full_name} #{subjobs.keys.inspect} #{attributes.inspect})"
      end

      def is_subjob?
        parent != nil
      end

      def is_background?
        @attributes['background'] == true
      end

      def make_background
        @attributes['background'] = true
      end

      def unmake_background
        @attributes['background'] = false
      end

      def full_name
        if is_subjob?
          parent.name + "/" + name
        else
          name
        end
      end

      def self.parse_full_name(full_name)
        if full_name =~ %r{(.*)/(.*)}
          return $1, $2
        else
          return full_name, nil
        end
      end

      def eql?(other)
        return false unless other.kind_of? Job
        self.full_name == other.full_name 
      end

      def hash
        # this should give enough distribution of hash buckets.
        name.hash  
      end

      def ==(other)
        self.eql?(other) && 
          self.attributes == other.attributes &&
          self.subjobs == other.subjobs
      end

      def <=>(other)
        self.name <=> other.name
      end
    end
  end
end

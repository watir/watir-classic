require 'thread'

module Weak

  class RefError < RuntimeError; end

  class Key

    attr_reader :internal_id

    # Map from an object to a list of its references
    ID_MAP = {}

    # Map from a reference to its object
    ID_REV_MAP = {}

    def self.make_finalizer(internal_id, hash)
      return proc do |id|
        Thread.exclusive do
          rids = ID_MAP[id]
          if rids then
            for rid in rids
              ID_REV_MAP.delete(rid)
            end

            ID_MAP.delete(id)
          end

          rid = ID_REV_MAP[id]

          if rid then
            ID_REV_MAP.delete(id)
            ID_MAP[rid].delete(id)
            ID_MAP.delete(rid) if ID_MAP[rid].empty?
          end
        end

        hash.delete(internal_id) unless hash.nil?
      end
    end 

    def initialize(orig, hash)
      @internal_id = orig.object_id

      ObjectSpace.define_finalizer(orig, self.class.make_finalizer(@internal_id, hash))
      ObjectSpace.define_finalizer(self, self.class.make_finalizer(@internal_id, nil))

      Thread.exclusive do
        ID_MAP[@internal_id] = [] unless ID_MAP[@internal_id]
      end

      ID_MAP[@internal_id].push self.object_id
      ID_REV_MAP[self.object_id] = @internal_id
    end

    def hash
      @internal_id
    end

    def eql?(other)
      if other.respond_to? :internal_id then
        return other.internal_id == @internal_id
      else
        return other.object_id == @internal_id
      end
    end

    def inspect
      "#<#{self.class}:0x%x @internal_id=0x%x>" % [object_id, @internal_id]
    end

    def get_obj
      unless ID_REV_MAP[self.object_id] == @internal_id then
        raise RefError, "Illegal Reference - probably recycled", caller(2)
      end

      begin
        return ObjectSpace._id2ref(@internal_id)
      rescue RangeError
        raise RefError, "Illegal Reference - probably recycled", caller(2)
      end
    end

    def self.by_obj(obj)
      ref = nil

      Thread.exclusive do
        rids = ID_MAP[obj.object_id]

        if rids.nil? or rids.empty? then
          raise RefError, "Reference does not exist"
        end

        for rid in rids do
          begin
            ref = ObjectSpace._id2ref(rid)
          rescue RangeError
            next
          end

          return ref unless ref.nil?
        end

        raise RefError, "Reference does not exist"
      end
    end

  end # class Weak::Key

  class IdentityKeyHash < Hash

    def [](key)
      return super(Weak::Key.by_obj(key))
    end

    def []=(key, value)
      ref_key = nil

      unless self.has_key? key then
        ref_key = Weak::Key.new(key, self)
      else
        ref_key = Weak::Key.by_id(key.object_id)
      end

      super(ref_key, value)
    end

    def each
      key = nil

      super do |ref_key, value|
        begin
          key = ref_key.get_obj
        rescue RefError
          next
        end

        yield key, value
      end
    end

  end # class Weak::IdentityKeyHash

end # module Weak


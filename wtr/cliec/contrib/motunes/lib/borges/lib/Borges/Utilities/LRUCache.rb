##
# A least recently used cache

class Borges::LRUCache

  DEFAULT_CAPACITY = 20

  attr_accessor :capacity

  ##
  # Create a new LRUCache that can accomodate up to +capacity+ objects

  def initialize(capacity = DEFAULT_CAPACITY)
    @capacity = capacity
    @table = {}
    @age_table = {}
  end

  def size
    return @table.size
  end

  def store(object)
    key = next_key
    self[key] = object
    return key
  end

  def fetch(key)
    return self[key]
  end

  private

  def next_key
    key = nil
    while @table.key?(key = Borges::ExternalID.create) do end
    return key
  end

  def remove(object)
    @age_table.delete(object)
    @table.delete(object)
  end

  def []=(key, val)
    @table[key] = val
    @age_table[key] = 0

    removals = []
    @age_table.each do |key, age|
      removals << key if age >= @capacity
      @age_table[key] = age + 1
    end
    
    removals.each do |item|
      remove(item)
    end

    return val
  end

  def [](key)
    val = @table[key]
    @age_table[key] = 0
    return val
  end

end


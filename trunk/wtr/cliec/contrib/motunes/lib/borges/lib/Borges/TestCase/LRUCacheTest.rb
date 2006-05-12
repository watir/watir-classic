require 'test/unit'

module Borges; end
require 'Borges/Utilities/LRUCache'
require 'Borges/Utilities/ExternalID'

class LRUCacheTest < Test::Unit::TestCase

  CACHE_SIZE = 10

  def setup
    @cache = Borges::LRUCache.new(CACHE_SIZE)
  end

  def test_capacity
    (CACHE_SIZE + 1).times do |i|
      @cache.store(i)
    end

    assert_equal(CACHE_SIZE, @cache.size)
  end

  def test_store_fetch
    key = @cache.store(1)
    assert_equal(1, @cache.fetch(key))
  end

  def teardown
    @cache = nil
  end

end


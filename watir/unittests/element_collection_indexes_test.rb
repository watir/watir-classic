$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'


class TC_TestElementCollectionIndexingForOneBasedIndexes < Test::Unit::TestCase

  def setup
    close_browser
    Watir.options[:zero_based_indexing] = false
    goto_page "zeroindex.html"    
  end

  def teardown
    Watir.options[:zero_based_indexing] = true
    close_browser
  end

  def test_one_based_index    
    assert browser.table(:id, 'a_table').rows.length == 6

    #row 1
    r = browser.table(:id, 'a_table').rows[1]
    assert r.id == 'first'

    #something in the middle
    r = browser.table(:id, 'a_table').rows[2]
    assert r.id == 'second'

    #the last row
    r = browser.table(:id, 'a_table').rows[6]
    assert r.id == 'sixth'
  end
end

class TC_TestElementCollectionIndexingForZeroBasedIndexes < Test::Unit::TestCase

  def setup
    #currently the watir default is zero based index    
    goto_page "zeroindex.html"
  end

  def test_zero_based_index
    assert browser.table(:id, 'a_table').rows.length == 6

    #row 1
    r = browser.table(:id, 'a_table').rows[0]
    assert r.id == 'first'

    #something in the middle
    r = browser.table(:id, 'a_table').rows[2]
    assert r.id == 'third'

    #last row
    r = browser.table(:id, 'a_table').rows[5]
    assert r.id == 'sixth'
  end
end
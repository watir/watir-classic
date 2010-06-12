# feature tests for Watir::Table#to_a and Watir::TableRow#to_a

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Table_TableRow_to_a < Test::Unit::TestCase

  def setup
    goto_page "table_and_tablerow_to_a.html"
  end

  def test_table_to_a_works_with_regular_table
    expected_table = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"]
    ]
    assert_equal(expected_table, browser.table(:id => "normal").to_a)
  end

  def test_table_to_a_works_with_table_with_headers
    expected_table = [
            ["1", "2", "3", "4"],
            ["5", "6", "7", "8"],
            ["9", "10", "11", "12"]
    ]
    assert_equal(expected_table, browser.table(:id => "headers").to_a)
  end

  def test_table_to_a_works_with_nested_tables
    expected_table =
            [
                    ["1", "2"],
                    [[["11", "12"],
                      ["13", "14"]], "3"]
            ]
    assert_equal(expected_table, browser.table(:id => "nested").to_a(2))
  end

  def test_table_to_a_works_with_nested_table_with_non_direct_child
    expected_table =
            [
                    ["1", "2"],
                    [[["11", "12"],
                      ["13", "14"]], "3"]
            ]

    assert_equal(expected_table, browser.table(:id => "nestednondirectchild").to_a(2))
  end

  def test_table_to_a_works_with_deep_nested_tables
    expected_table =
            [
                    ["1", "2"],
                    [[["11", "12"],
                      [[["404", "405"],
                        ["406", "407"]], "14"]], "3"]
            ]
    assert_equal(expected_table, browser.table(:id => "deepnested").to_a(3))
  end

  def test_table_to_a_works_with_colspan
    expected_table =
            [
                    ["1", "2"],
                    ["3"]
            ]
    assert_equal(expected_table, browser.table(:id => "colspan").to_a)
  end

  def test_table_to_a_works_with_rowspan
    expected_table =
            [
                    ["1", "2"],
                    ["3", "4"],
                    ["5"]
            ]
    assert_equal(expected_table, browser.table(:id => "rowspan").to_a)
  end

  def test_tablerow_to_a_works_with_regular_row
    first_row = browser.table(:id => "normal")[1]
    assert_equal(["1", "2", "3"], first_row.to_a)
  end

  def test_tablerow_to_a_works_with_headers_in_row
    first_row = browser.table(:id => "headers")[1]
    assert_equal(["1", "2", "3", "4"], first_row.to_a)
  end

  def test_tablerow_to_a_works_with_nested_tables
    second_row = browser.table(:id => "nested")[2]
    assert_equal([[["11", "12"], ["13", "14"]], "3"], second_row.to_a(2))
  end

  def test_tablerow_to_a_works_with_deep_nested_tables
    second_row = browser.table(:id => "deepnested")[2]
    expected_row = [[["11", "12"],
                     [[["404", "405"], ["406", "407"]], "14"]], "3"]
    assert_equal(expected_row, second_row.to_a(3))
  end

  def test_tablerow_to_a_works_with_colspan
    second_row = browser.table(:id => "colspan")[2]
    assert_equal(["3"], second_row.to_a)
  end

  def test_tablerow_to_a_works_with_rowspan
    t = browser.table(:id => "rowspan")
    second_row = t[2]
    assert_equal(["3", "4"], second_row.to_a)

    third_row = t[3]
    assert_equal(["5"], third_row.to_a)
  end
end


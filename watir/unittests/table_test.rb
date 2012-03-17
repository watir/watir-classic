# feature tests for Tables
# Why do so many of these tests call "strip"? A distinct smell...

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Tables < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    uses_page "table1.html"
  end
  def teardown
    browser.refresh if @reload_page
  end
  
  def test_exists
    assert browser.table(:id, 't1').exists?
    assert browser.table(:id, /t/).exists?
    
    assert !browser.table(:id, 'missingTable').exists?
    assert !browser.table(:id, /missing_table/).exists?
    
    assert browser.table(:index, 0).exists?
    assert !browser.table(:index, 33).exists?
  end
  
  tag_method :test_row_count_exceptions, :fails_on_firefox
  def test_row_count_exceptions
    assert_raises UnknownObjectException do
      browser.table(:id, 'missingTable').row_count
    end
    assert_raises UnknownObjectException do
      browser.table(:index, 66).row_count
    end
    assert_raises MissingWayOfFindingObjectException do
      browser.table(:bad_attribute, 99).row_count
    end
  end
  def test_rows
    assert_equal(2, browser.table(:index, 0).row_count)
    assert_equal(2, browser.table(:index, 0).rows.length)
    
    assert_equal(5, browser.table(:id, 't1').row_count)  # 4 rows and a header 
    assert_equal(5, browser.table(:index, 1).row_count)  # same table as above, just accessed by index 
    assert_equal(5, browser.table(:id, 't1').rows.length)   
    
    # test the each iterator on rows - ie, go through each cell
    row = browser.table(:index, 1)[1]
    result = []
    row.each do |cell|
      result << cell.to_s.strip
    end
    assert_equal(['Row 1 Col1', 'Row 1 Col2'], result)
    assert_equal(2, row.column_count)        
  end

  tag_method :test_row_counts, :fails_on_firefox
  def test_row_counts
    table = browser.table(:id => 't2')
    assert_equal(2, table.row_count)
  end

  tag_method :test_dynamic_tables, :fails_on_firefox
  def test_dynamic_tables
    @reload_page = true
    t = browser.table(:id, 't1')
    assert_equal(5, t.row_count)
    browser.button(:value, 'add row').click
    assert_equal(6, t.row_count)
  end
  
  def test_columns
    assert_raises UnknownObjectException do
      browser.table(:id, 'missingTable').column_count
    end
    assert_raises UnknownObjectException do
      browser.table(:index, 77).column_count
    end
    assert_equal(2, browser.table(:index, 0).column_count)
    assert_equal(1, browser.table(:id, 't1').column_count)   # row one has 1 cell with a colspan of 2
  end
  
  def test_links_and_images_in_table
    table = browser.table(:id, 'pic_table')
    image = table[0][1].image(:index,0)
    assert_equal(106, image.width)
    
    link = table[0][3].link(:index,0)
    assert_equal("Google", link.text)
  end
  
  def test_cell_directly
    assert browser.td(:id, 'cell1').exists?
    assert ! browser.td(:id, 'no_exist').exists?
    assert_equal("Row 1 Col1", browser.td(:id, 'cell1').to_s.strip)
  end
  
  def test_cell_another_way
    assert_equal( "Row 1 Col1", browser.table(:index,0)[0][0].to_s.strip)
  end
  
  def test_row_directly
    assert browser.tr(:id, 'row1').exists?
    assert ! browser.tr(:id, 'no_exist').exists?
  end
  def test_row_another_way
    assert_equal('Row 2 Col1',  browser.tr(:id, 'row1')[0].to_s.strip)
  end

  tag_method :test_row_in_table, :fails_on_firefox
  def test_row_in_table
    assert_equal 'Row 2 Col1 Row 2 Col2', 
      browser.table(:id, 't1').row(:id, 'row1').text.gsub(/(\r|\n)/,'')
  end
  
  def test_row_collection
    t = browser.table(:index,0)
    t.rows.each_with_index do |row, i|
      assert("Row #{i + 1} Col1", row[0].text)
      assert("Row #{i + 1} Col2", row[1].text)
    end
  end 
  
  tag_method :test_cell_collection, :fails_on_firefox
  def test_cell_collection
    t = browser.table(:index,0)
    contents = t.cells.collect {|c| c.text}
    assert_equal(["Row 1 Col1","Row 1 Col2","Row 2 Col1","Row 2 Col2"], contents)
  end    
   
  tag_method :test_table_body, :fails_on_firefox
  def test_table_body
    assert_equal(1, browser.table(:index, 0).tbodys.length)
    assert_equal(3, browser.table(:id, 'body_test').tbodys.length)
    
    count = 1
    browser.table(:id, 'body_test').tbodys.each do |n|
      # do something better here!
      case count 
      when 1 
        compare_text = "This text is in the FRST TBODY."
      when 2 
        compare_text = "This text is in the SECOND TBODY."
      when 3 
        compare_text = "This text is in the THIRD TBODY."
      end
      assert_equal(compare_text, n[0][0].to_s.strip )   # this is the 1st cell of the first row of this particular body
      count += 1
    end
    assert_equal( count - 1, browser.table(:id, 'body_test').tbodys.length )
    assert_equal( "This text is in the THIRD TBODY." ,browser.table(:id, 'body_test' ).tbody(:index,2)[0][0].to_s.strip ) 
  end
  
  def test_table_container
    assert_nothing_raised { browser.table(:id, 't1').html }
  end
  
  def test_multiple_selector
    assert_equal('Second table with css class', 
      browser.table(:class => 'sample', :index => 1)[0][0].text)
  end
end    

class TC_Tables_Simple < Test::Unit::TestCase
  include Watir
  
  def setup
    goto_page "simple_table.html"
  end
  
  def test_simple_table_access
    table = browser.table(:index,0)
    assert_equal("Row 3 Col1", table[2][0].text.strip)
    assert_equal("Row 1 Col1", table[0][0].text.strip)
    assert_equal("Row 3 Col2", table[2][1].text.strip)
    assert_equal(2, table.column_count)
  end
end
class TC_Tables_Buttons < Test::Unit::TestCase
  include Watir
  
  def setup
    uses_page "simple_table_buttons.html"
  end
  
  def test_simple_table_buttons
    table = browser.table(:index, 0)
    
    table[0][0].button(:index, 0).click
    assert(browser.text_field(:name,"confirmtext").verify_contains(/CLICK1/i))
    table[1][0].button(:index, 0).click
    assert(browser.text_field(:name,"confirmtext").verify_contains(/CLICK2/i))
    
    table[0][0].button(:id, 'b1').click
    assert(browser.text_field(:name,"confirmtext").verify_contains(/CLICK1/i))
    
    assert_raises(UnknownObjectException   ) { table[0][0].button(:id,'b_missing').click }
    
    table[2][0].button(:index, 1).click
    assert(browser.text_field(:name,"confirmtext").verify_contains(/TOO/i))
    
    table[2][0].button(:value, "Click too").click
    assert(browser.text_field(:name,"confirmtext").verify_contains(/TOO/i))
    
    browser.table(:index, 0)[3][0].text_field(:index,0).set("123")
    assert(browser.text_field(:index,1).verify_contains("123"))
    
    # check when a cell contains 2 objects
    
    # if there were 2 different html objects in the same cell, some weird things happened ( button caption could change for example)
    assert_equal( 'Click ->' , browser.table(:index,0)[4][0].text_field(:index,0).value )
    browser.table(:index,0)[4][0].text_field(:index,0).click
    assert_equal( 'Click ->' , browser.table(:index,0)[4][0].text_field(:index,0).value )
    
    browser.table(:index,0)[4][0].button(:index,0).click
    assert_equal( '' , browser.table(:index,0)[4][0].text_field(:index,0).value )
  end
  
  def test_simple_table_gif
    table = browser.table(:index,1)
    assert_match(/1\.gif/, table[0][0].image(:index, 0).src)
    assert_match(/2\.gif/, table[0][1].image(:index, 0).src)
    assert_match(/3\.gif/, table[0][2].image(:index, 0).src)
    
    assert_match(/1\.gif/, table[2][0].image(:index, 0).src)
    assert_match(/2\.gif/, table[2][1].image(:index, 0).src)
    assert_match(/3\.gif/, table[2][2].image(:index, 0).src)
    
    table = browser.table(:index,2)
    assert_match(/1\.gif/, table[0][0].image(:index, 0).src)
    assert_match(/2\.gif/, table[0][0].image(:index, 1).src)
    assert_match(/3\.gif/, table[0][0].image(:index, 2).src)
    
    assert_match(/1\.gif/, table[2][0].image(:index, 0).src)
    assert_match(/2\.gif/, table[2][0].image(:index, 1).src)
    assert_match(/3\.gif/, table[2][0].image(:index, 2).src)
  end
  
end

class TC_Table_Columns < Test::Unit::TestCase
  include Watir::Exception
  def setup
    uses_page "simple_table_columns.html"
  end
  
  def test_get_columnvalues_single_column
    assert_equal(["R1C1", "R2C1", "R3C1"], browser.table(:index, 0).column_values(0))
  end
  
  def test_colspan
    assert_equal(2, browser.table(:index, 2)[1][0].colspan)
    assert_equal(1, browser.table(:index, 2)[0][0].colspan)
    assert_equal(3, browser.table(:index, 2)[3][0].colspan)
  end
  
  def test_get_columnvalues_multiple_column
    assert_equal(["R1C1", "R2C1", "R3C1"], browser.table(:index, 1).column_values(0))
    assert_equal(["R1C3", "R2C3", "R3C3"], browser.table(:index, 1).column_values(2))
  end
  
  tag_method :test_get_columnvalues_with_colspan, :fails_on_firefox
  def test_get_columnvalues_with_colspan
    assert_equal(["R1C1", "R2C1", "R3C1", "R4C1", "R5C1", "R6C2"], browser.table(:index, 2).column_values(0))
     (1..3).each{|x|assert_raises(UnknownCellException){browser.table(:index, 2).column_values(x)}}
  end
  
  def test_get_rowvalues_full_row
    assert_equal(["R1C1", "R1C2", "R1C3"], browser.table(:index, 2).row_values(0))
  end
  
  def test_get_rowvalues_with_colspan
    assert_equal(["R2C1", "R2C2"], browser.table(:index, 2).row_values(1))
  end
  
  def test_getrowvalues_with_rowspan
    assert_equal(["R5C1", "R5C2", "R5C3"], browser.table(:index, 2).row_values(4))
    assert_equal(["R6C2", "R6C3"], browser.table(:index, 2).row_values(5))
  end
end

class TC_Tables_Complex < Test::Unit::TestCase
  def setup
    uses_page "complex_table.html"
  end
  
  def test_complex_table_access
    table = browser.table(:index,0)
    assert_equal("subtable1 Row 1 Col1",table[0][0].table(:index,0)[0][0].text.strip)
    assert_equal("subtable1 Row 1 Col2",table[0][0].table(:index,0)[0][1].text.strip)
    assert_equal("subtable2 Row 1 Col2",table[1][0].table(:index,0)[0][1].text.strip)
    assert_equal("subtable2 Row 1 Col1",table[1][0].table(:index,0)[0][0].text.strip)
  end
  
end

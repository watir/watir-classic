# feature tests for Tables
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Tables_XPath < Test::Unit::TestCase
  
  
  def setup
    goto_page("table1.html")
  end
  
  def test_Table_Exists
    assert(!browser.table(:xpath , "//table[@id = 'missingTable']").exists?)
    assert(browser.table(:xpath, "//table[@id = 't1']").exists?)
  end

  tag_method :test_element_by_xpath_class, :fails_on_ie
  def test_element_by_xpath_class
    element = browser.element_by_xpath("//table[@id = 't1']")
    assert_class(element, 'Table')
    # FIXME really bizarre: this one should be a Table, but 
    # Firefox.element_factory gets HTMLAnchorElement as input
    # TODO: If element is not present, this should return null or raises exception
    #element = browser.element_by_xpath("//table[@id = 'missingTable']")
    #assert(element.instance_of?(Table),"element class should be #{Table}; got #{element.class}")
  end
  
  def test_rows
    assert_raises(UnknownObjectException ){ browser.table(:xpath, "//table[@id = 'missingTable']").row_count }
    assert_raises(UnknownObjectException){ browser.table(:xpath, "//table[@bad_attribute = 99]").row_count }
    
    assert_equal(5, browser.table(:xpath, "//table[@id = 't1']").row_count)  # 4 rows and a header 
    assert_equal(5, browser.table(:xpath, "//table[@id = 't1']").rows.length)   
    
    # test the each iterator on rows - ie, go through each cell
    row = browser.table(:xpath, "//table[@id = 't1']")[2]
    count = 1
    row.each do |cell|
      if count == 1
        assert_equal('Row 1 Col1', cell.to_s.strip)
      elsif count==2
        assert_equal('Row 1 Col2', cell.to_s.strip)
      end
      count += 1
    end
    assert_equal(2, count -1)
    assert_equal(2, browser.table(:xpath, "//table[@id = 't1']")[2].column_count)        
  end
  
  def test_dynamic_tables
    t = browser.table(:xpath, "//table[@id = 't1']")
    assert_equal(5, t.row_count)
    
    browser.button(:xpath, "//input[@value = 'add row']").click
    assert_equal(6, t.row_count)
  end
  
  def test_columns
    assert_raises(UnknownObjectException  ){ browser.table(:xpath, "//table[@id = 'missingTable']").column_count }
    assert_equal(1, browser.table(:xpath, "//table[@id = 't1']").column_count)   # row one has 1 cell with a colspan of 2
  end
  
  def test_to_a
    table1Expected = [["Table 2"], ["Row 1 Col1" , "Row 1 Col2"] ,[ "Row 2 Col1" , "Row 2 Col2"],[ "Row 3 Col1" , "Row 3 Col2"],[ "Row 4 Col1" , "Row 4 Col2"] ]
    assert_equal(table1Expected, browser.table(:xpath, "//table[@id = 't1']").to_a )
  end
  
  def test_links_and_images_in_table
    table = browser.table(:xpath, "//table[@id = 'pic_table']")
    image = table[1][2].image(:index,1)
    assert_equal("106", image.width)
    
    link = table[2][2].link(:index,1)
    assert_equal("Google", link.innerText)
  end
  
  #def test_cell_directly
  #  assert( browser.cell(:id, 'cell1').exists? )
  #  assert(! browser.cell(:id, 'no_exist').exists? )
  #  assert_equal( "Row 1 Col1",  browser.cell(:id, 'cell1').to_s.strip )
  #  
  #  # not really cell directly, but just to show another way of geting the cell
  #  assert_equal( "Row 1 Col1",  browser.table(:index,1)[1][1].to_s.strip )
  #end
  
  #def test_row_directly
  #  assert( browser.row(:id, 'row1').exists? )  
  #  assert(! browser.row(:id, 'no_exist').exists? )
  #  
  #  assert_equal('Row 2 Col1' ,  browser.row(:id, 'row1')[1].to_s.strip )
  #end
  
  def test_row_iterator
    t = browser.table(:xpath, "//table[@id = 't1']")
    count = 1 
    t.each do |row|
      if count == 1
        assert("Table 2", row[1].text)
      elsif count == 2  
        assert("Row 1 Col1", row[1].text)
        assert("Row 1 Col2", row[2].text)
      elsif count == 3
        assert("Row 2 Col1", row[1].text)
        assert("Row 2 Col2", row[2].text)
      elsif count == 4
        assert("Row 3 Col1", row[1].text) 
        assert("Row 4 Col2", row[2].text)
      elsif count == 5
        assert("Row 4 Col1", row[1].text) 
        assert("Row 4 Col2", row[2].text)
      end
      count += 1
    end
  end
  
  def test_row_collection
    t = browser.table(:xpath, "//table[@id = 't1']")
    count = 1 
    t.rows.each do |row|
      if count == 1
        assert("Table 2", row[1].text)
      elsif count == 2  
        assert("Row 1 Col1", row[1].text)
        assert("Row 1 Col2", row[2].text)
      elsif count == 3
        assert("Row 2 Col1", row[1].text)
        assert("Row 2 Col2", row[2].text)
      elsif count == 4
        assert("Row 3 Col1", row[1].text) 
        assert("Row 4 Col2", row[2].text)
      elsif count == 5
        assert("Row 4 Col1", row[1].text) 
        assert("Row 4 Col2", row[2].text)
      end
      count += 1
    end
  end
  
  #def test_table_body
  #  assert_equal( 1, browser.table(:index,1).bodies.length )
  #  assert_equal( 3, browser.table(:id, 'body_test' ).bodies.length )
  #  
  #  count = 1
  #  browser.table(:id, 'body_test').bodies.each do |n|
  #    
  #    # do something better here!
  #    # n.flash # this line commented out to speed up the test
  #    
  #    case count 
  #    when 1 
  #      compare_text = "This text is in the FRST TBODY."
  #    when 2 
  #      compare_text = "This text is in the SECOND TBODY."
  #    when 3 
  #      compare_text = "This text is in the THIRD TBODY."
  #    end
  #    
  #    assert_equal(compare_text, n[1][1].to_s.strip )   # this is the 1st cell of the first row of this particular body
  #    
  #    count += 1
  #  end
  #  assert_equal( count - 1, browser.table(:id, 'body_test').bodies.length )
  #  
  #  assert_equal( "This text is in the THIRD TBODY." ,browser.table(:id, 'body_test' ).body(:index,3)[1][1].to_s.strip ) 
  #  
  #  # iterate through all the rows in a table body
  #  count = 1
  #  browser.table(:id, 'body_test').body(:index, 2).each do | row |
  #    # row.flash    # this line commented out, to speed up the tests
  #    if count == 1
  #      assert_equal('This text is in the SECOND TBODY.', row[1].text.strip )
  #    elsif count == 1 # BUG: Huh?
  #      assert_equal('This text is also in the SECOND TBODY.', row[1].text.strip )
  #    end
  #    count+=1
  #  end
 # end
  
  def test_table_container
    assert_nothing_raised { browser.table(:id, 't1').html }
  end
end    


# feature tests for Tables
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Tables < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "table1.html")
  end
  
  def test_Table_Exists
    assert(!$ff.table(:id, 'missingTable').exists?)
    assert(!$ff.table(:index, 33).exists?)
    
    assert($ff.table(:id, 't1').exists?)
    assert($ff.table(:id, /t/).exists?)
    assert(!$ff.table(:id, /missing_table/).exists?)
    
    assert($ff.table(:index, 1).exists?)
    assert($ff.table(:index, 2).exists?)
  end
  
  def test_rows
    assert_raises(UnknownObjectException ){ $ff.table(:id, 'missingTable').row_count }
    assert_raises(UnknownObjectException ){ $ff.table(:index, 66).row_count }
    assert_raises(UnknownObjectException){ $ff.table(:bad_attribute, 99).row_count }
    
    assert_equal(2, $ff.table(:index, 1).row_count)
    assert_equal(2, $ff.table(:index, 1).rows.length)
    
    assert_equal(5, $ff.table(:id, 't1').row_count)  # 4 rows and a header 
    assert_equal(5, $ff.table(:index, 2).row_count)  # same table as above, just accessed by index 
    assert_equal(5, $ff.table(:id, 't1').rows.length)   
    
    # test the each iterator on rows - ie, go through each cell
    row = $ff.table(:index, 2)[2]
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
    assert_equal(2, $ff.table(:index, 2)[2].column_count)        
  end
  
  def test_dynamic_tables
    t = $ff.table(:id, 't1')
    assert_equal(5, t.row_count)
    
    $ff.button(:value, 'add row').click
    assert_equal(6, t.row_count)
  end
  
  def test_columns
    assert_raises(UnknownObjectException  ){ $ff.table(:id, 'missingTable').column_count }
    assert_raises(UnknownObjectException  ){ $ff.table(:index, 77).column_count }
    assert_equal(2, $ff.table(:index, 1).column_count)
    assert_equal(1, $ff.table(:id, 't1').column_count)   # row one has 1 cell with a colspan of 2
  end
  
  def test_to_a
    table1Expected = [ ["Row 1 Col1" , "Row 1 Col2"] ,[ "Row 2 Col1" , "Row 2 Col2"] ]
    assert_equal(table1Expected, $ff.table(:index , 1).to_a )
  end
  
  def test_links_and_images_in_table
    table = $ff.table(:id, 'pic_table')
    image = table[1][2].image(:index,1)
    assert_equal("106", image.width)
    
    link = table[2][2].link(:index,1)
    assert_equal("Google", link.innerText)
  end
  
  def test_cell_directly
    assert( $ff.cell(:id, 'cell1').exists? )
    assert(! $ff.cell(:id, 'no_exist').exists? )
    assert_equal( "Row 1 Col1",  $ff.cell(:id, 'cell1').to_s.strip )
    
    # not really cell directly, but just to show another way of geting the cell
    assert_equal( "Row 1 Col1",  $ff.table(:index,1)[1][1].to_s.strip )
    assert_equal(2, $ff.cell(:id, "cell_with_colspan").colspan)
  end
  
  def test_row_directly
    assert( $ff.row(:id, 'row1').exists? )  
    assert(! $ff.row(:id, 'no_exist').exists? )
    
    assert_equal('Row 2 Col1' ,  $ff.row(:id, 'row1')[1].to_s.strip )
  end
  
  def test_row_iterator
    t = $ff.table(:index, 1)
    count = 1 
    t.each do |row|
      if count == 1
        assert("Row 1 Col1", row[1].text)
        assert("Row 1 Col2", row[2].text)
      elsif count == 2
        assert("Row 2 Col1", row[1].text)
        assert("Row 2 Col2", row[2].text)
      end
      count += 1
    end
  end
  
  def test_row_collection
    t = $ff.table(:index,1)
    count = 1
    t.rows.each do |row|
      if count == 1
        assert("Row 1 Col1", row[1].text)
        assert("Row 1 Col2", row[2].text)
      elsif count == 2
        assert("Row 2 Col1", row[1].text)
        assert("Row 2 Col2", row[2].text)
      end
      count += 1
    end
  end 
  
  #def test_table_body
  #  assert_equal( 1, $ff.table(:index,1).bodies.length )
  #  assert_equal( 3, $ff.table(:id, 'body_test' ).bodies.length )
  #  
  #  count = 1
  #  $ff.table(:id, 'body_test').bodies.each do |n|
  #    
  #    # do something better here!
      # n.flash # this line commented out to speed up the test
      
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
  #  assert_equal( count - 1, $ff.table(:id, 'body_test').bodies.length )
  #  
  #  assert_equal( "This text is in the THIRD TBODY." ,$ff.table(:id, 'body_test' ).body(:index,3)[1][1].to_s.strip ) 
  #  
  #  # iterate through all the rows in a table body
  #  count = 1
  #  $ff.table(:id, 'body_test').body(:index, 2).each do | row |
  #    # row.flash    # this line commented out, to speed up the tests
  #    if count == 1
  #      assert_equal('This text is in the SECOND TBODY.', row[1].text.strip )
  #    elsif count == 1 # BUG: Huh?
  #      assert_equal('This text is also in the SECOND TBODY.', row[1].text.strip )
  #    end
  #    count+=1
  #  end
  #end
  
  def test_table_container
    assert_nothing_raised { $ff.table(:id, 't1').html }
  end
end    

class TC_Tables_Simple < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "simple_table.html")
  end
  
  def test_simple_table_access
    table = $ff.table(:index,1)
    
    assert_equal("Row 3 Col1",table[3][1].text.strip)
    assert_equal("Row 1 Col1",table[1][1].text.strip)
    assert_equal("Row 3 Col2",table[3][2].text.strip)
    assert_equal(2,table.column_count)
  end
end

class TC_Tables_Buttons < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "simple_table_buttons.html")
  end
  
  def test_simple_table_buttons
    table = $ff.table(:index,1)
    
    table[1][1].button(:index,1).click
    assert($ff.text_field(:name,"confirmtext").verify_contains(/CLICK1/i))
    table[2][1].button(:index,1).click
    assert($ff.text_field(:name,"confirmtext").verify_contains(/CLICK2/i))
    
    table[1][1].button(:id,'b1').click
    assert($ff.text_field(:name,"confirmtext").verify_contains(/CLICK1/i))
    
    assert_raises(UnknownObjectException   ) { table[1][1].button(:id,'b_missing').click }
    
    table[3][1].button(:index,2).click
    assert($ff.text_field(:name,"confirmtext").verify_contains(/TOO/i))
    
    table[3][1].button(:value ,"Click too").click
    assert($ff.text_field(:name,"confirmtext").verify_contains(/TOO/i))
    
    $ff.table(:index,1)[4][1].text_field(:index,1).set("123")
    assert($ff.text_field(:index,2).verify_contains("123"))
    
    # check when a cell contains 2 objects
    
    # if there were 2 different html objects in the same cell, some weird things happened ( button caption could change for example)
    assert_equal( 'Click ->' , $ff.table(:index,1)[5][1].text_field(:index,1).value )
    $ff.table(:index,1)[5][1].text_field(:index,1).click
    assert_equal( 'Click ->' , $ff.table(:index,1)[5][1].text_field(:index,1).value )
    
    $ff.table(:index,1)[5][1].button(:index,1).click
    assert_equal( '' , $ff.table(:index,1)[5][1].text_field(:index,1).value )
  end
  
  def test_simple_table_gif
    table = $ff.table(:index,2)
    
    assert_match( /1\.gif/   , table[1][1].image( :index,1).src  )
    assert_match( /2\.gif/   , table[1][2].image( :index ,1).src )
    assert_match( /3\.gif/   , table[1][3].image( :index ,1).src    )
    
    assert_match( /1\.gif/   , table[3][1].image( :index ,1).src  )
    assert_match( /2\.gif/   , table[3][2].image( :index ,1).src )
    assert_match( /3\.gif/   , table[3][3].image( :index ,1).src  )
    
    table = $ff.table(:index,3)
    assert_match( /1\.gif/   , table[1][1].image( :index ,1).src  )
    assert_match( /2\.gif/   , table[1][1].image( :index ,2).src )
    assert_match( /3\.gif/   , table[1][1].image( :index ,3).src )
   
    assert_match( /1\.gif/  , table[3][1].image( :index ,1).src  )
    assert_match( /2\.gif/  , table[3][1].image( :index ,2).src    )
    assert_match( /3\.gif/  , table[3][1].image( :index ,3).src  )
  end
  
  def test_table_with_hidden_or_visible_rows
    t = $ff.table(:id , 'show_hide')
    
    # expand the table
    t.each do |r|
      r[1].image(:src, /plus/).click if r[1].image(:src, /plus/).exists?
    end
    
    # shrink rows 1,2,3
    count=1
    t.each do |r|
      r[1].image(:src, /minus/).click if r[1].image(:src, /minus/).exists? and (1..3) === count 
      count=2
    end
  end
  
#  def test_table_from_element
#    button = $ff.button(:id, "b1")
#    table = Table.create_from_element($ff, button)
    
#    table[2][1].button(:index, 1).click
#    assert($ff.textField(:name, "confirmtext").verify_contains(/CLICK2/i))
#  end
end

class TC_Table_Columns < Test::Unit::TestCase
  include FireWatir
  def setup
    $ff.goto($htmlRoot + "simple_table_columns.html")
  end
  
#  def test_get_columnvalues_single_column
#    assert_equal(["R1C1", "R2C1", "R3C1"], $ff.table(:index, 1).column_values(1))
#  end

  def test_colspan
    assert_equal(2, $ff.table(:index, 3)[2][1].colspan)
    assert_equal(1, $ff.table(:index, 3)[1][1].colspan)
    assert_equal(3, $ff.table(:index, 3)[4][1].colspan)
  end

  def test_get_columnvalues_multiple_column
    assert_equal(["R1C1", "R2C1", "R3C1"], $ff.table(:index, 2).column_values(1))
    assert_equal(["R1C3", "R2C3", "R3C3"], $ff.table(:index, 2).column_values(3))
  end

  def test_get_columnvalues_with_colspan
    assert_equal(["R1C1", "R2C1", "R3C1", "R4C1", "R5C1", "R6C2"], $ff.table(:index, 3).column_values(1))
  end

  def test_get_rowvalues_full_row
    assert_equal(["R1C1", "R1C2", "R1C3"], $ff.table(:index, 3).row_values(1))
  end

  def test_get_rowvalues_with_colspan
    assert_equal(["R2C1", "R2C2"], $ff.table(:index, 3).row_values(2))
  end

  def test_getrowvalues_with_rowspan
    assert_equal(["R5C1", "R5C2", "R5C3"], $ff.table(:index, 3).row_values(5))
    assert_equal(["R6C2", "R6C3"], $ff.table(:index, 3).row_values(6))
  end
end

class TC_Tables_Complex < Test::Unit::TestCase
  include FireWatir
  def setup
    $ff.goto($htmlRoot + "complex_table.html")
  end

  def test_complex_table_access
    table = $ff.table(:index,1)
    
    assert_equal("subtable1 Row 1 Col1",table[1][1].table(:index,1)[1][1].text.strip)
    assert_equal("subtable1 Row 1 Col2",table[1][1].table(:index,1)[1][2].text.strip)
    assert_equal("subtable2 Row 1 Col2",table[2][1].table(:index,1)[1][2].text.strip)
    assert_equal("subtable2 Row 1 Col1",table[2][1].table(:index,1)[1][1].text.strip)
  end
end

class TC_Tables_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showTables
    $ff.goto($htmlRoot + "table1.html")
    $stdout = @mockout
    $ff.showTables
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 7 tables
table:   id: tblTest
       rows: 2
    columns: 2
      index: 1
table:   id: t1
       rows: 5
    columns: 1
      index: 2
table:   id: t2
       rows: 2
    columns: 2
      index: 3
table:   id: 
       rows: 1
    columns: 2
      index: 4
table:   id: body_test
       rows: 5
    columns: 1
      index: 5
table:   id: pic_table
       rows: 2
    columns: 2
      index: 6
table:   id: tblTest1
       rows: 5
    columns: 1
      index: 7
END_OF_MESSAGE
  end
end

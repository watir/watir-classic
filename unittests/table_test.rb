# feature tests for Tables
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Tables < Test::Unit::TestCase
    include Watir

    def gotoTablePage()
        $ie.goto($htmlRoot + "table1.html")
    end


    def test_Table_Exists
       gotoTablePage()
       assert_false($ie.table(:id , 'missingTable').exists? )
       assert_false($ie.table(:index, 33).exists? )

       assert($ie.table(:id, 't1').exists? )
       assert($ie.table(:index, 1).exists? )
       assert($ie.table(:index, 2).exists? )


    end

    def test_rows
       gotoTablePage()
       assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').row_count }
       assert_raises( UnknownTableException  ){ $ie.table(:index , 66).row_count }

        assert_equal( 2 , $ie.table(:index , 1).row_count)
        assert_equal( 5 , $ie.table(:id, 't1').row_count)   # 4 rows and a header 
        assert_equal( 5 , $ie.table(:index, 2).row_count)   # same table as above, just accessed by index 


    end

    def test_columns
       gotoTablePage()

       assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').column_count }
       assert_raises( UnknownTableException  ){ $ie.table(:index , 77).column_count }


        assert_equal( 2 , $ie.table(:index , 1).column_count)
        assert_equal( 1 , $ie.table(:id, 't1').column_count)   # row one has 1 cell with a colspan of 2
    end

    def test_to_a
       gotoTablePage()

        table1Expected = [ ["Row 1 Col1" , "Row 1 Col2"] ,[ "Row 2 Col1" , "Row 2 Col2"] ]
        assert_arrayEquals(table1Expected, $ie.table(:index , 1).to_a )
    end

  def test_simple_table_access
      $ie.goto($htmlRoot + "simple_table.html")
 
       table = $ie.table(:index,1)
    
       assert_equal("Row 3 Col1",table[3][1].text.strip)
       assert_equal("Row 1 Col1",table[1][1].text.strip)
       assert_equal("Row 3 Col2",table[3][2].text.strip)
       assert_equal(2,table.column_count)
   
  end
  
  def test_simple_table_buttons
   $ie.goto($htmlRoot + "simple_table_buttons.html")
 
   table = $ie.table(:index,1)
   
   table[1][1].button.click
   assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK1/i))
   table[2][1].button.click
   assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK2/i))
   
   $ie.table(:index,1)[4][1].text_field.set("123")
   assert($ie.text_field(:index,2).verify_contains("123"))


  end

  def test_table_from_element
   $ie.goto($htmlRoot + "simple_table_buttons.html")
 
   button = $ie.button(:id,"b1")
   table = Table.create_from_element($ie,button)
   
   table[2][1].button.click
   assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK2/i))
  
  end

  def test_complex_table_access
   $ie.goto($htmlRoot + "complex_table.html")
 
   table = $ie.table(:index,1)
   
   assert_equal("subtable1 Row 1 Col1",table[1][1].table[1][1].text.strip)
   assert_equal("subtable1 Row 1 Col2",table[1][1].table[1][2].text.strip)
   assert_equal("subtable2 Row 1 Col2",table[2][1].table[1][2].text.strip)

   assert_equal("subtable2 Row 1 Col1",table[2][1].table[1][1].text.strip)
   
  end

    def cell_directly

        assert( $ie.cell(:id, 'cell1').exists? )
        assert_false( $ie.cell(:id, 'no_exist').exists? )
        assert_equal( "Row 1 Col1",  $ie.cell(:id, 'cell1').to_s.strip )

        # not really cell directly, but just to show another way of geting the cell
        assert_equal( "Row 1 Col1",  $ie.table(:index,1)[1][1].to_s.strip )


    end

    def row_directly

    end

end

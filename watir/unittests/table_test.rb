# feature tests for Tables
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Tables < Test::Unit::TestCase
    include Watir

    def setup
        gotoTablePage
    end

    def gotoTablePage()
        $ie.goto($htmlRoot + "table1.html")
    end


    def test_Table_Exists
       assert_false($ie.table(:id , 'missingTable').exists? )
       assert_false($ie.table(:index, 33).exists? )

       assert($ie.table(:id, 't1').exists? )
       assert($ie.table(:index, 1).exists? )
       assert($ie.table(:index, 2).exists? )


    end

    def test_rows
       assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').row_count }
       assert_raises( UnknownTableException  ){ $ie.table(:index , 66).row_count }

        assert_equal( 2 , $ie.table(:index , 1).row_count)
        assert_equal( 5 , $ie.table(:id, 't1').row_count)   # 4 rows and a header 
        assert_equal( 5 , $ie.table(:index, 2).row_count)   # same table as above, just accessed by index 

        # test the each iterator on rows - ie, go through each cell

        row = $ie.table(:index, 2)[2]
        count=1
        row.each do |cell|
            #  cell.flash   # this line commented out to speed up the test
            if count == 1
                assert_equal('Row 1 Col1' , cell.to_s.strip )
            elsif count==2
                assert_equal('Row 1 Col2' , cell.to_s.strip )
            end
            count+=1
        end
        assert_equal(2, count -1)


    end
  
    def test_dynamic_tables
        t = $ie.table(:id, 't1')
        assert_equal( 5, t.row_count)

        $ie.button(:value , 'add row').click
        assert_equal( 6, t.row_count)


    end

    def test_columns

        assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').column_count }
        assert_raises( UnknownTableException  ){ $ie.table(:index , 77).column_count }
        assert_equal( 2 , $ie.table(:index , 1).column_count)
        assert_equal( 1 , $ie.table(:id, 't1').column_count)   # row one has 1 cell with a colspan of 2
    end

    def test_to_a

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
   
        table[1][1].button(:index,1).click
        assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK1/i))
        table[2][1].button(:index,1).click
        assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK2/i))

        table[1][1].button(:id,'b1').click
        assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK1/i))

        assert_raises(UnknownObjectException   ) { table[1][1].button(:id,'b_missing').click }

        table[3][1].button(:index,2).click
        assert($ie.textField(:name,"confirmtext").verify_contains(/TOO/i))


        table[3][1].button(:value ,"Click too").click
        assert($ie.textField(:name,"confirmtext").verify_contains(/TOO/i))



        
        $ie.table(:index,1)[4][1].text_field(:index,1).set("123")
        assert($ie.text_field(:index,2).verify_contains("123"))

        # check when a cell contains 2 objects

        # if there were 2 different html objects in the same cell, some weird things happened ( button caption could change for example)
        assert_equal( 'Click ->' , $ie.table(:index,1)[5][1].text_field(:index,1).value )
        $ie.table(:index,1)[5][1].text_field(:index,1).click
        assert_equal( 'Click ->' , $ie.table(:index,1)[5][1].text_field(:index,1).value )

        $ie.table(:index,1)[5][1].button(:index,1).click
        assert_equal( '' , $ie.table(:index,1)[5][1].text_field(:index,1).value )


    end
 
    def test_links_and_images_in_table

        table = $ie.table(:id, 'pic_table')
        image = table[1][2].image(:index,1)
        assert_equal("106", image.width)

        link = table[1][4].link(:index,1)
        assert_equal("Google", link.innerText)


    end


    def test_table_from_element
        $ie.goto($htmlRoot + "simple_table_buttons.html")
     
        button = $ie.button(:id,"b1")
        table = Table.create_from_element($ie,button)
       
        table[2][1].button(:index,1).click
        assert($ie.textField(:name,"confirmtext").verify_contains(/CLICK2/i))
    end

    def atest_complex_table_access
        $ie.goto($htmlRoot + "complex_table.html")
     
        table = $ie.table(:index,1)
       
        assert_equal("subtable1 Row 1 Col1",table[1][1].table[1][1].text.strip)
        assert_equal("subtable1 Row 1 Col2",table[1][1].table[1][2].text.strip)
        assert_equal("subtable2 Row 1 Col2",table[2][1].table[1][2].text.strip)
        assert_equal("subtable2 Row 1 Col1",table[2][1].table[1][1].text.strip)
     
    end

    def test_cell_directly

        assert( $ie.cell(:id, 'cell1').exists? )
        assert_false( $ie.cell(:id, 'no_exist').exists? )
        assert_equal( "Row 1 Col1",  $ie.cell(:id, 'cell1').to_s.strip )

        # not really cell directly, but just to show another way of geting the cell
        assert_equal( "Row 1 Col1",  $ie.table(:index,1)[1][1].to_s.strip )


    end

    def test_row_directly

        assert( $ie.row(:id, 'row1').exists? )  
        assert_false( $ie.row(:id, 'no_exist').exists? )

        assert_equal('Row 2 Col1' ,  $ie.row(:id, 'row1')[1].to_s.strip )
    end

    def test_row_iterator

        t = $ie.table(:index,1)
        count =1
        t.each do |row|
            if count==1
                assert( "Row 1 Col1" , row[1].text )
                assert( "Row 1 Col2" , row[2].text )
            elsif count==2
                assert( "Row 2 Col1" , row[1].text )
                assert( "Row 2 Col2" , row[2].text )
            end
        end

    end

    def test_table_body

        assert_equal( 1, $ie.table(:index,1).bodies.length )
        assert_equal( 3, $ie.table(:id, 'body_test' ).bodies.length )

        count = 1
        $ie.table(:id, 'body_test' ).bodies.each do |n|

            # do something better here!
            # n.flash # this line commented out to speed up the test

            case count 
                when 1 
                    compare_text = "This text is in the FRST TBODY."
                when 2 
                    compare_text = "This text is in the SECOND TBODY."
                when 3 
                    compare_text = "This text is in the THIRD TBODY."
            end

            assert_equal( compare_text , n[1][1].to_s.strip )   # this is the 1st cell of the first row of this particular body

            count +=1
        end
        assert_equal( count-1, $ie.table(:id, 'body_test' ).bodies.length  )

        assert_equal( "This text is in the THIRD TBODY." ,$ie.table(:id, 'body_test' ).body(:index,3)[1][1].to_s.strip ) 


        # iterate through all the rows in a table body
        count = 1
        $ie.table(:id, 'body_test' ).body(:index,2).each do | row |
            # row.flash    # this line commented out, to speed up the tests
            if count == 1
                assert_equal('This text is in the SECOND TBODY.' , row[1].text.strip )
            elsif count == 1
                 assert_equal('This text is also in the SECOND TBODY.' , row[1].text.strip )
            end

            count+=1
        end


    end

    def test_get_columnvalues_single_column
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R1C1", "R2C1", "R3C1"], $ie.table(:index, 1).column_values(1))
    end

    def test_get_columnvalues_multiple_column
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R1C1", "R2C1", "R3C1"], $ie.table(:index, 2).column_values(1))
        assert_equal(["R1C3", "R2C3", "R3C3"], $ie.table(:index, 2).column_values(3))
    end

    def test_get_columnvalues_with_colspan
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R1C1", "R2C1", "R3C1", "R4C1", "R5C1", "R6C2"], $ie.table(:index, 3).column_values(1))
        (2..4).each{|x|assert_raises(UnknownCellException){$ie.table(:index, 3).column_values(x)}}
    end
    
    def test_get_rowvalues_full_row
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R1C1", "R1C2", "R1C3"], $ie.table(:index, 3).row_values(1))
    end
    
    def test_get_rowvalues_with_colspan
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R2C1", "R2C2"], $ie.table(:index, 3).row_values(2))
    end
    
    def test_getrowvalues_with_rowspan
        $ie.goto($htmlRoot + "simple_table_columns.html")
        assert_equal(["R5C1", "R5C2", "R5C3"], $ie.table(:index, 3).row_values(5))
        assert_equal(["R6C2", "R6C3"], $ie.table(:index, 3).row_values(6))
    end





end

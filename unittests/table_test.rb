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
       assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').rows }
       assert_raises( UnknownTableException  ){ $ie.table(:index , 3).rows }

        assert_equal( 2 , $ie.table(:index , 1).rows)
        assert_equal( 5 , $ie.table(:id, 't1').rows)   # 4 rows and a header 
        assert_equal( 5 , $ie.table(:index, 2).rows)   # same table as above, just accessed by index 


    end

    def test_columns
       gotoTablePage()

       assert_raises( UnknownTableException  ){ $ie.table(:id , 'missingTable').columns }
       assert_raises( UnknownTableException  ){ $ie.table(:index , 3).columns }


        assert_equal( 2 , $ie.table(:index , 1).columns)
        assert_equal( 2 , $ie.table(:id, 't1').columns)   # row one has 1 cell with a colspan of 2
    end

    def test_to_a

        table1Expected = [ ["Row 1 Col1" , "Row 1 Col2"] ,[ "Row 2 Col1" , "Row 2 Col2"] ]
        assert_arrayEquals(table1Expected, $ie.table(:index , 1).to_a )
    end
end

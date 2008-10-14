# feature tests for Tables
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Tables_XPath < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "table1.html"
  end
  
  def test_Table_Exists
    assert_false($ie.table(:xpath , "//table[@id='missingTable']/").exists? )
    assert($ie.table(:xpath , "//table[@id='t1']/").exists? )
  end
  
  def test_rows
    assert_raises( UnknownObjectException  ){ $ie.table(:xpath , "//table[@id='missingTable']/").row_count }
    assert_equal( 5 , $ie.table(:xpath , "//table[@id='t1']/").row_count)   # 4 rows and a header 
  end
  
  def test_dynamic_tables
    t = $ie.table(:xpath , "//table[@id='t1']/")
    assert_equal( 5, t.row_count)
    
    $ie.button(:xpath,"//input[@value='add row']/").click
    assert_equal( 6, t.row_count)
  end
  
  def test_columns
    assert_raises( UnknownObjectException  ){ $ie.table(:xpath , "//table[@id='missingTable']/").column_count }
    assert_equal( 1 , $ie.table(:xpath , "//table[@id='t1']/").column_count)   # row one has 1 cell with a colspan of 2
  end
  
  def test_links_and_images_in_table
    table = $ie.table(:xpath , "//table[@id='pic_table']/")
    image = table[1][2].image(:index,1)
    assert_equal("106", image.width)
    
    link = table[1][4].link(:index,1)
    assert_equal("Google", link.innerText)
  end
  
  def test_table_from_element
    goto_page "simple_table_buttons.html"
    
    button = $ie.button(:xpath , "//input[@id='b1']/")
    table = Watir::Table.create_from_element($ie,button)
    
    table[2][1].button(:index,1).click
    assert($ie.text_field(:name,"confirmtext").verify_contains(/CLICK2/i))
  end
  
  def test_cell_directly
    
    assert( $ie.cell(:xpath , "//td[@id='cell1']/").exists? )
    assert_false( $ie.cell(:xpath , "//td[@id='no_exist']/").exists? )
    assert_equal( "Row 1 Col1",  $ie.cell(:xpath , "//td[@id='cell1']/").to_s.strip )
  end
  
  def test_row_directly
    assert( $ie.row(:xpath , "//tr[@id='row1']/").exists? )  
    assert_false( $ie.row(:xpath , "//tr[@id='no_exist']/").exists? )
    
    assert_equal('Row 2 Col1' ,  $ie.row(:xpath , "//tr[@id='row1']/")[1].to_s.strip )
  end
  
  
  def test_table_body
    assert_equal( 3, $ie.table(:xpath , "//table[@id='body_test']/").bodies.length )
    
    count = 1
    $ie.table(:xpath , "//table[@id='body_test']/").bodies.each do |n|
      
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
    assert_equal( count-1, $ie.table(:xpath , "//table[@id='body_test']/").bodies.length  )
    
    assert_equal( "This text is in the THIRD TBODY." ,$ie.table(:xpath , "//table[@id='body_test']/").body(:index,3)[1][1].to_s.strip ) 
    
    # iterate through all the rows in a table body
    count = 1
    $ie.table(:xpath , "//table[@id='body_test']/").body(:index,2).each do | row |
      # row.flash    # this line commented out, to speed up the tests
      if count == 1
        assert_equal('This text is in the SECOND TBODY.' , row[1].text.strip )
      elsif count == 1
        assert_equal('This text is also in the SECOND TBODY.' , row[1].text.strip )
      end
      count+=1
    end
  end
  
end

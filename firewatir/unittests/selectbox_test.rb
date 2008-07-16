# feature tests for Select Boxes
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_SelectList < Test::Unit::TestCase
    include FireWatir
    
    def setup()
        $ff.goto($htmlRoot + "selectboxes1.html")
    end
    
    def test_textBox_Exists
        assert($ff.select_list(:name, "sel1").exists?)   
        assert_false($ff.select_list(:name, "missing").exists?)   
        assert_false($ff.select_list(:id, "missing").exists?)   
    end

    def test_select_list_enabled
        assert($ff.select_list(:name, "sel1").enabled?)   
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "NoName").enabled? }  
    end

    def test_select_list_getAllContents
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "NoName").getAllContents }  
        assert_equal( ["Option 1" ,"Option 2" , "Option 3" , "Option 4"] , 
        $ff.select_list(:name, "sel1").getAllContents)   
    end

    def test_Option_text_select
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "sel1").option(:text, "missing item").select }  
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "sel1").option(:text, /missing/).select }  
        assert_raises(MissingWayOfFindingObjectException) { $ff.select_list(:name, "sel1").option(:missing, "Option 1").select }

        # the select method keeps any currently selected items - use the clear selection method first
        $ff.select_list( :name , "sel1").clearSelection
        $ff.select_list( :name , "sel1").option(:text, "Option 1").select
        assert_equal( ["Option 1" ] , $ff.select_list(:name, "sel1").getSelectedItems)   
    end    


    def test_option_class_name

        # the option object doesnt inherit from element, so this doesnt work
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "sel1").option(:text, "missing item").class_name }  
        assert_equal("option_style" , $ff.select_list(:name, "sel2").option(:value , 'o2').class_name)   
        assert_equal("" , $ff.select_list(:name, "sel2").option(:value , 'o1').class_name)   

    end

    def test_selectBox_select_using_value
        assert_raises(UnknownObjectException) { $ff.select_list(:name, "NoName").getSelectedItems }  
        assert_raises(NoValueFoundException) { $ff.select_list(:name, "sel1").select_value("missing item") }  
        assert_raises(NoValueFoundException) { $ff.select_list(:name, "sel1").select_value(/missing/) }  
        
        # the select method keeps any currently selected items - use the clear selectcion method first
        $ff.select_list( :name , "sel1").clearSelection
        $ff.select_list( :name , "sel1").select_value("o1")
        assert_equal( ["Option 1" ] , $ff.select_list(:name, "sel1").getSelectedItems)   
        
        $ff.select_list( :name , "sel1").clearSelection
        $ff.select_list( :name , "sel1").select_value(/2/)
        assert_equal( ["Option 2" ] , $ff.select_list(:name, "sel1").getSelectedItems)   
        
        $ff.select_list( :name , "sel2").clearSelection
        $ff.select_list( :name , "sel2").select_value(/4/)
        $ff.select_list( :name , "sel2").select_value(/2/)
        assert_equal( ["Option 2" , "Option 4" ] , 
        $ff.select_list(:name, "sel2").getSelectedItems)   
        
        # these are to test the onchange event
        # the event shouldnt get fired, as this is the selected item
        $ff.select_list( :name , "sel3").select_value( /3/ )
        assert_false($ff.text.include?("Pass") )
    end
    
    def test_select_list_select_using_value2
        # the event should get fired
        $ff.select_list( :name , "sel3").select_value( /2/ )
        assert($ff.text.include?("PASS") )
    end
    
    def test_select_list_properties
        assert_raises(UnknownObjectException) { $ff.select_list(:index, 199).value }  
        assert_raises(UnknownObjectException) { $ff.select_list(:index, 199).name }  
        assert_raises(UnknownObjectException) { $ff.select_list(:index, 199).id }  
        assert_raises(UnknownObjectException) { $ff.select_list(:index, 199).disabled }  
        assert_raises(UnknownObjectException) { $ff.select_list(:index, 199).type }  
        
        assert_equal("o3"   ,    $ff.select_list(:index, 1).value)  
        assert_equal("sel1" ,    $ff.select_list(:index, 1).name )  
        assert_equal(""     ,    $ff.select_list(:index, 1).id )  
        assert_equal("select-one",         $ff.select_list(:index, 1).type )  
        assert_equal("select-multiple",    $ff.select_list(:index, 2).type )  
        
        $ff.select_list(:index,1).select(/1/)
        assert_equal("o1"   ,    $ff.select_list(:index, 1).value)  
                
        assert_false( $ff.select_list(:index, 1).disabled )
        assert( $ff.select_list(:index, 4).disabled )
        assert( $ff.select_list(:id, 'selectbox_4').disabled )
    end
    
    def test_select_list_iterator
        assert_equal(5, $ff.select_lists.length)
        assert_equal("o3"   ,    $ff.select_lists[1].value)  
        assert_equal("sel1" ,    $ff.select_lists[1].name )  
        assert_equal("select-one",         $ff.select_lists[1].type )  
        assert_equal("select-multiple" ,   $ff.select_lists[2].type )  
        
        index=1
        $ff.select_lists.each do |l|
            assert_equal( $ff.select_list(:index, index).name , l.name )
            assert_equal( $ff.select_list(:index, index).id , l.id )
            assert_equal( $ff.select_list(:index, index).type , l.type )
            assert_equal( $ff.select_list(:index, index).value , l.value )
            index+=1
        end
        assert_equal( index-1, $ff.select_lists.length)
        # Bug Fix 25 
        $ff.select_lists.each { |list| puts list.getAllContents() }
    end
end

class TC_Select_Options < Test::Unit::TestCase
    include FireWatir
   
    def setup()
        $ff.goto($htmlRoot + "select_tealeaf.html")
    end
   
    def test_options_text
        $ff.select_list(:name, 'op_numhits').option(:text, '>=').select
        assert($ff.select_list(:name, 'op_numhits').option(:text, '>=').selected)
        assert_equal( [">=" ] , $ff.select_list(:name, "op_numhits").getSelectedItems)   
        assert_equal( "=" , $ff.select_list(:name, "op_numhits")[1].text)   
        assert_equal( "0" , $ff.select_list(:name, "op_numhits")[1].value)   
    end
end


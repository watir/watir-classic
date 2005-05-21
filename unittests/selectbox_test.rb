# feature tests for Select Boxes
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Selectbox < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "selectboxes1.html")
    end
    
    def test_textBox_Exists
        assert($ie.selectBox(:name, "sel1").exists?)   
        assert_false($ie.selectBox(:name, "missing").exists?)   
        assert_false($ie.selectBox(:id, "missing").exists?)   
    end
    
    def test_selectBox_enabled
        assert($ie.selectBox(:name, "sel1").enabled?)   
        assert_raises(UnknownObjectException) { $ie.selectBox(:name, "NoName").enabled? }  
    end
    
    def test_selectBox_getAllContents
        assert_raises(UnknownObjectException) { $ie.selectBox(:name, "NoName").getAllContents }  
        assert_arrayEquals( ["Option 1" ,"Option 2" , "Option 3" , "Option 4"] , 
        $ie.selectBox(:name, "sel1").getAllContents)   
    end
    
    def test_selectBox_getSelectedItems
        assert_raises(UnknownObjectException) { $ie.selectBox(:name, "NoName").getSelectedItems }  
        assert_arrayEquals( ["Option 3" ] , 
        $ie.selectBox(:name, "sel1").getSelectedItems)   
        assert_arrayEquals( ["Option 3" , "Option 6" ] , 
        $ie.selectBox(:name, "sel2").getSelectedItems)   
    end
    
    def test_clearSelection
        assert_raises(UnknownObjectException) { $ie.selectBox(:name, "NoName").clearSelection }  
        $ie.selectBox( :name , "sel1").clearSelection
        
        # the box sel1 has no ability to have a de-selected item
        assert_arrayEquals( ["Option 3" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   
        
        $ie.selectBox( :name , "sel2").clearSelection
        assert_arrayEquals( [ ] , $ie.selectBox(:name, "sel2").getSelectedItems)   
    end
    
    def test_selectBox_select
        assert_raises(UnknownObjectException) { $ie.selectBox(:name, "NoName").getSelectedItems }  
        assert_raises(NoValueFoundException) { $ie.selectBox(:name, "sel1").select("missing item") }  
        assert_raises(NoValueFoundException) { $ie.selectBox(:name, "sel1").select(/missing/) }  
        
        # the select method keeps any currently selected items - use the clear selectcion method first
        $ie.selectBox( :name , "sel1").clearSelection
        $ie.selectBox( :name , "sel1").select("Option 1")
        assert_arrayEquals( ["Option 1" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   
        
        $ie.selectBox( :name , "sel1").clearSelection
        $ie.selectBox( :name , "sel1").select(/2/)
        assert_arrayEquals( ["Option 2" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   
        
        $ie.selectBox( :name , "sel2").clearSelection
        $ie.selectBox( :name , "sel2").select([ /2/ , /4/ ])
        assert_arrayEquals( ["Option 2" , "Option 4" ] , 
        $ie.selectBox(:name, "sel2").getSelectedItems)   
        
        # these are to test the onchange event
        # the event shouldnt get fired, as this is the selected item
        $ie.selectBox( :name , "sel3").select( /3/ )
        assert_false($ie.contains_text("Pass") )
    end
    
    def test_selectBox_select2
        # the event should get fired
        $ie.selectBox( :name , "sel3").select( /2/ )
        assert($ie.contains_text("PASS") )
    end
    
    def test_selectBox_select_using_value
        assert_raises(UnknownObjectException) { $ie.select_list(:name, "NoName").getSelectedItems }  
        assert_raises(NoValueFoundException) { $ie.select_list(:name, "sel1").select_value("missing item") }  
        assert_raises(NoValueFoundException) { $ie.select_list(:name, "sel1").select_value(/missing/) }  
        
        # the select method keeps any currently selected items - use the clear selectcion method first
        $ie.select_list( :name , "sel1").clearSelection
        $ie.select_list( :name , "sel1").select_value("o1")
        assert_arrayEquals( ["Option 1" ] , $ie.select_list(:name, "sel1").getSelectedItems)   
        
        $ie.select_list( :name , "sel1").clearSelection
        $ie.select_list( :name , "sel1").select_value(/2/)
        assert_arrayEquals( ["Option 2" ] , $ie.select_list(:name, "sel1").getSelectedItems)   
        
        $ie.select_list( :name , "sel2").clearSelection
        $ie.select_list( :name , "sel2").select_value([ /2/ , /4/ ])
        assert_arrayEquals( ["Option 2" , "Option 4" ] , $ie.select_list(:name, "sel2").getSelectedItems)   
        
        # these are to test the onchange event
        # the event shouldnt get fired, as this is the selected item
        $ie.select_list( :name , "sel3").select_value( /3/ )
        assert_false($ie.contains_text("Pass") )
    end
    
    def test_select_list_select_using_value2
        # the event should get fired
        $ie.select_list( :name , "sel3").select_value( /2/ )
        assert($ie.contains_text("PASS") )
    end
    
    def test_select_list_properties
        
        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).type }  
        
        assert_equal("o3"   ,    $ie.select_list(:index, 1).value)  
        assert_equal("sel1" ,    $ie.select_list(:index, 1).name )  
        assert_equal(""     ,    $ie.select_list(:index, 1).id )  
        assert_equal("select-one",         $ie.select_list(:index, 1).type )  
        assert_equal("select-multiple",    $ie.select_list(:index, 2).type )  
        
        
        $ie.select_list(:index,1).select(/1/)
        assert_equal("o1"   ,    $ie.select_list(:index, 1).value)  
        
        
        assert_equal( false, $ie.select_list(:index, 1).disabled )
        assert_equal( true,  $ie.select_list(:index, 4).disabled )
        assert_equal( true,  $ie.select_list(:id, 'selectbox_4').disabled )
        
        
        
    end
    
    
    def test_select_list_iterator
        
        assert_equal(4, $ie.select_lists.length)
        assert_equal("o3"   ,    $ie.select_lists[1].value)  
        assert_equal("sel1" ,    $ie.select_lists[1].name )  
        assert_equal("select-one",         $ie.select_lists[1].type )  
        assert_equal("select-multiple" ,   $ie.select_lists[2].type )  
        
        index=1
        $ie.select_lists.each do |l|
            assert_equal( $ie.select_list(:index, index).name , l.name )
            assert_equal( $ie.select_list(:index, index).id , l.id )
            assert_equal( $ie.select_list(:index, index).type , l.type )
            assert_equal( $ie.select_list(:index, index).value , l.value )
            
            index+=1
        end
        assert_equal( index-1, $ie.select_lists.length)
        
    end
    
end

class TC_Select_Options < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "select_tealeaf.html")
    end
    
    def test_options_text
        $ie.select_list(:name, 'op_numhits').option(:text, '>=').select
        assert($ie.select_list(:name, 'op_numhits').option(:text, '>=').selected?)
    end
    
    def test_select_list_properties
        
        
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.select_list(:index, 199).type }  
        
        assert_equal("o3"   ,    $ie.select_list(:index, 1).value)  
        assert_equal("sel1" ,    $ie.select_list(:index, 1).name )  
        assert_equal(""     ,    $ie.select_list(:index, 1).id )  
        assert_equal("select-one",         $ie.select_list(:index, 1).type )  
        assert_equal("select-multiple",    $ie.select_list(:index, 2).type )  
        
        
        $ie.select_list(:index,1).select(/1/)
        assert_equal("o1"   ,    $ie.select_list(:index, 1).value)  
        
        
        assert_equal( false, $ie.select_list(:index, 1).disabled )
        assert_equal( true,  $ie.select_list(:index, 4).disabled )
        assert_equal( true,  $ie.select_list(:id, 'selectbox_4').disabled )
        
        
        
    end
    
    
    def test_select_list_iterator
        
        assert_equal(4, $ie.select_lists.length)
        assert_equal("o3"   ,    $ie.select_lists[1].value)  
        assert_equal("sel1" ,    $ie.select_lists[1].name )  
        assert_equal("select-one",         $ie.select_lists[1].type )  
        assert_equal("select-multiple" ,   $ie.select_lists[2].type )  
        
        index=1
        $ie.select_lists.each do |l|
            assert_equal( $ie.select_list(:index, index).name , l.name )
            assert_equal( $ie.select_list(:index, index).id , l.id )
            assert_equal( $ie.select_list(:index, index).type , l.type )
            assert_equal( $ie.select_list(:index, index).value , l.value )
            
            index+=1
        end
        assert_equal( index-1, $ie.select_lists.length)
        
    end
    
end


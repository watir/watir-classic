# feature tests for Select Boxes
# revision: $Revision: 1.31 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_SelectList < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "selectboxes1.html")
    end
    
    def test_Option_text_select
        assert_raises(UnknownObjectException) { $ie.select_list(:name, "sel1").option(:text, "missing item").select }  
        assert_raises(UnknownObjectException) { $ie.select_list(:name, "sel1").option(:text, /missing/).select }  
        assert_raises(MissingWayOfFindingObjectException) { $ie.select_list(:name, "sel1").option(:missing, "Option 1").select }

        # the select method keeps any currently selected items - use the clear selection method first
        $ie.select_list( :name , "sel1").clearSelection
        $ie.select_list( :name , "sel1").option(:text, "Option 1").select
        assert_equal( ["Option 1" ] , $ie.select_list(:name, "sel1").getSelectedItems)   
    end    


    def xtest_option_class_name

        # the option object doesnt inherit from element, so this doesnt work
        assert_raises(UnknownObjectException) { $ie.select_list(:name, "sel1").option(:text, "missing item").class_name }  
        assert_equal("list_style" , $ie.select_list(:name, "sel2").option(:value , 'o2').class_name)   
        assert_equal("" , $ie.select_list(:name, "sel2").option(:value , 'o1').class_name)   

    end

    def test_selectBox_select_using_value
        assert_raises(UnknownObjectException) { $ie.select_list(:name, "NoName").getSelectedItems }  
        assert_raises(NoValueFoundException) { $ie.select_list(:name, "sel1").select_value("missing item") }  
        assert_raises(NoValueFoundException) { $ie.select_list(:name, "sel1").select_value(/missing/) }  
        
        # the select method keeps any currently selected items - use the clear selectcion method first
        $ie.select_list( :name , "sel1").clearSelection
        $ie.select_list( :name , "sel1").select_value("o1")
        assert_equal( ["Option 1" ] , $ie.select_list(:name, "sel1").getSelectedItems)   
        
        $ie.select_list( :name , "sel1").clearSelection
        $ie.select_list( :name , "sel1").select_value(/2/)
        assert_equal( ["Option 2" ] , $ie.select_list(:name, "sel1").getSelectedItems)   
        
        $ie.select_list( :name , "sel2").clearSelection
        $ie.select_list( :name , "sel2").select_value(/4/)
        $ie.select_list( :name , "sel2").select_value(/2/)
        assert_equal( ["Option 2" , "Option 4" ] , 
            $ie.select_list(:name, "sel2").getSelectedItems)   
        
        # these are to test the onchange event
        # the event shouldnt get fired, as this is the selected item
        $ie.select_list( :name , "sel3").select_value( /3/ )
        assert_false($ie.text.include?("Pass") )
    end
    
    def test_select_list_select_using_value2
        # the event should get fired
        $ie.select_list( :name , "sel3").select_value( /2/ )
        assert($ie.text.include?("PASS") )
    end
    
    def test_select_list_properties
        assert_raises(UnknownObjectException) { $ie.select_list(:index, 199).value }  
        assert_raises(UnknownObjectException) { $ie.select_list(:index, 199).name }  
        assert_raises(UnknownObjectException) { $ie.select_list(:index, 199).id }  
        assert_raises(UnknownObjectException) { $ie.select_list(:index, 199).disabled }  
        assert_raises(UnknownObjectException) { $ie.select_list(:index, 199).type }  
        
        assert_equal("o3"   ,    $ie.select_list(:index, 1).value)  
        assert_equal("sel1" ,    $ie.select_list(:index, 1).name )  
        assert_equal(""     ,    $ie.select_list(:index, 1).id )  
        assert_equal("select-one",         $ie.select_list(:index, 1).type )  
        assert_equal("select-multiple",    $ie.select_list(:index, 2).type )  
        
        $ie.select_list(:index,1).select(/1/)
        assert_equal("o1"   ,    $ie.select_list(:index, 1).value)  
                
        assert_false( $ie.select_list(:index, 1).disabled )
        assert( $ie.select_list(:index, 4).disabled )
        assert( $ie.select_list(:id, 'selectbox_4').disabled )
    end
    
    #def test_select_list_iterator
       # assert_equal(4, $ie.select_lists.length)
      #  assert_equal("o3"   ,    $ie.select_lists[1].value)  
      #  assert_equal("sel1" ,    $ie.select_lists[1].name )  
      #  assert_equal("select-one",         $ie.select_lists[1].type )  
      #  assert_equal("select-multiple" ,   $ie.select_lists[2].type )  
        
      #  index=1
      #  $ie.select_lists.each do |l|
      #      assert_equal( $ie.select_list(:index, index).name , l.name )
      #      assert_equal( $ie.select_list(:index, index).id , l.id )
      #      assert_equal( $ie.select_list(:index, index).type , l.type )
      #      assert_equal( $ie.select_list(:index, index).value , l.value )
     #       index+=1
     #   end
     #   assert_equal( index-1, $ie.select_lists.length)
    #end
end

class TC_Select_Options < Test::Unit::TestCase
    include Watir
    
    def setup()
        $ie.goto($htmlRoot + "select_tealeaf.html")
    end
    
    def test_options_text
        $ie.select_list(:name, 'op_numhits').option(:text, '>=').select
        assert($ie.select_list(:name, 'op_numhits').option(:text, '>=').selected)
    end
end


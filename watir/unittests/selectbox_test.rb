# tests for Select Boxes
# revision: $Revision$

require 'unittests/setup'

class TC_Selectbox < Test::Unit::TestCase


    def gotoPage()
        $ie.goto($htmlRoot + "selectboxes1.html")
    end

    

   

    def test_textBox_Exists
       gotoPage()
       assert($ie.selectBox(:name, "sel1").exists?)   
       assert_false($ie.selectBox(:name, "missing").exists?)   

       assert_false($ie.selectBox(:id, "missing").exists?)   
    end


    def test_selectBox_enabled
       gotoPage()
       assert($ie.selectBox(:name, "sel1").enabled?)   
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.selectBox(:name, "NoName").enabled? }  
    end


    def test_selectBox_getAllContents
       gotoPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.selectBox(:name, "NoName").getAllContents }  
       assert_arrayEquals( ["Option 1" ,"Option 2" , "Option 3" , "Option 4"] , $ie.selectBox(:name, "sel1").getAllContents)   
    end


    def test_selectBox_getSelectedItems
       gotoPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.selectBox(:name, "NoName").getSelectedItems}  

       assert_arrayEquals( ["Option 3" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   
       assert_arrayEquals( ["Option 3" , "Option 6" ] , $ie.selectBox(:name, "sel2").getSelectedItems)   
    end


    def test_clearSelection

       gotoPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.selectBox(:name, "NoName").clearSelection}  
       $ie.selectBox( :name , "sel1").clearSelection

       # the box sel1 has no ability to have a de-selected item
       assert_arrayEquals( ["Option 3" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   

       $ie.selectBox( :name , "sel2").clearSelection
       assert_arrayEquals( [ ] , $ie.selectBox(:name, "sel2").getSelectedItems)   

    end


    def test_selectBox_select
       gotoPage()

       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.selectBox(:name, "NoName").getSelectedItems}  

       assert_raises(NoValueFoundException , "NoValueFoundException was supposed to be thrown" ) {   $ie.selectBox(:name, "sel1").select("missing item") }  
       assert_raises(NoValueFoundException , "NoValueFoundException was supposed to be thrown" ) {   $ie.selectBox(:name, "sel1").select(/missing/) }  

       # the select method keeps any currently selected items - use the clear selectcion method first
       $ie.selectBox( :name , "sel1").clearSelection
       $ie.selectBox( :name , "sel1").select("Option 1")
       assert_arrayEquals( ["Option 1" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   

       $ie.selectBox( :name , "sel1").clearSelection
       $ie.selectBox( :name , "sel1").select(/2/)
       assert_arrayEquals( ["Option 2" ] , $ie.selectBox(:name, "sel1").getSelectedItems)   

       $ie.selectBox( :name , "sel2").clearSelection
       $ie.selectBox( :name , "sel2").select([ /2/ , /4/ ])
       assert_arrayEquals( ["Option 2" , "Option 4" ] , $ie.selectBox(:name, "sel2").getSelectedItems)   


        # these are to test the onchange event

       # the event shouldnt get fired, as this is the selected item
       $ie.selectBox( :name , "sel3").select( /3/ )
       assert_false($ie.pageContainsText("Pass") )
       gotoPage()

       # the event should get fired
       $ie.selectBox( :name , "sel3").select( /2/ )
       assert($ie.pageContainsText("PASS") )
       gotoPage()




    end
end

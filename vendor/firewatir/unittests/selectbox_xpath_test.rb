# feature tests for Select Boxes
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Selectbox_XPath < Test::Unit::TestCase
    include FireWatir

    def setup()
        $ff.goto($htmlRoot + "selectboxes1.html")
    end

    def test_textBox_Exists
       assert($ff.select_list(:xpath, "//select[@name='sel1']").exists?)   
       assert_false($ff.select_list(:xpath, "//select[@name='missing']").exists?)   
       assert_false($ff.select_list(:xpath, "//select[@id='missing']").exists?)   
    end

    def test_element_by_xpath_class
      element = $ff.element_by_xpath("//select[@name='sel1']")
      assert(element.instance_of?(SelectList),"element class should be #{SelectList}; got #{element.class}")
      # FIXME got HTMLAnchorElement, should've gotten HTMLSelectElement
      # TODO: If element is not present, this should return null
      #element = $ff.element_by_xpath("//select[@name='missing']")
      #assert(element.instance_of?(SelectList),"element class should be #{SelectList}; got #{element.class}")
      # FIXME got HTMLAnchorElement, should've gotten HTMLSelectElement
      # TODO: If element is not present, this should return null
      #element = $ff.element_by_xpath("//select[@id='missing']")
      #assert(element.instance_of?(SelectList),"element class should be #{SelectList}; got #{element.class}")
    end

    def test_select_list_enabled
       assert($ff.select_list(:xpath, "//select[@name='sel1']").enabled?)   
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").enabled? }  
    end

    def test_select_list_getAllContents
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").getAllContents }  
       assert_equal( ["Option 1" ,"Option 2" , "Option 3" , "Option 4"] , 
           $ff.select_list(:xpath, "//select[@name='sel1']").getAllContents)   
    end

    def test_select_list_getSelectedItems
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_equal( ["Option 3" ] , 
           $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   
       assert_equal( ["Option 3" , "Option 6" ] , 
           $ff.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   
    end

    def test_clearSelection
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").clearSelection }  
       $ff.select_list(:xpath, "//select[@name='sel1']").clearSelection

       # the box sel1 has no ability to have a de-selected item
       # By default Option 1 will be selected
       assert_equal( ["Option 1" ] , $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       $ff.select_list(:xpath, "//select[@name='sel2']").clearSelection
       assert_equal( [ ] , $ff.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   
    end

    def test_select_list_select
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_raises(NoValueFoundException) { $ff.select_list(:xpath, "//select[@name='sel1']").select("missing item") }  
       assert_raises(NoValueFoundException) { $ff.select_list(:xpath, "//select[@name='sel1']").select(/missing/) }  

       # the select method keeps any currently selected items - use the clear selectcion method first
       $ff.select_list(:xpath, "//select[@name='sel1']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel1']").select("Option 1")
       assert_equal( ["Option 1" ] , $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       $ff.select_list(:xpath, "//select[@name='sel1']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel1']").select(/2/)
       assert_equal( ["Option 2" ] , $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       $ff.select_list(:xpath, "//select[@name='sel2']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel2']").select( /2/ )
       $ff.select_list(:xpath, "//select[@name='sel2']").select( /4/ )
       assert_equal( ["Option 2" , "Option 4" ] , 
       $ff.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   

       # these are to test the onchange event
       # the event shouldnt get fired, as this is the selected item
       $ff.select_list(:xpath, "//select[@name='sel3']").select( /3/ )
       assert_false($ff.text.include?("Pass") )
    end

    def test_select_list_select2
       # the event should get fired
       $ff.select_list(:xpath, "//select[@name='sel3']").select( /2/ )
       assert($ff.text.include?("PASS") )
    end

    def test_select_list_select_using_value
       assert_raises(UnknownObjectException) { $ff.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_raises(NoValueFoundException) { $ff.select_list(:xpath, "//select[@name='sel1']").select_value("missing item") }  
       assert_raises(NoValueFoundException) { $ff.select_list(:xpath, "//select[@name='sel1']").select_value(/missing/) }  

       # the select method keeps any currently selected items - use the clear selectcion method first
       $ff.select_list(:xpath, "//select[@name='sel1']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel1']").select_value("o1")
       assert_equal( ["Option 1" ] , $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       $ff.select_list(:xpath, "//select[@name='sel1']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel1']").select_value(/2/)
       assert_equal( ["Option 2" ] , $ff.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       $ff.select_list(:xpath, "//select[@name='sel2']").clearSelection
       $ff.select_list(:xpath, "//select[@name='sel2']").select( /2/ )
       $ff.select_list(:xpath, "//select[@name='sel2']").select( /4/ )
       assert_equal( ["Option 2" , "Option 4" ] , $ff.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   

       # these are to test the onchange event
       # the event shouldnt get fired, as this is the selected item
       $ff.select_list(:xpath, "//select[@name='sel3']").select_value( /3/ )
       assert_false($ff.text.include?("Pass") )
    end

    def test_select_list_select_using_value2
       # the event should get fired
       $ff.select_list(:xpath, "//select[@name='sel3']").select_value( /2/ )
       assert($ff.text.include?("PASS") )
    end

end

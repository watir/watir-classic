# feature tests for Select Boxes
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Selectbox_XPath < Test::Unit::TestCase
    

    def setup()
        goto_page("selectboxes1.html")
    end

    def test_textBox_Exists
       assert(browser.select_list(:xpath, "//select[@name='sel1']").exists?)   
       assert_false(browser.select_list(:xpath, "//select[@name='missing']").exists?)   
       assert_false(browser.select_list(:xpath, "//select[@id='missing']").exists?)   
    end

    tag_method :test_element_by_xpath_class, :fails_on_ie
    def test_element_by_xpath_class
      element = browser.element_by_xpath("//select[@name='sel1']")
      assert_class(element, 'SelectList')
      # FIXME got HTMLAnchorElement, should've gotten HTMLSelectElement
      # TODO: If element is not present, this should return null
      #element = browser.element_by_xpath("//select[@name='missing']")
      #assert(element.instance_of?(SelectList),"element class should be #{SelectList}; got #{element.class}")
      # FIXME got HTMLAnchorElement, should've gotten HTMLSelectElement
      # TODO: If element is not present, this should return null
      #element = browser.element_by_xpath("//select[@id='missing']")
      #assert(element.instance_of?(SelectList),"element class should be #{SelectList}; got #{element.class}")
    end

    def test_select_list_enabled
       assert(browser.select_list(:xpath, "//select[@name='sel1']").enabled?)   
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").enabled? }  
    end

    def test_select_list_getAllContents
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").getAllContents }  
       assert_equal( ["Option 1" ,"Option 2" , "Option 3" , "Option 4"] , 
           browser.select_list(:xpath, "//select[@name='sel1']").getAllContents)   
    end

    def test_select_list_getSelectedItems
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_equal( ["Option 3" ] , 
           browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   
       assert_equal( ["Option 3" , "Option 6" ] , 
           browser.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   
    end

    tag_method :test_clearSelection, :fails_on_ie
    def test_clearSelection
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").clearSelection }  
       browser.select_list(:xpath, "//select[@name='sel1']").clearSelection

       # the box sel1 has no ability to have a de-selected item
       # By default Option 1 will be selected
       assert_equal( ["Option 1" ] , browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       browser.select_list(:xpath, "//select[@name='sel2']").clearSelection
       assert_equal( [ ] , browser.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   
    end

    def test_select_list_select
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_raises(NoValueFoundException) { browser.select_list(:xpath, "//select[@name='sel1']").select("missing item") }  
       assert_raises(NoValueFoundException) { browser.select_list(:xpath, "//select[@name='sel1']").select(/missing/) }  

       # the select method keeps any currently selected items - use the clear selectcion method first
       browser.select_list(:xpath, "//select[@name='sel1']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel1']").select("Option 1")
       assert_equal( ["Option 1" ] , browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       browser.select_list(:xpath, "//select[@name='sel1']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel1']").select(/2/)
       assert_equal( ["Option 2" ] , browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       browser.select_list(:xpath, "//select[@name='sel2']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel2']").select( /2/ )
       browser.select_list(:xpath, "//select[@name='sel2']").select( /4/ )
       assert_equal( ["Option 2" , "Option 4" ] , 
       browser.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   

       # these are to test the onchange event
       # the event shouldnt get fired, as this is the selected item
       browser.select_list(:xpath, "//select[@name='sel3']").select( /3/ )
       assert_false(browser.text.include?("Pass") )
    end

    def test_select_list_select2
       # the event should get fired
       browser.select_list(:xpath, "//select[@name='sel3']").select( /2/ )
       assert(browser.text.include?("PASS") )
    end

    def test_select_list_select_using_value
       assert_raises(UnknownObjectException) { browser.select_list(:xpath, "//select[@name='NoName']").getSelectedItems }  
       assert_raises(NoValueFoundException) { browser.select_list(:xpath, "//select[@name='sel1']").select_value("missing item") }  
       assert_raises(NoValueFoundException) { browser.select_list(:xpath, "//select[@name='sel1']").select_value(/missing/) }  

       # the select method keeps any currently selected items - use the clear selectcion method first
       browser.select_list(:xpath, "//select[@name='sel1']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel1']").select_value("o1")
       assert_equal( ["Option 1" ] , browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       browser.select_list(:xpath, "//select[@name='sel1']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel1']").select_value(/2/)
       assert_equal( ["Option 2" ] , browser.select_list(:xpath, "//select[@name='sel1']").getSelectedItems)   

       browser.select_list(:xpath, "//select[@name='sel2']").clearSelection
       browser.select_list(:xpath, "//select[@name='sel2']").select( /2/ )
       browser.select_list(:xpath, "//select[@name='sel2']").select( /4/ )
       assert_equal( ["Option 2" , "Option 4" ] , browser.select_list(:xpath, "//select[@name='sel2']").getSelectedItems)   

       # these are to test the onchange event
       # the event shouldnt get fired, as this is the selected item
       browser.select_list(:xpath, "//select[@name='sel3']").select_value( /3/ )
       assert_false(browser.text.include?("Pass") )
    end

    def test_select_list_select_using_value2
       # the event should get fired
       browser.select_list(:xpath, "//select[@name='sel3']").select_value( /2/ )
       assert(browser.text.include?("PASS") )
    end

end

#-------------------------------------------------------------------------------------------------------------#
# demo test for the WATIR controller                                                              
#                                                                                                                  
#  Simple Yahoo test written by Jonathan Kohl   10/14/04                                                 
# Purpose: to demonstrate the following WATIR functionality:                                               
#   * entering text into a text field                                                                   
#   * clicking a button
#   * clicking a check box
#   * clicking a hyperlink
#   * checking to see if a page contains text.                                                   
#   * using a test::unit "assert" ( http://www.nunit.org/assertions.html )
#
#------------------------------------------------------------------------------------------------------------ #

#includes
require 'watir'   # the controller

#test::unit includes
require 'test/unit' 
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'


class TC_yahoo < Test::Unit::TestCase


 def test_a_simplesearch
  #--------------------------------------------------------
  # test case that shows basic WATIR functionality:
  #   * enter text in a field
  #   * click a button
  #
  
   #variables
   testSite = 'http://www.yahoo.com'

   #open the IE browser
   $ie = IE.new

   puts '## Beginning of test: Yahoo simple search'
   puts '  '
  
   puts 'Step 1: go to the yahoo site: www.yahoo.com'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + ' in the address bar.'

   puts 'Step 2: enter "pickaxe: in the search text field'
   $ie.textField(:name, "p").set("pickaxe")
   puts '  Action: entered pickaxe in the search field'

   puts 'Step 3: click the "Yahoo Search" button'
   $ie.button(:caption, "Yahoo! Search").click
   puts '  Action: clicked the Search the Web button.'

   puts 'Expected Result: '
   puts ' - a Yahoo page with results should be shown. A result containing "Programming Ruby" should be high on the list.'
  
   puts 'Actual Result: Check that the "Programming Ruby" link actually appears on the page by using an assertion'
   assert($ie.pageContainsText("Programming Ruby") )

   puts '  '
   puts '## End of test: yahoo simple search'
  
 end # end of test_simplesearch



 def test_b_EditCheckMaps
   
   #-------------------------------------------------------------------------
   # Test to demonstrate WATIR click checkbox functionality
   #
   
   #variables
   testSite = 'http://search.yahoo.com'

   puts '## Beginning of test: Yahoo Edit Check Maps'
   puts '  '
  
   puts 'Step 1: go to the yahoo site: search.yahoo.com'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + 'in the address bar.'

   puts 'Step 2: click the Edit link on the yahoo home page'
   $ie.link(:text, "Edit").click
   puts '  Action: clicked the Edit link'
   
   $ie.checkBox(:name, "tab[]", "maps").set
   assert($ie.checkBox(:name, "tab[]", "maps").isSet?)   
   
   puts '  '
   puts '## End of test: yahoo simple search'


 end

 def test_c_SaveMapsEdit
    #-------------------------------------------------------------------------
    # Test to Save Yahoo preferences after checking "Maps" above
    #
   puts '## Beginning of test: Yahoo Save Maps Edit'
   puts '  '
   
   puts 'Step 1: click the "Save" button'
   $ie.button(:caption, "Save").click
   puts '  Action: clicked the Save button.'
  
   puts 'Step 2: Check that the "Maps" link actually appears on the Yahoo Search page by using an assertion'
   assert($ie.pageContainsText("Maps") )
   
   puts '  '
   puts '## End of test: Yahoo Save Maps Edit'
   
 end

 def test_d_UncheckMaps
   #-------------------------------------------------------------------------
   # Test to demo unchecking a check box
   #
   puts '## Beginning of test: Yahoo Uncheck Maps Edit'
   puts '  '   
   
   puts 'Step 1: click the Edit link on the yahoo home page'
   $ie.link(:text, "Edit").click
   puts '  Action: clicked the Edit link'

   $ie.checkBox(:name, "tab[]", "maps").clear
   assert_false($ie.checkBox(:name, "tab[]", "maps").isSet?) 

   puts '  '
   puts '## End of test: Yahoo Uncheck Maps Edit'
   
 end

 def test_e_VerifyMapsUncheck
   #-------------------------------------------------------------------------
   # Test to verify that the actions are saved after unchecking the Maps check box
   #
   puts '## Beginning of test: Yahoo Verify Edit Actions saved'
   puts '  '
   
   puts 'Step 1: click the "Save" button'
   $ie.button(:caption, "Save").click
   puts '  Action: clicked the Save button.'
   
   puts 'Step 2: Check that the "Maps" link does not appear on the Yahoo Search page by using an assertion'
   assert_false($ie.pageContainsText("Maps") )
   
   puts '  '
   puts '## End of test: Verify Edit Actions saved'
   
 end   


 
  


end  #end of class TC_yahoo
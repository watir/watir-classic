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
include Watir

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
   test_site = 'http://www.yahoo.com'

   #open the IE browser
   $ie = IE.new

   puts '## Beginning of test: Yahoo simple search'
   puts '  '
  
   puts 'Step 1: go to the yahoo site: www.yahoo.com'
   $ie.goto(test_site)
   puts '  Action: entered ' + test_site + ' in the address bar.'

   puts 'Step 2: enter "pickaxe: in the search text field'
   $ie.text_field(:name, "p").set("pickaxe")
   puts '  Action: entered pickaxe in the search field'

   puts 'Step 3: click the "Yahoo Search" button'
   $ie.button(:id, "searchsubmit").click
   puts '  Action: clicked the Search the Web button.'

   puts 'Expected Result: '
   puts ' - a Yahoo page with results should be shown. A result containing "Programming Ruby" should be high on the list.'
  
   puts 'Actual Result: Check that the "Programming Ruby" link actually appears on the page by using an assertion'
   assert($ie.text.include?("Programming Ruby") )

   puts '  '
   puts '## End of test: yahoo simple search'
  
 end # end of test_simplesearch



 def test_b_EditCheckMaps
   
   #-------------------------------------------------------------------------
   # Test to demonstrate WATIR click checkbox functionality
   #
   
   #variables
   test_site = 'http://search.yahoo.com'

   puts '## Beginning of test: Yahoo Advanced Search'
   puts '  '
  
   puts 'Step 1: go to the yahoo site: search.yahoo.com'
   $ie.goto(test_site)
   puts '  Action: entered ' + test_site + 'in the address bar.'

   puts 'Step 2: click the Advanced Search link'
   $ie.link(:text, "Advanced Search").click
   puts '  Action: clicked the Advanced Search link'
   
   $ie.text_field(:id, 'f0va').set('derrida')
   $ie.checkbox(:id, "f0cccb0").set
   assert($ie.checkbox(:id, "f0cccb0").checked?)   
   $ie.button(:value, 'Yahoo! Search').click
   assert($ie.text.include?('Creative Commons Search'), "Creative Commons Search not found on page")
   assert($ie.text.include?('Jacques Derrida'), "Jacques Derrida not found on page")
   puts '  '
   puts '## End of test: yahoo advanced search'


 end

 def test_uncheck
    #-------------------------------------------------------------------------
    # Test unchecking and additional assertions
    #
    puts '## Go back to the search page'
    $ie.back
    puts '## Verify the text field still has the same content'
    assert_equal('derrida', $ie.text_field(:id, 'f0va').getContents)
    assert($ie.checkbox(:id, "f0cccb0").checked?)   
    $ie.checkbox(:id, "f0cccb0").clear
    puts '## Make sure checkbox has been cleared'
    assert(!$ie.checkbox(:id, "f0cccb0").checked?)   
    $ie.button(:value, 'Yahoo! Search').click   
    puts '## Check that the page no longer contains Creative Commons'
    assert_no_match(/Creative Commons/, $ie.text)
 end   

end  #end of class TC_yahoo
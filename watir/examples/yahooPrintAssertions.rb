#-------------------------------------------------------------------------------------------------------------#
# demo test for the WATIR controller                                                              
#                                                                                                                  
#  Simple Yahoo test written by Jonathan Kohl   01/03/05                                                 
# Purpose: to demonstrate the following WATIR functionality:                                               
#   * entering text into a text field                                                                   
#   * clicking a button
#   * using a test::unit "assert" 
#   * printing the assertion result to the screen
#
#------------------------------------------------------------------------------------------------------------ #

#includes
require 'watir'   # the controller

#test::unit includes
require 'test/unit' 
require 'test/unit/ui/console/testrunner'


class TC_yahoo_assert < Test::Unit::TestCase


 def test_print_assertion
  #--------------------------------------------------------
  # test case that shows basic WATIR functionality:
  #   * enter text in a field
  #   * click a button
  #   * print assertion results
  
   #variables
   testSite = 'http://www.yahoo.com'

   #open the IE browser
   $ie = IE.new

   puts "## Beginning of test: Yahoo print assertion"
   puts "  "
  
   puts "Step 1: go to the yahoo site: www.yahoo.com"
   $ie.goto(testSite)
   puts "  Action: entered ' + testSite + 'in the address bar."

   puts "Step 2: enter 'pickaxe' in the search text field"
   $ie.textField(:name, "p").set("pickaxe")
   puts "  Action: entered 'pickaxe' in the search field"

   puts "Step 3: click the 'Yahoo Search' button"
   $ie.button(:value, "Yahoo! Search").click
   puts '  Action: clicked the Search the Web button.'

   puts "Expected Result:" + "\n"
   puts " - a Yahoo page with results should be shown. A result containing the string 'Programming Ruby' should be high on the list."
  
   puts "Actual Result:" + "\n"
   
   #use this block for our assertion, and printing the results to the screen. You could also easily print results to a file with this method.
   begin
      assert($ie.pageContainsText("Programming Ruby") )
	 puts("TEST PASSED. Found test string 'Programming Ruby' ")
   rescue => e
         puts("TEST FAILED." + e.message + "\n" + e.backtrace.join("\n")) 
   end

   puts "  "
   puts "## End of test: Yahoo print assertion"
  
 end # end of test_print_assertion



end  #end of class TC_yahoo_assert
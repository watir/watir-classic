

#-------------------------------------------------------------------------------------------------------------#
# demo test for the WATIR controller                                           
#                                                                              
#  Simple Google test written by Jonathan Kohl   10/10/04                      
# Purpose: to demonstrate the following WATIR functionality:                   
#   * entering text into a text field                                          
#   * clicking a button
#   * checking to see if a page contains text.                                 
# Test will search Google for the "pickaxe" Ruby book
#
#------------------------------------------------------------------------------------------------------------#

   #includes:
   require 'watir'   # the watir controller

   #variables:
   testSite = 'http://www.google.com'
  
   #open the IE browser
   $ie = IE.new

   puts "## Beginning of test: Google search"
   puts "  "
  
   puts "Step 1: go to the test site: " + testSite
   $ie.goto(testSite)
   puts "  Action: entered " + testSite + "in the address bar."

   puts "Step 2: enter 'pickaxe' in the search text field"
   $ie.textField(:name, "q").set("pickaxe")       # q is the name of the search field
   puts "  Action: entered pickaxe in the search field"

   puts "Step 3: click the 'Google Search' button"
   $ie.button(:name, "btnG").click   # "btnG" is the name of the Search button
   puts "  Action: clicked the Google Search button."

   puts "Expected Result: "
   puts " - a Google page with results should be shown. 'Programming Ruby' should be high on the list."
  
   puts "Actual Result: Check that the 'Programming Ruby' link appears on the results page "
   a = $ie.pageContainsText("Programming Ruby") 
   if !a 
      puts "Test Failed! Could not find: 'Programming Ruby'" 
   else
      puts "Test Passed. Found the test string: 'Programming Ruby'. Actual Results match Expected Results."
   end
   
   puts "  "
   puts "## End of test: Google search"
  

# -end of simple Google search test



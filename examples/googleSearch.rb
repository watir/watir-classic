

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

   #includes
   require '../watir'   # the controller

   #variables
   testSite = 'http://www.google.com'

   #open the IE browser
   $ie = IE.new

   puts '## Beginning of test: google search'
   puts '  '
  
   puts 'Step 1: go to the google site: www.google.com'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + 'in the address bar.'

   puts 'Step 2: enter "pickaxe: in the search text field'
   $ie.textField(:name, "q").set("pickaxe")       # q is the name of the search field
   puts '  Action: entered pickaxe in the search field'

   puts 'Step 3: click the "Google Search" button'
   $ie.button(:caption, "Google Search").click   # Google Search is the caption of the button
   puts '  Action: clicked the Google Search button.'

   puts 'Expected Result: '
   puts ' - a google page with results should be shown. "Pragmatic Programmers LLC" should be high on the list.'
  
   puts 'Actual Result: Check that the "The Pragmatic Programmers, LLC" link actually appears on the page by using an assertion'
   a = $ie.pageContainsText("The Pragmatic Programmers, LLC") 
   if !a 
      puts "Test Failed! Could not find test string: The Pragmatic Programmers, LLC" 
   else
      puts "Test Passed. Found the test string: The Pragmatic Programmers, LLC. Actual Results match Expected Results."
   end
   
   puts '  '
   puts '## End of test: google search'
  

# -end of simple google search test





#-------------------------------------------------------------------------------------------------------------#
# demo test for the WATIR controller                                           
                  
#                                                                              
                                   
#  Simple Google test written by Jonathan Kohl   10/10/04                      
                          
# Purpose: to demonstrate the following WATIR functionality:                   
                           
#   * entering text into a text field                                          
                        
#   * clicking a button
#   * checking to see if a page contains text.                                 
                 
#   * using a test::unit "assert" ( http://www.nunit.org/assertions.html )
#
#------------------------------------------------------------------------------------------------------------
#

#includes
require 'watir.rb'   # the controller

#test::unit includes
require 'test/unit' 
require 'test/unit/ui/console/testrunner'
require 'testUnitAddons'

#code to set your current path in Windows
$myDir = File.dirname(__FILE__)
$LOAD_PATH << $myDir

class TC_google < Test::Unit::TestCase
 
  def test_google
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
   $ie.textField(:name, "q").set("pickaxe")  # q is the name of the search field

   puts '  Action: entered pickaxe in the search field'

   puts 'Step 3: click the "Google Search" button'
   $ie.button(:caption, "Google Search").click
   puts '  Action: clicked the Google Search button.'

   puts 'Expected Result: '
   puts ' - a google page with results should be shown. "Pragmatic Programmers LLC" should be high on the list.'
  
   puts 'Actual Result: Check that the "The Pragmatic Programmers, LLC" link actually appears on the page by using an assertion'
   assert($ie.pageContainsText("The Pragmatic Programmers, LLC") )

   puts '  '
   puts '## End of test: google search'
  
   end

end 

# -end of simple google search test
#####


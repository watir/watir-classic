#-------------------------------------------------------------------------------------------------------------#
# demo test for the WATIR controller                                                              
#                                                                                                                  
#  Simple Google test written by Jonathan Kohl   10/14/04                                                 
# Purpose: to demonstrate the following WATIR functionality:                                               
#   * entering text into a text field                                                                   
#   * clicking a button
#   * selecting from a drop-down box
#   * clicking a radio button
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
require 'unittests/testUnitAddons'

#code to set your current path in Windows
$myDir = File.dirname(__FILE__)
$LOAD_PATH << $myDir

class TC_google_suite < Test::Unit::TestCase



 def test_a_simplesearch
  #--------------------------------------------------------
  # test case that shows basic WATIR functionality:
  #   * enter text in a field
  #   * click a button
  #
  
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
   $ie.textField(:name, "q").set("pickaxe")
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
  
 end # end of test_simplesearch




 def test_b_googlenews
   
   #-------------------------------------------------------------------------
   # Test to demonstrate WATIR select from drop-down box functionality
   #
   
   #variables
   testSite = 'http://news.google.com'

   puts '## Beginning of test: google news use drop-down box'
   puts '  '
  
   puts 'Step 1: go to the google news site: news.google.com'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + 'in the address bar.'

   puts 'Step 2: Select Canada from the Top Stories drop-down list'
   $ie.selectBox( :name , "meta").select("Canada English")
   puts '  Action: selected Canada from the drop-down list.'

   puts 'Step 3: click the "Go" button'
   $ie.button(:caption, "Go").click
   puts '  Action: clicked the Go button.'

   puts 'Expected Result: '
   puts ' - The Google News Canada site should be displayed'
  
   puts 'Actual Result: Check that "Canada" appears on the page by using an assertion'
   assert($ie.pageContainsText("Canada") )

   puts '  '
   puts '## End of test: google news selection'
  
 end # end of test_googlenews


 def test_c_googleradio
   
   #-------------------------------------------------------------------------
   # Test to demonstrate WATIR click radio button functionality
   #
   
   #variables
   testSite = 'http://www.google.ca'

   puts '## Beginning of test: google Canada - use radio button'
   puts '  '
  
   puts 'Step 1: go to the google Canada site: www.google.ca'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + 'in the address bar.'

   
   puts 'Step 2: enter "WATIR: in the search text field'
   $ie.textField(:name, "q").set("WATIR")
   puts '  Action: entered watir in the search field'
   
   puts 'Step 3: Select Search: pages from Canada from the radio list'
   $ie.radio(:name, "meta" , "cr=countryCA").set
   puts '  Action: selected pages Canada radio button.'
  
   puts 'Step 4: click the "Google Search" button'
   $ie.button(:caption, "Google Search").click
   puts '  Action: clicked the Google Search button.'
     
   puts 'Expected Result: '
   puts ' a google page with results should be shown. "Collaborative Software Testing" should be high on the list.'
  
   puts 'Actual Result: Check that "Collaborative Software Testing" appears on the page by using an assertion'
   assert($ie.pageContainsText("Collaborative Software Testing") )

   puts '  '
   puts '## End of test: google Canada search selection'
  
 end # end of test_googleradio


 def test_d_googlegroups
   
   #-------------------------------------------------------------------------
   # Test to demonstrate WATIR click hyperlink functionality
   #
   
   #variables
   testSite = 'http://www.google.com'


   puts '## Beginning of test: google groups'
   puts '  '
  
   puts 'Step 1: go to the google site: www.google.com'
   $ie.goto(testSite)
   puts '  Action: entered ' + testSite + 'in the address bar.'

   puts 'Step 2: click the Groups link on the google home page'
   $ie.link(:text, "Groups").click
   puts '  Action: clicked the Groups link'
   
      puts 'Step 3: enter "comp.lang.ruby" in the search text field'
   $ie.textField(:name, "q").set("comp.lang.ruby")
   puts '  Action: entered comp.lang.ruby in the search field'

   puts 'Step 4: click the "Google Search" button'
   $ie.button(:caption, "Google Search").click
   puts '  Action: clicked the Google Search button.'

   puts 'Expected Result: '
   puts ' - The Google Groups page for comp.lang.ruby should be shown.'
   
   puts 'Actual Result: Check that the "comp.lang.ruby" link actually appears on the page by using an assertion'
   assert($ie.pageContainsText("comp.lang.ruby") )
   
   puts '  '
   puts '## End of test: google groups'

 end # end of test_googlegroups
 
  


end  #end of class TC_google_suite
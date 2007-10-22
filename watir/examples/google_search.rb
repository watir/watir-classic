# Please, when you update this file, update also http://wiki.openqa.org/display/WTR/Example+Test+Case

#-------------------------------------------------------------#
# Demo test for the Watir controller.
#
# Simple Google test written by Jonathan Kohl 10/10/04.
# Purpose: to demonstrate the following Watir functionality:
#   * entering text into a text field,
#   * clicking a button,
#   * checking to see if a page contains text.
# Test will search Google for the "pickaxe" Ruby book.
#-------------------------------------------------------------#

# the Watir controller
require "watir"

# set a variable
test_site = "http://www.google.com"

# open the IE browser
ie = Watir::IE.new

# print some comments
puts "Beginning of test: Google search."

puts " Step 1: go to the test site: " + test_site
ie.goto test_site

puts " Step 2: enter 'pickaxe' in the search text field."
ie.text_field(:name, "q").set "pickaxe" # "q" is the name of the search field

puts " Step 3: click the 'Google Search' button."
ie.button(:name, "btnG").click # "btnG" is the name of the Search button

puts " Expected Result:"
puts "  A Google page with results should be shown. 'Programming Ruby' should be high on the list."

puts " Actual Result:"
if ie.text.include? "Programming Ruby"  
  puts "  Test Passed. Found the test string: 'Programming Ruby'. Actual Results match Expected Results."
else
  puts "  Test Failed! Could not find: 'Programming Ruby'." 
end

puts "End of test: Google search."
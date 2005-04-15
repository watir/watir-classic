require 'thread'
require 'watir'
require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'watir/testUnitAddons'
include Watir

testSite = 'http://www.fortlewis.edu'
$ie = IE.new
ie2 = nil
puts "## Beginning of Example:  FortLewis.edu"
puts "    "
sleep 1
puts "Step 1: go to the test site:  " + testSite
$ie.goto(testSite)
$ie.link(:text,"      Prospective Students      ").fireEvent("onMouseOver")
sleep 1
$ie.link(:text,"      Prospective Students      ").fireEvent("onMouseOut")
$ie.link(:text,"  Current Students  ").fireEvent("onMouseOver") 
$ie.link(:url,"http://faculty.fortlewis.edu/").flash
sleep 1

$ie.link(:url,"http://faculty.fortlewis.edu/").click
sleep 1

ie2 = IE.attach(:title, "Faculty Web Sites @ Fort Lewis College, Durango Colorado") 
ie2.link(:url,"http://faculty.fortlewis.edu/ADAMS_E").flash
ie2.link(:url,"http://faculty.fortlewis.edu/ADAMS_E").click
sleep 1
ie2.link(:url,/classnotesandassignments.html/).flash
ie2.link(:url,/classnotesandassignments.html/).click
sleep 1 
ie2.link(:url,/CS496W05/).flash
ie2.link(:url,/CS496W05/).click
sleep 1

ie2.link(:url,/schedulew05.html/).flash
ie2.link(:url,/schedulew05.html/).click
sleep 1

ie2.link(:url,/TopicProposalScheduleW05.htm/).flash
ie2.link(:url,/TopicProposalScheduleW05.htm/).click

#includes
require 'watir'
include Watir

#test::unit includes
require 'test/unit' 
require 'test/unit/ui/console/testrunner'

#logger includes
require 'example_logger1'

class TC_google_logging < Test::Unit::TestCase

   def start
   #open the IE browser
    $ie = IE.new
    filePrefix = "test_logger1"
   #create a logger 
    $logger = LoggerFactory.start_xml_logger(filePrefix) 
    $ie.set_logger($logger)
  end


 def test_a_simplesearch

  #call start method...
  start #fires up the IE browser and a logger object

  #variables
   test_site = 'http://www.google.com'
  #
   $logger.log("")
   $logger.log("## Beginning of test: Google search") #logs only to corelogger file 
   $logger.log("Step 1: Go to the Google site: www.google.com")
   $ie.goto(test_site)
   $logger.log(" Action: entered " + test_site + " in the address bar.")

   $logger.log("Step 2: Enter 'pickaxe' in the search text field")
   $ie.text_field(:name, "q").set("pickaxe")
   $logger.log("  Action: entered pickaxe in the search field")

   $logger.log("Step 3: Click the 'Google Search' button")
   $ie.button(:name, "btnG").click
   $logger.log("  Action: clicked the Google Search button.")

   $logger.log("Expected Result: ")
   $logger.log(" - A Google page with results should be shown. 'Programming Ruby' should be high on the list.")

   $logger.log("Actual Result: Check that the 'Programming Ruby' link actually appears on the page by using an assertion")

   begin
        assert($ie.contains_text("Programming Ruby") )
        $logger.log("Passed. Found test string 'Programming Ruby' ")
        $logger.log_results("test_a_simplesearch", "pickaxe", "Programming Ruby", "TEST PASSED.") #logs to both the XML file and corelogger
   rescue => e
        $logger.log("*FAILED*." + e.message + "\n" + e.backtrace.join("\n"))
        $logger.log_results("test_a_simplesearch", "pickaxe", "Programming Ruby", "TEST FAILED.")  #logs to both the XML file and corelogger    
   end


   $logger.log "## End of test: google search\n"
  

 end # end of test_simplesearch
 
 def test_b_googlenews

   #variables
   test_site = 'http://news.google.com'

   $logger.log("## Beginning of test: Google News")
  
   $logger.log("Step 1: go to the Google news site: news.google.com")
   $ie.goto(test_site)
   $logger.log("  Action: entered " + test_site + " in the address bar.")

   $logger.log("Step 2: Select Canada from the Top Stories drop-down list")
   $ie.select_list( :index , 1).select("Canada English")
   $logger.log("  Action: selected Canada from the drop-down list.")

   $logger.log("Step 3: click the 'Go' button")
   $ie.button(:caption, "Go").click
   $logger.log("  Action: clicked the Go button.")

   $logger.log("Expected Result: ")
   $logger.log(" - The Google News Canada site should be displayed")
  
   $logger.log(" Actual Result: Check that 'Canada' appears on the page by using an assertion")
   
   begin
       assert($ie.contains_text("Canada") )
       $logger.log("TEST PASSED. Found test string 'Canada' ")
        $logger.log_results("test_b_googlenews", "Canada English", "Canada", "TEST PASSED.") #logs to both the XML file and corelogger
   rescue => e
        $logger.log("TEST FAILED." + e.message + "\n" + e.backtrace.join("\n"))
        $logger.log_results("test_b_googlenews", "Canada English", "Canada", "TEST FAILED.")  #logs to both the XML file and corelogger    
   end
   
   $logger.log '## End of test: Google news selection'

   $logger.end_log  #close XML log file
  
 end # end of test_googlenews
 

  
end  #end of class TC_google_logging

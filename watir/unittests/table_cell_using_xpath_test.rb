# feature tests for xpath table cells
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_TableCell_XPath < Test::Unit::TestCase
  
  def setup
    goto_page "tableCell_using_xpath.html"
  end
  
  def testCellExists
    # There is no <image> with @src='rectangle.jpg'. So image will not be there.
    assert_false( browser.cell(:xpath , "//img[@src='images\/rectangle.jpg']/../").exists?  )
    # Select the parent element of image with src='square.jpg' which is a tablecell.
    assert(       browser.cell(:xpath , "//img[@src='images\/square.jpg']/../").exists?  )
    assert(       browser.cell(:xpath , "//img[@src='images\/triangle.jpg']/../").exists?  )
    puts "Selected table cell with text 'Table Cell with image of triangle.'"
    puts browser.cell(:xpath , "//img[@src='images\/triangle.jpg']/../").to_s
  end
  
  def testCell_properties
    assert_equal(1 , browser.cell(:xpath , "//img[@src='images\/square.jpg']/../").colspan) 
    assert_equal(2 , browser.cell(:xpath , "//img[@src='images\/triangle.jpg']/../").colspan) 
    assert_equal(3 , browser.cell(:xpath , "//img[@src='images\/circle.jpg']/../").colspan) 
    assert_equal(4 , browser.cell(:xpath , "//img[@src='images\/button.jpg']/../").colspan) 
    
    # to string tests -- output should be verified!
    puts browser.cell(:xpath , "//img[@src='images\/square.jpg']/../").to_s
    puts browser.cell(:xpath , "//img[@src='images\/triangle.jpg']/../").to_s
  end
  
end


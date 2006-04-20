# feature tests for file Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_FileField < Test::Unit::TestCase
  include Watir
  
  def gotoPage
    $ie.goto($htmlRoot + "fileupload.html")
  end
  
  def test_fileField_Exists
    gotoPage
    #test for existance of 4 file area
    assert($ie.fileField(:name,"file1").exists?)
    assert($ie.fileField(:id,"file2").exists?)
    #test for missing 
    assert(!$ie.fileField(:name, "missing").exists?)   
    assert(!$ie.fileField(:name,"totallybogus").exists?)
    #pop one open and put something in it.
    $ie.fileField(:name,"file1").set($htmlRoot + "fileupload.html")	
    #click the upload button
    $ie.button(:name,"upload").click
    
    assert($ie.text.include?("PASS"))	
  end
  
  def test_iterator
    gotoPage
    assert_equal(6, $ie.file_fields.length)
  end
  
end

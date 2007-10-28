# feature tests for TextArea Fields
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_FileField_XPath < Test::Unit::TestCase
    include FireWatir

  def gotoPage
 	$ff.goto($htmlRoot + "fileupload.html")
  end
  
  def test_file_field_Exists
	gotoPage()
	#test for existance of 4 file area
	assert($ff.file_field(:xpath, "//input[@name='file1']").exists?)
	assert($ff.file_field(:xpath, "//input[@id='file2']").exists?)
	#test for missing 
	assert_false($ff.file_field(:xpath, "//input[@name='missing']").exists?)   
	assert_false($ff.file_field(:xpath, "//input[@name='totallybogus']").exists?)
	#pop one open and put something in it.
	$ff.file_field(:xpath, "//input[@name='file3']").set($htmlRoot + "fileupload.html")	
	#click the upload button
	$ff.button(:xpath, "//input[@name='upload']").click

	assert($ff.text.include?("PASS"))	
    end

    #def test_iterator
    #    gotoPage()
    #    assert_equal(6, $ff.file_fields.length)
    #end

end

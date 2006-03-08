# feature tests for TextArea Fields
# revision: $Revision: 1.3 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_FileField_XPath < Test::Unit::TestCase
  include Watir

  def gotoPage
 	$ie.goto($htmlRoot + "fileupload.html")
  end
  
  def test_file_field_Exists
	gotoPage()
	#test for existance of 4 file area
	assert($ie.file_field(:xpath, "//input[@name='file1']").exists?)
	assert($ie.file_field(:xpath, "//input[@id='file2']").exists?)
	#test for missing 
	assert_false($ie.file_field(:xpath, "//input[@name='missing']").exists?)   
	assert_false($ie.file_field(:xpath, "//input[@name='totallybogus']").exists?)
	#pop one open and put something in it.
	$ie.file_field(:xpath, "//input[@name='file1']").set($htmlRoot + "fileupload.html")	
	#click the upload button
	$ie.button(:xpath, "//input[@name='upload']").click

	assert($ie.text.include?("PASS"))	
    end

    #def test_iterator
    #    gotoPage()
    #    assert_equal(6, $ie.file_fields.length)
    #end

end

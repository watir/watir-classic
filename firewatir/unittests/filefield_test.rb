# feature tests for file Fields
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_FileField < Test::Unit::TestCase
    

  def gotoPage()
	goto_page("fileupload.html")
  end

  def test_fileField_Exists
	gotoPage()
	#test for existance of 4 file area
	assert(browser.file_field(:name,"file1").exists?)
	assert(browser.file_field(:id,"file2").exists?)
	#test for missing 
	assert_false(browser.file_field(:name, "missing").exists?)   
	assert_false(browser.file_field(:name,"totallybogus").exists?)
	#pop one open and put something in it.
	browser.file_field(:name,"file3").set($htmlRoot + "fileupload.html")	
	#click the upload button
	browser.button(:name,"upload").click

	assert(browser.text.include?("PASS"))	
    end

    def test_iterator
        gotoPage()
        assert_equal(6, browser.file_fields.length)
        arrFileFields = browser.file_fields
        assert_equal("file1", arrFileFields[1].name)
        assert_equal("file2", arrFileFields[2].id)
        assert_equal("disabled", arrFileFields[3].name)
        assert_equal("file3", arrFileFields[4].name)
        assert_equal("beforetest", arrFileFields[5].name)
        assert_equal("aftertest", arrFileFields[6].name)
        arrFileFields.each do |fileField|
            assert_equal("file", fileField.type)
        end
    end

end

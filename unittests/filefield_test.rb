# feature tests for file Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_FileField < Test::Unit::TestCase
  include Watir
  
  def goto_page
    use_page "fileupload.html"
  end
  
  def test_file_field_Exists
    goto_page

    # test for existance of 4 file area
    assert($ie.file_field(:name,"file1").exists?)
    assert($ie.file_field(:id,"file2").exists?)

    # test for missing 
    assert(!$ie.file_field(:name, "missing").exists?)   
    assert(!$ie.file_field(:name,"totallybogus").exists?)

    # pop one open and put something in it.
    file = $htmlRoot + "fileupload.html"
    file.gsub! 'file://', ''
    file.gsub! '/', '\\'
    $ie.file_field(:name,"file1").set(file)	
    assert_equal file, $ie.file_field(:name,"file1").value

    # click the upload button
    $ie.button(:name,"upload").click
    assert($ie.text.include?("PASS"))	
  end
  
  def test_iterator
    goto_page
    assert_equal(6, $ie.file_fields.length)
  end
  
end

# feature tests for file Fields

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_FileDownloadLink < Test::Unit::TestCase
  tags :must_be_visible, :creates_windows
  include Watir
  
  def setup
    goto_page "filedownload.html"
    @file = File.expand_path(File.dirname(__FILE__) + '/test_file_download.bin')
    @file.gsub!('/', '\\')
  end

  def teardown
    Watir::Wait.until {File.exists?(@file)}
    File.delete @file
  end

  def test_file_field_Exists
    # test for existance of 4 file area
    assert(browser.file_download_link(:text,"file").exists?)
    assert(browser.file_download_link(:url,/download_me\.bin/).exists?)

    # test for missing 
    assert_false(browser.file_download_link(:text, "missing").exists?)

    # pop one open and put something in it.
    browser.file_download_link(:text, "file").set @file

  end
  
end

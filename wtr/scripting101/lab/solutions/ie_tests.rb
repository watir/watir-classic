require 'win32ole'
require 'test/unit'

class TC_Ie < Test::Unit::TestCase

  def setup
    @ie = WIN32OLE.new ("InternetExplorer.Application")
    @ie.visible = TRUE
  end
  def teardown
    @ie.quit
    sleep .5 # to avoid errors; not sure why
  end

  def test_start
    @ie.navigate("http://c2.com")
    sleep .5 # so we can see it
  end

  def test_start2
    @ie.invoke("navigate", "http://c2.com")
    sleep .5
  end

  def test_gohome
    @ie.gohome
    sleep .5
  end

  def test_document
    @ie.gohome # must have a page loaded to get a document
    sleep .5
    print @ie.document.to_s
    print
    
  end

end

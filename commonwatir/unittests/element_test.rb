$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Elements < Test::Unit::TestCase
  include Watir::Exception
  location __FILE__

  def setup
    @html_dir = "#{File.dirname(__FILE__)}/html"
    uses_page "elements.html"
  end

  def test_objects_in_element_exists
    assert browser.div(:id => "buttons1").exists?
    assert browser.button(:name => "b1").exists?    
    assert browser.div(:id => "buttons1").button(:name => "b1").exists?

    assert !browser.div(:id => "buttons1").button(:id => 'doesntexist').exists?
    assert !browser.div(:id => "doesntexist").button(:name => "b1").exists?
    assert !browser.div(:id => "doesntexist").button(:id => "doesntexist").exists?
  end

end


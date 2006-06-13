# feature tests for Links with multiple attributes
# revision: $Revision: 1009 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Links_Multi < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto $htmlRoot + 'links_multi.html'
  end
  
  def test_existing
    assert_match(/not.html/, $ie.link(:class_name, 'Papa').href)
    assert_match(/mama.html/, $ie.link(:text, 'click').href)
  end
  
  def test_class_alias
    assert_match(/not.html/, $ie.link(:class, 'Papa').href)
  end

  def test_hash_syntax
    assert_match(/not.html/, $ie.link(:class_name => 'Papa').href)
    assert_match(/mama.html/, $ie.link(:text => 'click').href)
  end
  
  def test_class_and_text
    assert_match(/papa.html/, $ie.link(:class => 'Papa', :text => 'click').href)
  end
  
  def test_class_and_index
    assert_match(/papa.html/, $ie.link(:class => 'Papa', :index => 2).href)
  end  
  
end
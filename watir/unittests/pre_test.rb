# feature tests for Pre
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Pre < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "pre.html")
  end
  
  def test_Pre_Count
    assert( $ie.pres.length == 3 )
  end
  
  def test_Pre_Exists
    assert_false( $ie.pre( :id, 'missingPre' ).exists? )
    assert_false( $ie.pre( :index, 33 ).exists? )
    
    assert( $ie.pre( :id, '1' ).exists? )
    assert( $ie.pre( :id, /[3-9]/ ).exists? )
    
    assert_false( $ie.pre( :id, /missing_pre/ ).exists? )
    
    assert( $ie.pre( :index, 1 ).exists? )
    assert( $ie.pre( :index, 2 ).exists? )
    assert( $ie.pre( :index, 3 ).exists? )
    
    assert( $ie.pre( :name, '3' ).exists? )
    assert_false( $ie.pre( :name, "name_missing" ).exists? )
  end
  
  def test_simple_access
    pre = $ie.pre( :index, 1 )
    assert( pre.text.include?( "simple pre space" ) )
    assert_false( pre.text.include?( "A second block" ) )
    
    assert( pre.html.include?( "id=1 name=\"1\"" ) )
    
    pre = $ie.pre( :index, 2 )
    assert( pre.text.include?( "A second block" ) )
    assert_false( pre.text.include?( "this is the last block" ) )
    
    pre = $ie.pre( :index, 3 )
    assert( pre.text.include?( "continue    to work" ) )
    assert_false( pre.text.include?( "Pre Tag Test" ) )
    
  end
  
end

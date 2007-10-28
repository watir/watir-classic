# feature tests for Pre
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Pre < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "pre.html")
  end
  
  def test_Pre_Count
    assert( $ff.pres.length == 3 )
  end
  
  def test_Pre_Exists
    assert(! $ff.pre( :id, 'missingPre' ).exists? )
    assert(! $ff.pre( :index, 33 ).exists? )
    
    assert( $ff.pre( :id, '1' ).exists? )
    assert( $ff.pre( :id, /[3-9]/ ).exists? )
    
    assert(! $ff.pre( :id, /missing_pre/ ).exists? )
    
    assert( $ff.pre( :index, 1 ).exists? )
    assert( $ff.pre( :index, 2 ).exists? )
    assert( $ff.pre( :index, 3 ).exists? )
    
    assert( $ff.pre( :name, '3' ).exists? )
    assert(! $ff.pre( :name, "name_missing" ).exists? )
  end
  
  def test_simple_access
    pre = $ff.pre( :index, 1 )
    assert( pre.text.include?( "simple pre space" ) )
    assert(! pre.text.include?( "A second block" ) )
    
    pre = $ff.pre( :index, 2 )
    assert( pre.text.include?( "A second block" ) )
    assert(! pre.text.include?( "this is the last block" ) )
    
    pre = $ff.pre( :index, 3 )
    assert( pre.text.include?( "continue    to work" ) )
    assert(! pre.text.include?( "Pre Tag Test" ) )
    
  end
  
end


class TC_Pres_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showPres
    $ff.goto($htmlRoot + "pre.html")
    $stdout = @mockout
    $ff.showPres
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 3 pres
pre:     id: 1
       name: 1
      index: 1
pre:     id: 2
       name: 2
      index: 2
pre:     id: 3
       name: 3
      index: 3
END_OF_MESSAGE
  end
end

# feature tests for Pre
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Pre < Test::Unit::TestCase
  
  
  def setup
    goto_page("pre.html")
  end
  
  def test_Pre_Count
    assert( browser.pres.length == 3 )
  end
  
  def test_Pre_Exists
    assert(! browser.pre( :id, 'missingPre' ).exists? )
    assert(! browser.pre( :index, 33 ).exists? )
    
    assert( browser.pre( :id, '1' ).exists? )
    assert( browser.pre( :id, /[3-9]/ ).exists? )
    
    assert(! browser.pre( :id, /missing_pre/ ).exists? )
    
    assert( browser.pre( :index, 1 ).exists? )
    assert( browser.pre( :index, 2 ).exists? )
    assert( browser.pre( :index, 3 ).exists? )
    
    assert( browser.pre( :name, '3' ).exists? )
    assert(! browser.pre( :name, "name_missing" ).exists? )
  end
  
  def test_simple_access
    pre = browser.pre( :index, 1 )
    assert( pre.text.include?( "simple pre space" ) )
    assert(! pre.text.include?( "A second block" ) )
    
    pre = browser.pre( :index, 2 )
    assert( pre.text.include?( "A second block" ) )
    assert(! pre.text.include?( "this is the last block" ) )
    
    pre = browser.pre( :index, 3 )
    assert( pre.text.include?( "continue    to work" ) )
    assert(! pre.text.include?( "Pre Tag Test" ) )
    
  end
  
end


class TC_Pres_Display < Test::Unit::TestCase
  include MockStdoutTestCase

  tag_method :test_showPres, :fails_on_ie
  def test_showPres
    goto_page("pre.html")
    $stdout = @mockout
    browser.showPres
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

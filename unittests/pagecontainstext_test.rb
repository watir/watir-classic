# feature tests for IE::contains_text
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_contains_text < Test::Unit::TestCase
  
  def setup
    use_page "textsearch.html"
  end        
  
  def test_text_found
    assert($ie.contains_text('slings and arrows of outrageous fortune'))
  end
  
  def test_text_not_found
    assert(!$ie.contains_text('So are they all, all honourable men'))
  end
  
  def test_regexp_found
    assert($ie.contains_text(/bodkin.*fardels/))
  end
  
  def test_regexp_not_found
    assert(!$ie.contains_text(/winding.*watch.*wit/))
  end
  
  def test_match_regexp_found
    $~ = $ie.contains_text(/Messages ([0-9]+)/)
    assert_equal('42', $1)
  end
  
  def test_bad_search_argument
    assert_raises(ArgumentError) do
      $ie.contains_text
    end
    assert_raises(ArgumentError) do
      $ie.contains_text(nil)
    end
    assert_raises(ArgumentError) do
      $ie.contains_text(42)
    end
  end
  
end

class TC_contains_text_in_new_ie < Test::Unit::TestCase
  def setup
    @ie = Watir::IE.new
  end
  def test_nothing_raised
    assert_nothing_raised {@ie.contains_text ''}
  end
  def teardown
    @ie.close
  end
end

class TC_contains_text_in_frame < Test::Unit::TestCase
  def setup
    use_page "frame_links.html"
  end        
  def test_in_frame
    assert $ie.frame('linkFrame').contains_text('The button is really a link')
  end
end
# feature tests for IE::pageContainsText
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_PageContainsText < Test::Unit::TestCase
    include Watir

    def setup
        $ie.goto($htmlRoot + "textsearch.html")
    end        
    
    def test_text_found
        assert($ie.pageContainsText('slings and arrows of outrageous fortune'))
    end

    def test_text_not_found
        assert_false($ie.pageContainsText('So are they all, all honourable men'))
    end
    
    def test_regexp_found
        assert($ie.pageContainsText(/bodkin.*fardels/))
    end
    
    def test_regexp_not_found
        assert_false($ie.pageContainsText(/winding.*watch.*wit/))
    end
                
    def test_match_regexp_found
    	$~ = $ie.pageContainsText(/Messages ([0-9]+)/)
        assert_equal('42', $1)
    end

    def test_bad_search_argument
        assert_raises(ArgumentError) do
            $ie.pageContainsText()
        end
        assert_raises(MissingWayOfFindingObjectException) do
            $ie.pageContainsText(nil)
        end
        assert_raises(MissingWayOfFindingObjectException) do
            $ie.pageContainsText(42)
        end
    end
                        
end

    
# feature tests for attaching to existing IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ExistingWindow< Test::Unit::TestCase
    include Watir

    def goto_page(page)
      $ie.goto($htmlRoot + page)
    end

    def test_ExistingWindow
       goto_page 'buttons1.html'
       ie3=nil

       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:title , "missing") }
       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:title , /missing/) }

       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:url , "missing") }
       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:url , /missing/) }

       ie3 = IE.attach(:title , /buttons/i )
       assert_equal( "Test page for buttons" , ie3.title)
       ie3=nil

       ie3 = IE.attach(:title , "Test page for buttons" )
       assert_equal( "Test page for buttons" , ie3.title)
       ie3=nil

       ie3 = IE.attach(:url, /buttons1.html/ )
       assert_equal( "Test page for buttons" , ie3.title)
       ie3=nil

       #hard to test :url with explicit text
    end

end


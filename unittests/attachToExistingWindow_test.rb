# tests for attaching to existing IE windows
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_ExistingWindow< Test::Unit::TestCase
    include Watir

    def test_ExistingWindow
       e = $htmlRoot + 'buttons1.html'
       $ie.goto(e)
       ie3=nil

       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:title , "missing") }
       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:title , /missing/) }

       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:url , "missing") }
       assert_raises( NoMatchingWindowFoundException ) { ie3 = IE.attach(:url , /missing/) }


       ie3 = IE.attach(:title , /buttons/i )
       assert( "Test page for buttons" , ie3.title)
       ie3=nil


       ie3 = IE.attach(:title , "Test page for buttons" )
       assert( "Test page for buttons" , ie3.title)
       ie3=nil

       ie3 = IE.attach(:url, /buttons1.html/ )
       assert( "Test page for buttons" , ie3.title)
       ie3=nil

       # this is difficult to test, as the url gets munged
       #ie3 = IE.new( nil , :url, $htmlRoot + "buttons1.html" )
       #assert( "Test page for buttons" , ie3.title)
       #ie3=nil



=begin
       gotoPage( 'buttons1.html')
       gotoPage( 'checkboxes1.html')
       assert($ie.title , "Test page for Check Boxes") 



       $ie.back
       assert($ie.title , "Test page for buttons")   

       $ie.forward
       assert($ie.title , "Test page for Check Boxes")   

       $ie.checkBox(:name , "box1").set
       assert($ie.checkBox(:name, "box1").isSet?)   
 
       $ie.refresh
       # Not sure how we test this. Text fields and checkboxes dont get reset if you click the browser refresh button

=end
    end

    

end


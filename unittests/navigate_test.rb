# tests for navigation
# revision: $Revision$

require 'setup'

class TC_Frames < Test::Unit::TestCase


   
    def gotoPage( a )

       $ie.goto($htmlRoot + a)
    end


    def test_navigation
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


    end

    

end


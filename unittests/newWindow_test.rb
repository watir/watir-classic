# Test for new windows
# revision: $Revision$

require 'unittests/setup'

class TC_Links < Test::Unit::TestCase
   
    def test_newWindows 
        $ie.captureEvents
        $ie.goto($htmlRoot + 'links1.html')
        $ie.link(:index ,5).click
        ie2 = $ie.newWindow
        if ie2 == nil
          puts "Couldnt get newly opened window."
        else
          ie2.link(:index ,5).click
        end
    end
end
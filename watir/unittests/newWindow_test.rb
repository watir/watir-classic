# feature Test for new windows (broken)
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Links < Test::Unit::TestCase
    include Watir
   
    def xtest_newWindows 
        $ie.goto($htmlRoot + 'links1.html')
        $ie.capture_events
        $ie.link(:index, 5).click
        ie2 = $ie.newWindow
        assert_equal('TextArea-MultiLine', ie2.title)
    end
end
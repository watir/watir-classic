require 'timeclock/client/html/FirstJobCreationPageSketch'
require 'timeclock/client/tutil'

module Timeclock
  module Client
    module Html

      class FirstJobCreationPageSketchTests < ClientTestCase
        def test_sketch_contents
          sketch = FirstJobCreationPageSketch.new(@session_id)
          xhtml = sketch.to_xhtml
          
          
          assert_match(/action="job"/, xhtml)
          assert_match(/input .*name="name".*type="text"/,
                       xhtml)
      end

      
      end
    end
  end
end

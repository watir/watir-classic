require 'timeclock/client/html/LoginPageSketch'
require 'timeclock/client/tutil'

module Timeclock
  module Client
    module Html

      class LoginPageSketchTests < ClientTestCase

        def test_required_structure
          sketch = LoginPageSketch.new
          xhtml = sketch.to_xhtml

          assert_match(/Timeclock Login Page/, xhtml)
          assert_match(/Welcome to Timeclock. Please log in./, xhtml)
        end

      end
    end
  end
end

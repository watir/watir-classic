require 'timeclock/client/html/BadRequestPageSketch'
require 'timeclock/client/tutil'

module Timeclock
  module Client
    module Html

      class BadRequestPageSketchTests < ClientTestCase

        ## Many of these are tested indirectly.
        
        def test_unknown_command
          sketch = BadRequestPageSketch.unknown_request('foo', 'some details')
          xhtml = sketch.to_xhtml
          
          assert_match(/unknown request 'foo'/, xhtml)
          assert_match(/Please include this detail: 'some details'/, xhtml)
          assert_match(/Please also describe the page you came from and what you did to get to this page. Thank you./, xhtml)
      end

        def test_unknown_session
          sketch = BadRequestPageSketch.unknown_session
          xhtml = sketch.to_xhtml
          
          assert_match(/Your session no longer exists./, xhtml)
          assert_match(/Please also describe the page you came from and what you did to get to this page. Thank you./, xhtml)
        end

        def test_exception
          begin
            raise Exception, 'hi'
          rescue Exception => ex
            sketch = BadRequestPageSketch.exception(ex)
            xhtml = sketch.to_xhtml
            assert_match(/An exception was raised: Exception\('hi'\)/,
                         xhtml)
            # there's a stack trace.
            assert_match(/test_exception/, xhtml)
          end
        end            
      end
    end
  end
end

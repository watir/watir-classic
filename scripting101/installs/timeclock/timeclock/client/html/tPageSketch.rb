require 'timeclock/client/html/PageSketch'
require 'timeclock/client/tutil.rb'

module Timeclock
  module Client
    module Html

      class PageSketchTests < ClientTestCase

        def test_to_xhtml
          sketch = PageSketch.new('test title')
          xhtml = sketch.to_xhtml

          expected = %Q{.<!DOCTYPE html PUBLIC
                        .           "-//W3C//DTD XHTML 1.0 Transitional//EN"
                        .           "DTD/xhtml1-transitional.dtd"	>
                        .<html>
                        .  <head>
                        .    <title>test title</title>
                        .  </head>
                        .  <body>
                        .    <h1><p align="center">
                        .      test title
                        .    </p></h1>
                        .  </body>
                        .</html>}

          assert_message(expected, xhtml)
        end

      end
    end
  end
end

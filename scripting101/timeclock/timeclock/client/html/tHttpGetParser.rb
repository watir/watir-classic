require 'timeclock/client/html/HttpGetParser'
require 'timeclock/client/tutil.rb'

module Timeclock
  module Client
    module Html

      class HttpGetParserTests < Test::Unit::TestCase

        # Note: we assume no need for error handling.

        def test_http_null_request
          request = HttpGetParser.new.parse("GET / HTTP/1.1")
          assert_equal("", request.name)
          assert_equal({}, request.args)
        end

        def test_http_argless_request
          request = HttpGetParser.new.parse("GET  /login HTTP/1.0")
          
          assert_equal("login", request.name)
          assert_equal({}, request.args)
        end

        def test_http_argfull_request
          request = HttpGetParser.new.parse("GET /restart?name=glenn HTTP/1.0")
          assert_equal("restart", request.name)
          assert_equal({"name"=>"glenn"}, request.args)

          # two args
          request = HttpGetParser.new.parse("GET /restart?first=glenn&last=kowack HTTP/1.0")
          assert_equal("restart", request.name)
          assert_equal({"first"=>"glenn", "last"=>"kowack"},
                       request.args)

        end

        def test_http_empty_argument
          request = HttpGetParser.new.parse("GET /login?email=&action=hi HTTP/1.0")
          assert_equal("login", request.name)
          assert_equal({"email"=>"", "action"=>'hi'}, request.args)

          # Try it with empty argument last in list.
          request = HttpGetParser.new.parse("GET /login?action=hi&email= HTTP/1.0")
          assert_equal("login", request.name)
          assert_equal({"email"=>"", "action"=>'hi'}, request.args)
        end

        def test_http_escaped_args
          line = "GET /cmd?arg=+%26+%24+%22&foo+bar=%3F+%2B HTTP/Who cares?"
          request = HttpGetParser.new.parse(line)

          assert_equal('cmd', request.name)
          assert_equal({'arg'=>' & $ "', 'foo bar'=>'? +'},
                       request.args)
        end

      end
    end
  end
end

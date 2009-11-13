# feature tests for Firefox Browser
# revision: $Revision: 1.0 $
 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
 
class TC_FirefoxBrowser < Test::Unit::TestCase
 
    def setup()
    end
    
    def test_close_all_firefox_browsers
        ff1 = Watir::Browser.new
        ff2 = Watir::Browser.new
        ff3 = Watir::Browser.new
        ff1.close_all
        result = true
        # After closing all the browsers we'll not be able to connect to the JSSh. So just check
        begin
            jssh_socket = TCPSocket::new(MACHINE_IP, "9997")
            result = false
        rescue
            result = true
        end
        assert_true(result)
    end
 
    def teardown()
        browser = Watir::Browser.new
    end
end
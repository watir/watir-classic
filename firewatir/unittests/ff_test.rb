# feature tests for Firefox Browser
 
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'
 
class TC_FirefoxBrowser < Test::Unit::TestCase
 
    def setup()
    end
    
    def close_all_firefox_browsers
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
 
    def test_status
        # Create the browser as all browsers are closed in above test case.
        #browser = Watir::Browser.new
        goto_page("radioButtons1.html")
        status = browser.status
        assert_equal(status, "Done")
    end
    
    def test_element_html
	  # Create the browser as all browsers are closed in above test case.
        #browser = Watir::Browser.new
        goto_page("buttons1.html")
        html = browser.button(:id, "b7").html
        assert_equal(html, "Click Me2")
    end

    def teardown()
        
    end
end
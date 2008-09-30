# feature tests for Links
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Links_XPath < Test::Unit::TestCase
    
    def setup()
        goto_page("links1.html")
    end
    
    def xtest_new_link_exists
        assert(exists?{browser.link(:xpath , "//a[contains(.,'test1')]")})
        assert(exists?{browser.link(:xpath, "//a[contains(., /TEST/i)]")})   
        assert_false(exists?{browser.link(:xpath , "//a[contains(.,'missing')]")})
        assert_false(exists?{browser.link(:xpath, "//a[contains(., /miss/)]")})   
    end
        
    tag_method :test_element_by_xpath_class, :fails_on_ie
    def test_element_by_xpath_class
        # TODO: If element is not present this should return null
        #element = browser.element_by_xpath("//a[contains(., /miss/)]")
        #assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
        #element = browser.element_by_xpath("//a[contains(.,'missing')]")
        #assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
        element = browser.element_by_xpath("//a[contains(., /TEST/i)]")
        assert_class(element, 'Link')
        element = browser.element_by_xpath("//a[contains(.,'test1')]")
        assert_class(element, 'Link')
    end

    def test_element_by_xpath_behavior
      # TODO implement this, acquiring objects through element_by_xpath and 
      # then testing their properties to see if they behave normally, as if 
      # they had been created with browser.link
    end
    
    def test_Link_Exists
       assert(browser.link(:xpath , "//a[contains(.,'test1')]").exists?)
       assert(browser.link(:xpath, "//a[contains(., /TEST/i)]").exists?)   
       assert_false(browser.link(:xpath , "//a[contains(.,'missing')]").exists?)

       assert_false(browser.link(:xpath , "//a[@url='alsomissing.html']").exists?)

       assert(browser.link(:xpath , "//a[@id='link_id']").exists?)
       assert_false(browser.link(:xpath , "//a[@id='alsomissing']").exists?)

       assert(browser.link(:xpath , "//a[@name='link_name']").exists?)
       assert_false(browser.link(:xpath , "//a[@name='alsomissing']").exists?)
       assert(browser.link(:xpath , "//a[@title='link_title']").exists?)

    end

    def test_Link_click
        browser.link(:xpath , "//a[contains(.,'test1')]").click
        assert( browser.text.include?("Links2-Pass") )
    end
    
    def test_link_properties
            
        assert_match( /links2/ ,browser.link(:xpath , "//a[contains(.,'test1')]").href )
        assert_equal( ""      , browser.link(:xpath , "//a[contains(.,'test1')]").value)
        assert_equal( "test1" , browser.link(:xpath , "//a[contains(.,'test1')]").text )
        assert_equal( ""      , browser.link(:xpath , "//a[contains(.,'test1')]").name )
        assert_equal( ""      , browser.link(:xpath , "//a[contains(.,'test1')]").id )
        #assert_equal( false   , browser.link(:xpath , "//a[contains(.,'test1')]").disabled )  
        assert_equal( ""      , browser.link(:xpath , "//a[contains(.,'test1')]").class_name)
        assert_equal( "link_class_1"      , browser.link(:xpath , "//a[@class='link_class_1']").class_name)
        
        assert_equal( "link_id"   , browser.link(:xpath , "//a[@id='link_id']").id )
        assert_equal( "link_name" , browser.link(:xpath , "//a[@name='link_name']").name )
        
        assert_equal( "" , browser.link(:xpath , "//a[@name='link_name']").title)
        
        assert_equal( "link_title" , browser.link(:xpath , "//a[@title='link_title']").title)
    end 
end


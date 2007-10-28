# feature tests for Links
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Links_XPath < Test::Unit::TestCase
    include FireWatir

    def setup()
        $ff.goto($htmlRoot + "links1.html")
    end
    
    def xtest_new_link_exists
        assert(exists?{$ff.link(:xpath , "//a[contains(.,'test1')]")})
        assert(exists?{$ff.link(:xpath, "//a[contains(., /TEST/i)]")})   
        assert_false(exists?{$ff.link(:xpath , "//a[contains(.,'missing')]")})
        assert_false(exists?{$ff.link(:xpath, "//a[contains(., /miss/)]")})   
    end
        
    def test_element_by_xpath_class
        # TODO: If element is not present this should return null
        #element = $ff.element_by_xpath("//a[contains(., /miss/)]")
        #assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
        #element = $ff.element_by_xpath("//a[contains(.,'missing')]")
        #assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
        element = $ff.element_by_xpath("//a[contains(., /TEST/i)]")
        assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
        element = $ff.element_by_xpath("//a[contains(.,'test1')]")
        assert(element.instance_of?(Link),"element class should be #{Link}; got #{element.class}")
    end

    def test_element_by_xpath_behavior
      # TODO implement this, acquiring objects through element_by_xpath and 
      # then testing their properties to see if they behave normally, as if 
      # they had been created with $ff.link
    end
    
    def test_Link_Exists
       assert($ff.link(:xpath , "//a[contains(.,'test1')]").exists?)
       assert($ff.link(:xpath, "//a[contains(., /TEST/i)]").exists?)   
       assert_false($ff.link(:xpath , "//a[contains(.,'missing')]").exists?)

       assert_false($ff.link(:xpath , "//a[@url='alsomissing.html']").exists?)

       assert($ff.link(:xpath , "//a[@id='link_id']").exists?)
       assert_false($ff.link(:xpath , "//a[@id='alsomissing']").exists?)

       assert($ff.link(:xpath , "//a[@name='link_name']").exists?)
       assert_false($ff.link(:xpath , "//a[@name='alsomissing']").exists?)
       assert($ff.link(:xpath , "//a[@title='link_title']").exists?)

    end

    def test_Link_click
        $ff.link(:xpath , "//a[contains(.,'test1')]").click
        assert( $ff.text.include?("Links2-Pass") )
    end
    
    def test_link_properties
            
        assert_match( /links2/ ,$ff.link(:xpath , "//a[contains(.,'test1')]").href )
        assert_equal( ""      , $ff.link(:xpath , "//a[contains(.,'test1')]").value)
        assert_equal( "test1" , $ff.link(:xpath , "//a[contains(.,'test1')]").text )
        assert_equal( ""      , $ff.link(:xpath , "//a[contains(.,'test1')]").name )
        assert_equal( ""      , $ff.link(:xpath , "//a[contains(.,'test1')]").id )
        #assert_equal( false   , $ff.link(:xpath , "//a[contains(.,'test1')]").disabled )  
        assert_equal( ""      , $ff.link(:xpath , "//a[contains(.,'test1')]").class_name)
        assert_equal( "link_class_1"      , $ff.link(:xpath , "//a[@class='link_class_1']").class_name)
        
        assert_equal( "link_id"   , $ff.link(:xpath , "//a[@id='link_id']").id )
        assert_equal( "link_name" , $ff.link(:xpath , "//a[@name='link_name']").name )
        
        assert_equal( "" , $ff.link(:xpath , "//a[@name='link_name']").title)
        
        assert_equal( "link_title" , $ff.link(:xpath , "//a[@title='link_title']").title)
    end 
end


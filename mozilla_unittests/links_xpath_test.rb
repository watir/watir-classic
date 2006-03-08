# feature tests for Links
# revision: $Revision: 1.2 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_Links_XPath < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "links1.html")
    end
    
    def xtest_new_link_exists
        assert(exists?{$ie.link(:xpath , "//a[contains(.,'test1')]")})
        assert(exists?{$ie.link(:xpath, "//a[contains(., /TEST/i)]")})   
        assert_false(exists?{$ie.link(:xpath , "//a[contains(.,'missing')]")})
        assert_false(exists?{$ie.link(:xpath, "//a[contains(., /miss/)]")})   

    end
    
    def test_Link_Exists
       assert($ie.link(:xpath , "//a[contains(.,'test1')]").exists?)
       assert($ie.link(:xpath, "//a[contains(., /TEST/i)]").exists?)   
       assert_false($ie.link(:xpath , "//a[contains(.,'missing')]").exists?)

       assert_false($ie.link(:xpath , "//a[@url='alsomissing.html']").exists?)

       assert($ie.link(:xpath , "//a[@id='link_id']").exists?)
       assert_false($ie.link(:xpath , "//a[@id='alsomissing']").exists?)

       assert($ie.link(:xpath , "//a[@name='link_name']").exists?)
       assert_false($ie.link(:xpath , "//a[@name='alsomissing']").exists?)
       assert($ie.link(:xpath , "//a[@title='link_title']").exists?)

    end

    def test_Link_click
        $ie.link(:xpath , "//a[contains(.,'test1')]").click
        assert( $ie.text.include?("Links2-Pass") )
    end
    
    def test_link_properties
            
        assert_match( /links2/ ,$ie.link(:xpath , "//a[contains(.,'test1')]").href )
        assert_equal( ""      , $ie.link(:xpath , "//a[contains(.,'test1')]").value)
        assert_equal( "test1" , $ie.link(:xpath , "//a[contains(.,'test1')]").text )
        assert_equal( ""      , $ie.link(:xpath , "//a[contains(.,'test1')]").name )
        assert_equal( ""      , $ie.link(:xpath , "//a[contains(.,'test1')]").id )
        #assert_equal( false   , $ie.link(:xpath , "//a[contains(.,'test1')]").disabled )  
        assert_equal( ""      , $ie.link(:xpath , "//a[contains(.,'test1')]").class_name)
        assert_equal( "link_class_1"      , $ie.link(:xpath , "//a[@class='link_class_1']").class_name)
        
        assert_equal( "link_id"   , $ie.link(:xpath , "//a[@id='link_id']").id )
        assert_equal( "link_name" , $ie.link(:xpath , "//a[@name='link_name']").name )
        
        assert_equal( "" , $ie.link(:xpath , "//a[@name='link_name']").title)
        
        assert_equal( "link_title" , $ie.link(:xpath , "//a[@title='link_title']").title)
    end 
end


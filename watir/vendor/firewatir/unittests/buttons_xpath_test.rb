# feature tests for Buttons
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Buttons_XPath < Test::Unit::TestCase
    include FireWatir
    
    def setup
        $ff.goto($htmlRoot + "buttons1.html")
    end
    
    def test_properties
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").id   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").name   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").disabled   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").type   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").value   }  
        
        assert_equal("b1"  , $ff.button(:xpath, "//input[@id='b2']").name  ) 
        assert_equal("b2"  , $ff.button(:xpath, "//input[@id='b2']").id  ) 
        assert_equal("button"  , $ff.button(:xpath, "//input[@id='b2']").type  ) 
    end
        
    def test_button_using_default
        # since most of the time, a button will be accessed based on its caption, there is a default way of accessing it....
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@value='Missing Caption']").click   }  
        
        $ff.button(:xpath, "//input[@value='Click Me']").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_Button_click_only
        $ff.button(:xpath, "//input[@value='Click Me']").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_button_click
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@value='Missing Caption']").click   }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@id='MissingId']").click   }  
        
        assert_raises(ObjectDisabledException , "ObjectDisabledException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@value='Disabled Button']").click   }  
        
        $ff.button(:xpath, "//input[@value='Click Me']").click
        assert($ff.text.include?("PASS") )
    end
    
    def test_Button_Exists
        assert($ff.button(:xpath, "//input[@value='Click Me']").exists?)   
        assert($ff.button(:xpath, "//input[@value='Submit']").exists?)   
        assert($ff.button(:xpath, "//input[@name='b1']").exists?)   
        assert($ff.button(:xpath, "//input[@id='b2']").exists?)   
        
        assert_false($ff.button(:xpath, "//input[@value='Missing Caption']").exists?)   
        assert_false($ff.button(:xpath, "//input[@name='missingname']").exists?)   
        assert_false($ff.button(:xpath, "//input[@id='missingid']").exists?)   
    end

    def test_element_by_xpath_class
      element = $ff.element_by_xpath("//input[@value='Click Me']")
      assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      element = $ff.element_by_xpath("//input[@value='Submit']")
      assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      element = $ff.element_by_xpath("//input[@name='b1']")
      assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      element = $ff.element_by_xpath("//input[@id='b2']")
      assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      # TODO: If object is not there this should return null
      #element = $ff.element_by_xpath("//input[@value='Missing Caption']")
      #assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      #element = $ff.element_by_xpath("//input[@name='missingname']")
      #assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
      #element = $ff.element_by_xpath("//input[@id='missingid']")
      #assert(element.instance_of?(Button),"element class should be #{Button}; got #{element.class}")
    end
    
    def test_Button_Enabled
        assert($ff.button(:xpath, "//input[@value='Click Me']").enabled?)   
        assert_false($ff.button(:xpath, "//input[@value='Disabled Button']").enabled?)   
        assert_false($ff.button(:xpath, "//input[@name='b4']").enabled?)   
        assert_false($ff.button(:xpath, "//input[@id='b5']").enabled?)   
        
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ff.button(:xpath, "//input[@name='noName']").enabled?  }  
    end
end


# feature tests for Text Fields
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Fields_XPath < Test::Unit::TestCase
    

    def setup()
        goto_page("textfields1.html")
    end

    def test_text_field_exists
       assert(browser.text_field(:xpath , "//input[@name='text1']").exists?)   
       assert_false(browser.text_field(:xpath , "//input[@name='missing']").exists?)   

       assert(browser.text_field(:xpath , "//input[@id='text2']").exists?)   
       assert_false(browser.text_field(:xpath , "//input[@id='alsomissing']").exists?)   

       #assert(browser.text_field(:xpath , "//input[@beforeText='This Text After']").exists? )
       #assert(browser.text_field(:xpath , "//input[@afterText='This Text Before']").exists? )
    end

    # Not supported by Mozilla
    #def test_text_field_dragContentsTo
    #    browser.text_field(:xpath , "//input[@name='text1']").dragContentsTo(:xpath , "//input[@id='text2']/")
    #    assert_equal(browser.text_field(:xpath , "//input[@name='text1']").value, "" ) 
    #    assert_equal(browser.text_field(:xpath , "//input[@id='text2']").value, "goodbye allHello World" ) 
    #end

    def test_text_field_VerifyContents
       assert(browser.text_field(:xpath , "//input[@name='text1']").verify_contains("Hello World") )  
       assert(browser.text_field(:xpath , "//input[@name='text1']").verify_contains(/Hello\sW/ ) )  
       assert_false(browser.text_field(:xpath , "//input[@name='text1']").verify_contains("Ruby") )  
       assert_false(browser.text_field(:xpath , "//input[@name='text1']").verify_contains(/R/) )  
       assert_raises(UnknownObjectException) {   browser.text_field(:xpath , "//input[@name='NoName']").verify_contains("No field to get a value of") }  

       assert(browser.text_field(:xpath , "//input[@id='text2']").verify_contains("goodbye all") )  
       assert_raises(UnknownObjectException) {   browser.text_field(:xpath , "//input[@id='noID']").verify_contains("No field to get a value of") }  
    end

    def test_text_field_enabled
       assert_false(browser.text_field(:xpath , "//input[@name='disabled']").enabled? )  
       assert(browser.text_field(:xpath , "//input[@name='text1']").enabled? )  
       assert(browser.text_field(:xpath , "//input[@id='text2']").enabled? )  
    end

    def test_text_field_readOnly
       assert_false(browser.text_field(:xpath , "//input[@name='disabled']").readonly? )  
       assert(browser.text_field(:xpath , "//input[@name='readOnly']").readonly? )  
       assert(browser.text_field(:xpath , "//input[@id='readOnly2']").readonly? )  
    end

    def test_text_field_value()
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='missing_field']").append("Some Text") }  
         assert_equal(  "Hello World" , browser.text_field(:xpath , "//input[@name='text1']").value )  
    end

    def build_to_s_regex(lhs, rhs)
        Regexp.new("^#{lhs}: +#{rhs}$")
    end

    def test_text_field_Append
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@id='readOnly2']").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='disabled']").append("Some Text") }  
         assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='missing_field']").append("Some Text") }  

         browser.text_field(:xpath , "//input[@name='text1']").append(" Some Text")
         assert_equal(  "Hello World Some Text" , browser.text_field(:xpath , "//input[@name='text1']").value )  
    end


    def test_text_field_Clear
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@id='readOnly2']").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='disabled']").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='missing_field']").append("Some Text") }  

         browser.text_field(:xpath , "//input[@name='text1']").clear()
         assert_equal(  "" , browser.text_field(:xpath , "//input[@name='text1']").value )  
    end

    def test_text_field_Set
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@id='readOnly2']").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='disabled']").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   browser.text_field(:xpath , "//input[@name='missing_field']").append("Some Text") }  

         browser.text_field(:xpath , "//input[@name='text1']").set("FireWatir Firefox Controller")
         assert_equal(  "FireWatir Firefox Controller" , browser.text_field(:xpath , "//input[@name='text1']").value )  
    end

    tag_method :test_JS_Events, :fails_on_ie
    def test_JS_Events
        browser.text_field(:xpath , "//input[@name='events_tester']").set('p')

        # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
        assert_equal( "keypresskeydownkeypresskeyup" , browser.text_field(:xpath , "//textarea[@name='events_text']").value.gsub("\n" , "")  )
        browser.button(:xpath , "//input[@value = 'Clear Events Box']").click
        browser.text_field(:xpath , "//input[@name='events_tester']").set('ab')

        # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
        assert_equal( "keypresskeydownkeypresskeyupkeydownkeypresskeyup" , browser.text_field(:xpath , "//textarea[@name='events_text']").value.gsub("\n" , "") )
    end

    def test_password
        browser.text_field(:xpath , "//input[@name='password1']").set("secret")
        assert( 'secret' , browser.text_field(:xpath , "//input[@name='password1']").value )

        browser.text_field(:xpath , "//input[@id='password1']").set("top_secret")
        assert( 'top_secret' , browser.text_field(:xpath , "//input[@id='password1']").value )
    end

end

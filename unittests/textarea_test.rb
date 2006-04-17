# feature tests for TextArea Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_TextArea < Test::Unit::TestCase
    include Watir

    def gotoPage()
        $ie.goto($htmlRoot + "textArea.html")
    end

    def test_textarea_field_exists
        gotoPage()
        #test for existance of 4 text area
        assert($ie.text_field(:name,"txtMultiLine1").exists?)
        assert($ie.text_field(:name,"txtMultiLine2").exists?)
        assert($ie.text_field(:name,"txtMultiLine3").exists?)
        assert($ie.text_field(:name,"txtReadOnly").exists?)
        
        assert($ie.text_field(:id,"txtMultiLine1").exists?)
        assert($ie.text_field(:id,"txtMultiLine2").exists?)
        assert($ie.text_field(:id,"txtMultiLine3").exists?)
        assert($ie.text_field(:id,"txtReadOnly").exists?)
        #test for missing 
        assert_false($ie.text_field(:name, "missing").exists?)   
        assert_false($ie.text_field(:name,"txtMultiLine4").exists?)
    end

    def test_textarea_to_s
        # from a bug reported by Zeljko Filipin
        assert_nothing_raised() { $ie.text_field(:id,"txtMultiLine3").to_s  }
    end

    def test_textarea_field
        gotoPage()

        # test for read only method
        assert_false($ie.text_field(:name, "txtMultiLine1").readonly? )  
        assert($ie.text_field(:name,"txtReadOnly").readonly?)

        # test for enabled? method
        assert_false($ie.text_field(:name, "txtDisabled").enabled? )  
        assert($ie.text_field(:id, "txtMultiLine1").enabled? )  


        t1 = $ie.text_field(:name, "txtMultiLine1")
        assert(t1.verify_contains("Hello World") )  
        assert(t1.verify_contains(/el/) )  
        t2 = $ie.text_field(:name, "txtMultiLine2")
        assert(t2.verify_contains(/IE/))
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.text_field(:name, "NoName").verify_contains("No field to get a value of") }  
        assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.text_field(:id, "noID").verify_contains("No field to get a value of") }  

        assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "txtNone").append("Some Text") }  

        assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "txtReadOnly").append("Some Text") }  
        assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   $ie.text_field(:name, "txtDisabled").append("Some Text") }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

        $ie.text_field(:name, "txtMultiLine1").append(" Some Text")
        assert_equal(  "Hello World Some Text" , $ie.text_field(:name, "txtMultiLine1").getContents )  

        assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "txtReadOnly").append("Some Text") }  
        assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "txtDisabled").append("Some Text") }  
        assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

        $ie.text_field(:name, "txtMultiLine1").set("watir IE Controller")
        assert_equal(  "watir IE Controller" , $ie.text_field(:name, "txtMultiLine1").getContents )  

        assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "txtReadOnly").append("Some Text") }  
        assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "txtDisabled").append("Some Text") }  
        assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

        $ie.text_field(:name, "txtMultiLine2").clear()
        assert_equal(  "" , $ie.text_field(:name, "txtMultiLine2").getContents )  

    end

end
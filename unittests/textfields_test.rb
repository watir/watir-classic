# feature tests for Text Fields
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Fields < Test::Unit::TestCase
    include Watir

    def setup()
        $ie.goto($htmlRoot + "textfields1.html")
    end

    def test_text_field_exists
       assert($ie.text_field(:name, "text1").exists?)   
       assert_false($ie.text_field(:name, "missing").exists?)   

       assert($ie.text_field(:id, "text2").exists?)   
       assert_false($ie.text_field(:id, "alsomissing").exists?)   

        assert($ie.text_field(:beforeText , "This Text After").exists? )
        assert($ie.text_field(:afterText , "This Text Before").exists? )

        assert($ie.text_field(:beforeText , /after/i).exists? )
        assert($ie.text_field(:afterText , /before/i).exists? )

    end

    def test_text_field_dragContentsTo

        $ie.text_field(:name, "text1").dragContentsTo(:id, "text2")
        assert_equal($ie.text_field(:name, "text1").getContents, "" ) 
        assert_equal($ie.text_field(:id, "text2").getContents, "goodbye allHello World" ) 

    end


    def test_text_field_VerifyContents
       assert($ie.text_field(:name, "text1").verify_contains("Hello World") )  
       assert($ie.text_field(:name, "text1").verify_contains(/Hello\sW/ ) )  
       assert_false($ie.text_field(:name, "text1").verify_contains("Ruby") )  
       assert_false($ie.text_field(:name, "text1").verify_contains(/R/) )  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.text_field(:name, "NoName").verify_contains("No field to get a value of") }  

       assert($ie.text_field(:id, "text2").verify_contains("goodbye all") )  
       assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.text_field(:id, "noID").verify_contains("No field to get a value of") }  

    end

    def test_text_field_enabled
       assert_false($ie.text_field(:name, "disabled").enabled? )  
       assert($ie.text_field(:name, "text1").enabled? )  
       assert($ie.text_field(:id, "text2").enabled? )  

    end

    def test_text_field_readOnly
       assert_false($ie.text_field(:name, "disabled").readOnly? )  
       assert($ie.text_field(:name, "readOnly").readOnly? )  
       assert($ie.text_field(:id, "readOnly2").readOnly? )  

    end


    def test_text_field_getContents()
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  
         assert_equal(  "Hello World" , $ie.text_field(:name, "text1").getContents )  
    end

    def test_TextField_to_s
         puts "---------------- To String test -------------"
         puts $ie.text_field(:index , 1).to_s
         puts "---------------- To String test -------------"
         puts $ie.text_field(:index , 2).to_s
         puts "---------------- To String test -------------"
         assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 999 ).to_s}  
    end


    def test_text_field_Append
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   $ie.text_field(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

         $ie.text_field(:name, "text1").append(" Some Text")
         assert_equal(  "Hello World Some Text" , $ie.text_field(:name, "text1").getContents )  

         # may need this to see that it really happened
         #puts "press return to continue"
         #gets 

    end


    def test_text_field_Clear
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

         $ie.text_field(:name, "text1").clear()
         assert_equal(  "" , $ie.text_field(:name, "text1").getContents )  

         # may need this to see that it really happened
         #puts "press return to continue"
         #gets 

    end

    def test_text_field_Set
         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:id, "readOnly2").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "disabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.text_field(:name, "missing_field").append("Some Text") }  

         $ie.text_field(:name, "text1").set("watir IE Controller")
         assert_equal(  "watir IE Controller" , $ie.text_field(:name, "text1").getContents )  

         # may need this to see that it really happened
         #puts "press return to continue"
         #gets 

    end

    def test_text_field_properties

        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 199).value}  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 199).name }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 199).id }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 199).disabled }  
        assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.text_field(:index, 199).type }  

        assert_equal( "Hello World" , $ie.text_field(:index, 1).value )
        assert_equal( "text"        , $ie.text_field(:index, 1).type)
        assert_equal( "text1"       , $ie.text_field(:index, 1).name )
        assert_equal( ""            , $ie.text_field(:index, 1).id )
        assert_equal( false         , $ie.text_field(:index, 1).disabled )

        assert_equal( ""            , $ie.text_field(:index, 2).name )
        assert_equal( "text2"       , $ie.text_field(:index, 2).id )

        assert(  $ie.text_field(:index, 3).disabled )




    end
end
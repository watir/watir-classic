# tests for TextArea Fields
# revision: $Revision$
require 'unittests/setup'

class TC_TextArea < Test::Unit::TestCase



	def gotoPage()
		$ie.goto($htmlRoot + "textArea.html")
	end

	def test_textAreaField_Exists
		gotoPage()
		#test for existance of 4 text area
		assert($ie.textField(:name,"txtMultiLine1").exists?)
		assert($ie.textField(:name,"txtMultiLine2").exists?)
		assert($ie.textField(:name,"txtMultiLine3").exists?)
		assert($ie.textField(:name,"txtReadOnly").exists?)
		
		assert($ie.textField(:id,"txtMultiLine1").exists?)
		assert($ie.textField(:id,"txtMultiLine2").exists?)
		assert($ie.textField(:id,"txtMultiLine3").exists?)
		assert($ie.textField(:id,"txtReadOnly").exists?)
		#test for missing 
		assert_false($ie.textField(:name, "missing").exists?)   
		assert_false($ie.textField(:name,"txtMultiLine4").exists?)
	end
	def test_textAreaField
		gotoPage()
		
		assert_false($ie.textField(:name, "txtMultiLine1").readOnly? )  
		# test for read only method
		assert($ie.textField(:name,"txtReadOnly").readOnly?)
    
		assert_false($ie.textField(:name, "txtDisabled").enabled? )  
		assert($ie.textField(:id, "txtMultiLine1").enabled? )  
		t1 = $ie.textField(:name, "txtMultiLine1")
		assert(t1.verify_contains("Hello World") )  
		assert(t1.verify_contains(/el/) )  
		t2 = $ie.textField(:name, "txtMultiLine2")
		assert(t2.verify_contains(/IE/))
		assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.textField(:name, "NoName").verify_contains("No field to get a value of") }  
		assert_raises(UnknownObjectException , "UnknownObjectException was supposed to be thrown" ) {   $ie.textField(:id, "noID").verify_contains("No field to get a value of") }  

		 assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "txtNone").append("Some Text") }  

         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "txtReadOnly").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectDisabledException   was supposed to be thrown" ) {   $ie.textField(:name, "txtDisabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "UnknownObjectException  was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "txtMultiLine1").append(" Some Text")
         assert_equal(  "Hello World Some Text" , $ie.textField(:name, "txtMultiLine1").getContents )  

         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "txtReadOnly").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "txtDisabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "txtMultiLine1").set("watir IE Controller")
         assert_equal(  "watir IE Controller" , $ie.textField(:name, "txtMultiLine1").getContents )  

         assert_raises(ObjectReadOnlyException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:id, "txtReadOnly").append("Some Text") }  
         assert_raises(ObjectDisabledException   , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "txtDisabled").append("Some Text") }  
         assert_raises(UnknownObjectException  , "ObjectReadOnlyException   was supposed to be thrown" ) {   $ie.textField(:name, "missing_field").append("Some Text") }  

         $ie.textField(:name, "txtMultiLine2").clear()
         assert_equal(  "" , $ie.textField(:name, "txtMultiLine2").getContents )  


	end

end
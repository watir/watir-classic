# feature tests for Text Fields & Labels
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Fields < Test::Unit::TestCase
    include FireWatir
    
    def setup
        $ff.goto($htmlRoot + "textfields1.html")
    end
    
    def test_text_field_exists
        assert($ff.text_field(:name, "text1").exists?)   
        assert_false($ff.text_field(:name, "missing").exists?)   
        
        assert($ff.text_field(:id, "text2").exists?)   
        assert_false($ff.text_field(:id, "alsomissing").exists?)   
        
        # TODO: Need to find an alternative to this in Mozilla
        #assert($ff.text_field(:beforeText, "This Text After").exists? )
        #assert($ff.text_field(:afterText, "This Text Before").exists? )
        
        #assert($ff.text_field(:beforeText, /after/i).exists? )
        #assert($ff.text_field(:afterText, /before/i).exists? )
    end
    
    # Drag Contents to in not supported by Mozilla because onDragStart, onDragEnd etc are not
    # supported in Mozilla
    #def test_text_field_dragContentsTo
        
        #$ff.text_field(:name, "text1").dragContentsTo(:id, "text2")
        #assert_equal($ff.text_field(:name, "text1").value, "") 
        #assert_equal($ff.text_field(:id, "text2").value, "goodbye allHello World") 
    #end
   
    def test_text_field_verify_contains
        assert($ff.text_field(:name, "text1").verify_contains("Hello World"))  
        assert($ff.text_field(:name, "text1").verify_contains(/Hello\sW/))  
        assert_false($ff.text_field(:name, "text1").verify_contains("Ruby"))  
        assert_false($ff.text_field(:name, "text1").verify_contains(/R/))  
        assert_raises(UnknownObjectException) { $ff.text_field(:name, "NoName").verify_contains("No field to get a value of") } 
        
        assert($ff.text_field(:id, "text2").verify_contains("goodbye all") )  
        assert_raises(UnknownObjectException) { $ff.text_field(:id, "noID").verify_contains("No field to get a value of") }          
    end
    
    def test_text_field_enabled
        assert_false($ff.text_field(:name, "disabled").enabled? )  
        assert($ff.text_field(:name, "text1").enabled? )  
        assert($ff.text_field(:id, "text2").enabled? )  
    end
    
    def test_text_field_readonly
        assert_false($ff.text_field(:name, "disabled").readonly? )  
        assert($ff.text_field(:name, "readOnly").readonly? )  
        assert($ff.text_field(:id, "readOnly2").readonly? )  
    end
    
    def test_text_field_get_contents
        assert_raises(UnknownObjectException) { $ff.text_field(:name, "missing_field").append("Some Text") }  
        assert_equal("Hello World", $ff.text_field(:name, "text1").value)  
    end
    
    def test_text_field_to_s
        expected = [
            "name:         text1",
            "type:         text",
            "id:           ",
            "value:        Hello World",
            "disabled:     false", 
            #"style:        ",
            #"  for:        ",
            "read only:    false",
            "max length:   500",
            "length:       0"
        ]
        assert_equal(expected, $ff.text_field(:index, 1).to_s)
        expected[0] = "name:         "
        expected[2] = "id:           text2"
        expected[3] = "value:        goodbye all"
        assert_equal(expected, $ff.text_field(:index, 2).to_s)
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 999).to_s }  
        #puts $ff.text_field(:name, "text1").to_s
        #puts $ff.text_field(:name, "readOnly").to_s
    end
    
    def test_text_field_append
        assert_raises(ObjectReadOnlyException) { $ff.text_field(:id, "readOnly2").append("Some Text") }  
        assert_raises(ObjectDisabledException) { $ff.text_field(:name, "disabled").append("Some Text") }  
        assert_raises(UnknownObjectException) { $ff.text_field(:name, "missing_field").append("Some Text") }  
        
        $ff.text_field(:name, "text1").append(" Some Text")
        assert_equal("Hello World Some Text", $ff.text_field(:name, "text1").value)  
    end
    
    def test_text_field_clear
        $ff.text_field(:name, "text1").clear
        assert_equal("", $ff.text_field(:name, "text1").value)  
    end
    
    def test_text_field_set
        $ff.text_field(:name, "text1").set("FireWatir Firefox Controller")
        assert_equal("FireWatir Firefox Controller" , $ff.text_field(:name, "text1").value)  
    end
    
    def test_text_field_properties
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 199).value }  
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 199).name }  
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 199).id }  
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 199).disabled }  
        assert_raises(UnknownObjectException) { $ff.text_field(:index, 199).type }  
        
        assert_equal("Hello World" , $ff.text_field(:index, 1).value) 
        assert_equal("text"        , $ff.text_field(:index, 1).type)
        assert_equal("text1"       , $ff.text_field(:index, 1).name)
        assert_equal(""            , $ff.text_field(:index, 1).id)
        assert_equal(false         , $ff.text_field(:index, 1).disabled)
        
        assert_equal(""            , $ff.text_field(:index, 2).name)
        assert_equal("text2"       , $ff.text_field(:index, 2).id)
        
        assert($ff.text_field(:index, 3).disabled)
        
        assert_equal("This used to test :afterText", $ff.text_field(:name, "aftertest").title)
        assert_equal("", $ff.text_field(:index, 1).title)
    end
    
    def test_text_field_iterators
        assert_equal(12, $ff.text_fields.length)
        
        # watir is 1 based, so this is the first text field
        assert_equal("Hello World" , $ff.text_fields[1].value)
        assert_equal("text1" , $ff.text_fields[1].name)
        assert_equal("password" , $ff.text_fields[$ff.text_fields.length].type)
        
        index = 1
        $ff.text_fields.each do |t|
            assert_equal($ff.text_field(:index, index).value, t.value) 
            assert_equal($ff.text_field(:index, index).id,    t.id)
            assert_equal($ff.text_field(:index, index).name,  t.name)
            index += 1
        end
        assert_equal(index - 1, $ff.text_fields.length)         
    end
    
    def test_JS_Events
        $ff.text_field(:name, 'events_tester').set('p')
        
        # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
        assert_equal( "keypresskeydownkeypresskeyup" , $ff.text_field(:name , 'events_text').value.gsub("\n" , "")  )
        $ff.button(:value , "Clear Events Box").click
        $ff.text_field(:name , 'events_tester').set('ab')
        
        # the following line has an extra keypress at the begining, as we mimic the delete key being pressed
        assert_equal( "keypresskeydownkeypresskeyupkeydownkeypresskeyup" , $ff.text_field(:name , 'events_text').value.gsub("\n" , "") )

        $ff.text_field(:name, "events_text").set("angrez\nsingh")
        $ff.text_field(:name, "events_text").append("\n") 
        $ff.text_field(:name, "events_text").append("singh") #\\nsupel")
    end
    
    def test_password
        $ff.text_field(:name , "password1").set("secret")
        assert( 'secret' , $ff.text_field(:name , "password1").value )
        
        $ff.text_field(:id , "password1").set("top_secret")
        assert( 'top_secret' , $ff.text_field(:id, "password1").value )
    end
    
    def test_labels_iterator
        assert_equal(3, $ff.labels.length)
        assert_equal('Label For this Field' , $ff.labels[1].innerText.strip )
        assert_equal('Password With ID ( the text here is a label for it )' , $ff.labels[3].innerText )
       
        count=0
        $ff.labels.each do |l|
            count +=1
        end
        assert_equal(count, $ff.labels.length)
    end
    
    def test_label_properties
        assert_raises(UnknownObjectException) { $ff.label(:index,20).innerText } 
        assert_raises(UnknownObjectException) { $ff.label(:index,20).for } 
        assert_raises(UnknownObjectException) { $ff.label(:index,20).name } 
        assert_raises(UnknownObjectException) { $ff.label(:index,20).type } 
        assert_raises(UnknownObjectException) { $ff.label(:index,20).id } 
        
        assert_false($ff.label(:index,10).exists?) 
        assert_false($ff.label(:id,'missing').exists?) 
        assert($ff.label(:index,1).exists?) 
       
        assert_equal("", $ff.label(:index,1).id)
        #assert_false(    $ff.label(:index,1).disabled?) 
        assert(          $ff.label(:index,1).enabled?)
        
        assert_equal("label2", $ff.label(:index,2).id )
       
        assert_equal("Password With ID ( the text here is a label for it )" , $ff.label(:index,3).innerText)
        assert_equal("password1", $ff.label(:index,3).for)
    end
end

class TC_Labels_Display < Test::Unit::TestCase
  include FireWatir
  include MockStdoutTestCase

  def test_showLabels
    $ff.goto($htmlRoot + "textfields1.html")
    $stdout = @mockout
    $ff.showLabels
    assert_equal(<<END_OF_MESSAGE, @mockout)
There are 3 labels
label: name: 
         id: 
        for: text2
      index: 1
label: name: 
         id: label2
        for: readOnly2
      index: 2
label: name: 
         id: 
        for: password1
      index: 3
END_OF_MESSAGE
  end
end

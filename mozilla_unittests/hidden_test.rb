# feature tests for Input Hidden elements
# revision: $Revision: 1.34 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'mozilla_unittests/setup'

class TC_Hidden_Fields < Test::Unit::TestCase
    def setup
        $ie.goto($htmlRoot + "forms3.html")
    end
    
    def test_hidden
        
        # test using index
        assert( $ie.hidden(:index,1).exists? )
        assert( $ie.hidden(:index,2).exists? )
        assert_false( $ie.hidden(:index,3).exists? )
        
        $ie.hidden(:index,1).value = 44
        $ie.hidden(:index,2).value = 55
        
        #$ie.button(:value , "Show Hidden").click
        
        #assert_equal("44"  , $ie.text_field(:name , "vis1").value ) 
        #assert_equal("55"  , $ie.text_field(:name , "vis2").value )
                        
        # test using name and ID
        assert( $ie.hidden(:name ,"hid1").exists? )
        assert( $ie.hidden(:id,"hidden_1").exists? )
        assert_false( $ie.hidden(:name,"hidden_44").exists? )
        assert_false( $ie.hidden(:id,"hidden_55").exists? )
        
        $ie.hidden(:name ,"hid1").value = 444
        $ie.hidden(:id,"hidden_1").value = 555
        
        $ie.button(:value , "Show Hidden").click
        
        assert_equal("444"  , $ie.text_field(:name , "vis1").value ) 
        assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
                
        #  test the over-ridden append method
        $ie.hidden(:name ,"hid1").append("a")
        $ie.button(:value , "Show Hidden").click
        assert_equal("444a"  , $ie.text_field(:name , "vis1").value ) 
        assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
        
        #  test the over-ridden clear method
        $ie.hidden(:name ,"hid1").clear
        $ie.button(:value , "Show Hidden").click
        assert_equal(""  , $ie.text_field(:name , "vis1").value ) 
        assert_equal("555"  , $ie.text_field(:name ,"vis2").value )
        
        # test using a form
        #assert( $ie.form(:name , "has_a_hidden").hidden(:name ,"hid1").exists? )
        #assert( $ie.form(:name , "has_a_hidden").hidden(:id,"hidden_1").exists? )
        #assert_false( $ie.form(:name , "has_a_hidden").hidden(:name,"hidden_44").exists? )
        #assert_false( $ie.form(:name , "has_a_hidden").hidden(:id,"hidden_55").exists? )
        
        #$ie.form(:name , "has_a_hidden").hidden(:name ,"hid1").value = 222
        #$ie.form(:name , "has_a_hidden").hidden(:id,"hidden_1").value = 333
        
        #$ie.button(:value , "Show Hidden").click
        
        #assert_equal("222"  , $ie.text_field(:name , "vis1").value ) 
        #assert_equal("333"  , $ie.text_field(:name ,"vis2").value )
        
        # iterators
        #assert_equal(2, $ie.hiddens.length)
        #count =1
        #$ie.hiddens.each do |h|
        #    case count
        #    when 1
        #        assert_equal( "", h.id)
        #        assert_equal( "hid1", h.name)
        #    when 2
        #        assert_equal( "", h.name)
        #        assert_equal( "hidden_1", h.id)
        #    end
        #    count+=1
        #end
        
        #assert_equal("hid1" , $ie.hiddens[1].name )
        #assert_equal("hidden_1" , $ie.hiddens[2].id )
    end
end
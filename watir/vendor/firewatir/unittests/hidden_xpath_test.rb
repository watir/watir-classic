# feature tests for Input Hidden elements
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Hidden_Fields_XPath < Test::Unit::TestCase
    def setup
        $ff.goto($htmlRoot + "forms3.html")
    end
    
    def test_hidden
        
        # test using name and ID
        assert( $ff.hidden(:xpath,"//input[@type='hidden' and @name='hid1']").exists? )
        assert( $ff.hidden(:xpath,"//input[@type='hidden' and @id='hidden_1']").exists? )
        assert_false( $ff.hidden(:xpath,"//input[@type='hidden' and @name='hidden_44']").exists? )
        assert_false( $ff.hidden(:xpath,"//input[@type='hidden' and @id='hidden_55']").exists? )
        
        $ff.hidden(:xpath,"//input[@type='hidden' and @name='hid1']").value = 444
        $ff.hidden(:xpath,"//input[@type='hidden' and @id='hidden_1']").value = 555
        
        $ff.button(:xpath , "//input[@type='button' and @value='Show Hidden']").click
        
        assert_equal("444"  , $ff.text_field(:xpath , "//input[@name='vis1']").value ) 
        assert_equal("555"  , $ff.text_field(:xpath ,"//input[@name='vis2']").value )
                
        #  test the over-ridden append method
        $ff.hidden(:xpath,"//input[@type='hidden' and @name='hid1']").append("a")
        $ff.button(:xpath , "//input[@type='button' and @value='Show Hidden']").click
        assert_equal("444a"  , $ff.text_field(:xpath , "//input[@name='vis1']").value ) 
        assert_equal("555"  , $ff.text_field(:xpath ,"//input[@name='vis2']").value )
        
        #  test the over-ridden clear method
        $ff.hidden(:xpath,"//input[@type='hidden' and @name='hid1']").clear
        $ff.button(:xpath , "//input[@type='button' and @value='Show Hidden']").click
        assert_equal(""  , $ff.text_field(:xpath , "//input[@name='vis1']").value ) 
        assert_equal("555"  , $ff.text_field(:xpath ,"//input[@name='vis2']").value )
        
        # test using a form
        #assert( $ff.form(:name , "has_a_hidden").hidden(:name ,"hid1").exists? )
        #assert( $ff.form(:name , "has_a_hidden").hidden(:id,"hidden_1").exists? )
        #assert_false( $ff.form(:name , "has_a_hidden").hidden(:name,"hidden_44").exists? )
        #assert_false( $ff.form(:name , "has_a_hidden").hidden(:id,"hidden_55").exists? )
        
        #$ff.form(:name , "has_a_hidden").hidden(:name ,"hid1").value = 222
        #$ff.form(:name , "has_a_hidden").hidden(:id,"hidden_1").value = 333
        
        #$ff.button(:value , "Show Hidden").click
        
        #assert_equal("222"  , $ff.text_field(:name , "vis1").value ) 
        #assert_equal("333"  , $ff.text_field(:name ,"vis2").value )
        
        # iterators
        #assert_equal(2, $ff.hiddens.length)
        #count =1
        #$ff.hiddens.each do |h|
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
        
        #assert_equal("hid1" , $ff.hiddens[1].name )
        #assert_equal("hidden_1" , $ff.hiddens[2].id )
    end
end

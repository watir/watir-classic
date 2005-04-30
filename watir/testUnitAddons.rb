
        
module Test::Unit::Assertions


   def assert_false(boolean, message=nil)
        _wrap_assertion do
          assert_block("assert should not be called with a block.") { !block_given? }
          assert_block(build_message(message, "<?> is not false.", boolean)) { !boolean }
        end
      end


     def compareArrays( expectArray, actualArray)
             result = true
             expectArray.each_with_index do |element,i|
                 #puts "Comparing #{element} #{element.class} with #{actualArray[i]} #{actualArray[i].class} "
                 if element != actualArray[i]
                     result = false
                     break
                 end
            end  

        return result

    end

    def assert_arrayEquals(expectArray, actualArray, message = nil )
        _wrap_assertion do
          assert_block("assert should not be called with a block.") { !block_given? }
          assert_equal(expectArray.length, actualArray.length, "Lengths did not match")

          assert_block("contents are different." ){  compareArrays( expectArray, actualArray)  }
       end  #_wrap
    end #def


    def assert_arrayContains(array, string , message =nil)

         _wrap_assertion do
          assert_block("assert should not be called with a block.") { !block_given? }
          assert(array.kind_of?(Array) , "Must have an array")
          assert(array.include?(string) , message)
        end
    end

end # module test

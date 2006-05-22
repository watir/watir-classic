require 'test/unit'

module Test
  module Unit
    class TestCase
      @@order = :alphabetically
      class << self
        attr_accessor :test_methods, :order
        def test_methods
          @test_methods ||= []
        end
        def order
          @order || @@order
        end
        def default_order= order
          @@order = order
        end
        def sorted_test_methods
          case order
          when :alphabetically:          test_methods.sort
          when :sequentially:            test_methods
          when :reversed_sequentially:   test_methods.reverse
          when :reversed_alphabetically: test_methods.sort.reverse
          else raise ArgumentError, "Execute option not supported: #{@order}"
          end
        end
        def suite
          suite = TestSuite.new(name)
          sorted_test_methods.each do |test|
            catch :invalid_test do
              suite << new(test)
            end
          end
          if (suite.empty?)
            catch :invalid_test do
              suite << new(:default_test)
            end
          end
          return suite
        end
        def method_added id
          name = id.id2name
          test_methods << name if name =~ /^test./
        end
        def execute order
          @order = order
        end
      end
    end
  end
end  

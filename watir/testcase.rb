require 'test/unit'

module Test
  module Unit
    class TestCase
      @@order = :alphabetically
      def self.default_order= order
        @@order = order
      end
      def self.sorted_test_methods
        method_names = @methods.clone
        method_names.delete_if {|method_name| method_name !~ /^test./}
        puts @order, @@order
        @order ||= @@order
        case @order
        when :alphabetically
          method_names.sort
        when :sequentially
          method_names
        when :reversed_sequentially
          method_names.reverse
        when :reversed_alphabetically
          method_names.sort.reverse
        else
          raise ArgumentError, "Execute option not supported: #{@order}"
        end
      end
      def self.suite
        tests = sorted_test_methods
        suite = TestSuite.new(name)
        tests.each do
          |test|
          catch(:invalid_test) do
            suite << new(test)
          end
        end
        if (suite.empty?)
          catch(:invalid_test) do
            suite << new(:default_test)
          end
        end
        return suite
      end
      def self.method_added id
        @methods ||= []
        @methods << id.id2name
        puts "#{self}.#{id.id2name}"
      end
      def self.execute order
        @order = order
        puts "#{self} #{order}"
      end
    end
  end
end  


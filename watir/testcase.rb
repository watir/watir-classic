require 'test/unit'

module Watir
  class TestCase < Test::Unit::TestCase
    @@order = :sequentially
    def initialize name
      throw :invalid_test if name == :default_test && self.class == Watir::TestCase
      super
    end        
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
        suite = Test::Unit::TestSuite.new(name)
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
    public :add_assertion
    
    #
    # Verification methods
    # 
    
    # Log a failure if the boolean is true. The message is the failure
    # message logged.
    # Whether true or false, the assertion count is incremented.
    def verify boolean, message = 'verify failed.'
      add_assertion
      add_failure message, caller unless boolean
    end
    
    def verify_equal expected, actual, message=nil
      full_message = build_message(message, <<EOT, expected, actual)
<?> expected but was
<?>.
EOT
      verify(expected == actual, full_message)
    end
    def verify_match pattern, string, message=nil
      pattern = case(pattern)
      when String
        Regexp.new(Regexp.escape(pattern))
      else
        pattern
      end
      full_message = build_message(message, "<?> expected to be =~\n<?>.", string, pattern)
      verify(string =~ pattern, full_message)
    end
    
  end
end  

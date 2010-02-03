require 'test/unit'
require 'watir/assertions'

module Watir

  # This is a 'test/unit' testcase customized to exeucte test methods sequentially by default
  # and extra assertions
  #
  # Example Usage
  #
  #   require 'watir/testcase'
  #
  #   class MyTestCase < Watir::TestCase
  #
  #     # some helpers
  #     @@browser = nil
  #     def browser
  #       @browser ||= Watir::IE.start(:url, 'http://watir.com/")
  #     end
  #
  #     # TESTS
  #     def test_text
  #       browser.goto "http://watir.com/"
  #       verify_match "Web Application Testing in Ruby", browser.text
  #     end
  #
  #     def test_title
  #       verify browser.title == 'Watir'
  #     end
  #
  #     def test_link
  #       verify_match 'watir.com', browser.link(:text, 'Home').href
  #     end
  #
  #     def test_navigate_to_examples
  #       browser.div(:id, 'nav').link(:text, 'Examples').click
  #     end
  #
  #     def test_url
  #       verify_equal browser.url, 'http://watir.com/examples/'
  #     end
  #
  #   end
  #
  class TestCase < Test::Unit::TestCase
    include Watir::Assertions
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
        when :alphabetically then          test_methods.sort
        when :sequentially then            test_methods
        when :reversed_sequentially then   test_methods.reverse
        when :reversed_alphabetically then test_methods.sort.reverse
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
  end    

end  

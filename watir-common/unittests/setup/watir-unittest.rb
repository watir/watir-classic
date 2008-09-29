$htmlRoot =  "file:///#{$myDir}/html/" 

module Watir::UnitTest
  # navigate the browser to the specified page in unittests/html
  def goto_page page
    new_url = self.class.html_root + page
    browser.goto new_url
  end
  # navigate the browser to the specified page in unittests/html IF the browser is not already on that page.
  def uses_page page # only works with IE
    new_url = self.class.html_root + page
    browser.goto new_url unless browser.url == new_url
  end
  def browser
    $browser
  end

  def assert_class element, klass
    assert_match(Regexp.new(klass, Regexp::IGNORECASE), element.class.to_s, "element class should be #{klass}; got #{element.class}")
  end

  @@filter = []
  class << self
    def filter
      @@filter
    end
    def filter= proc
      @@filter = proc
    end
    # Add a filter that excludes tests matching the provided block
    def filter_out &block
      @@filter << Proc.new do |test| 
        block.call(test) ? false : nil
      end
    end
    def filter_out_tests_tagged tag
      filter_out do |test|
        test.tagged? tag
      end
    end
  end
end

class Test::Unit::TestCase
  include Watir::UnitTest
  include Watir::Exception

  class << self
    def tags *names
      @tags ||= []
      @tags += names
    end
    def tag_method method_name, *tags
      self.method_tags[method_name.to_s] = tags    
    end
    def method_tags
      @method_tags ||= Hash.new []
    end
    def html_root
      return "file:///#{File.expand_path @html_dir}/" if @html_dir
      $htmlRoot
    end
    def location path
      @html_dir = File.join File.dirname(path), 'html'    
    end
  end
  
  def tagged? tag
    self.class.tags.include?(tag) ||
    self.class.method_tags[@method_name].include?(tag)
  end

end


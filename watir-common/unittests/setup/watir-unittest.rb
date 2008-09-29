$htmlRoot =  "file:///#{$myDir}/html/" 

module Watir::UnitTest
  # navigate the browser to the specified page in unittests/html
  def goto_page page
    new_url = self.class.html_root + page
    browser.goto new_url
  end
  # navigate the browser to the specified page in unittests/html IF the browser is not already on that page.
  def uses_page page
    new_url = self.class.html_root + page
    browser.goto new_url unless browser.url == new_url
  end
  def browser
    $browser
  end

  @@filter = []
  class << self
    def filter
      @@filter
    end
    def filter= proc
      @@filter = proc
    end
    def filter_for tag
      @@filter = Proc.new {|test| test.tagged? tag}
    end
    def filter_out tag
      @@filter = Proc.new {|test| ! test.tagged? tag}    
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


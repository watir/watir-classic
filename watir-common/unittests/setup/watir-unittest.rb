$htmlRoot =  "file:///#{$myDir}/html/" 

module Watir::UnitTest
  # navigate the browser to the specified page in unittests/html
  def goto_page page
    new_url = $htmlRoot + page
    browser.goto new_url
  end
  # navigate the browser to the specified page in unittests/html IF the browser is not already on that page.
  def uses_page page
    new_url = $htmlRoot + page
    browser.goto new_url unless browser.url == new_url
  end
  def browser
    $browser
  end

  @@filter = []
  def self.filter
    @@filter
  end
  def self.filter= proc
    @@filter = proc
  end
  def self.filter_for tag
    @@filter = Proc.new {|test| test.tagged? tag}
  end
  def self.filter_out tag
    @@filter = Proc.new {|test| ! test.tagged? tag}    
  end

end

class Test::Unit::TestCase
  include Watir::UnitTest
  def self.tags *names
    @tags ||= []
    @tags += names
  end
  def self.tag_method method_name, *tags
    self.method_tags[method_name.to_s] = tags    
  end
  def self.method_tags
    @method_tags ||= Hash.new []
  end
  def tagged? tag
    self.class.tags.include?(tag) ||
    self.class.method_tags[@method_name].include?(tag)
  end
end
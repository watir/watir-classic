# encoding: utf-8
require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Element" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  describe "#style" do
    it "returns the style attribute if the property exists" do
      el = browser.div(:id, 'best_language')
      el.style("color").should == "red"
      el.style("text-decoration").should == "underline"
      el.style("cursor").should == "pointer"
    end
  end

end

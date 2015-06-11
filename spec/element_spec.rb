# encoding: utf-8
require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Element" do

  before :each do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  describe "#style" do
    it "returns the style attribute if the property exists" do
      el = browser.div(:id, 'best_language')
      expect(el.style("color")).to eq("red")
      expect(el.style("text-decoration")).to eq("underline")
      expect(el.style("cursor")).to eq("pointer")
    end
  end

end

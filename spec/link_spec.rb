# encoding: utf-8
require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Link" do
  before do
    browser.goto(WatirSpec.url_for("non_control_elements.html"))
  end

  context "#exists?" do
    it "finds link by a name" do
      expect(browser.a(:name => "bad_attribute")).to exist
    end
  end
end

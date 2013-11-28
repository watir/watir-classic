# encoding: utf-8
require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Watir.default_timeout" do
  before do
    Watir.default_timeout = 1

    browser.goto WatirSpec.url_for("non_control_elements.html")
  end

  after do
    # Reset the default timeout
    Watir.default_timeout = 30
  end
  
  context "when no timeout is specified" do
    it "is used by Wait#until" do
      expect {
        Wait.until { false }
      }.to raise_error(Watir::Wait::TimeoutError, "timed out after 1 seconds")
    end

    it "is used by Wait#while" do
      expect {
        Wait.while { true }
      }.to raise_error(Watir::Wait::TimeoutError, "timed out after 1 seconds")
    end
  
    it "is used by Element#when_present" do
      expect { browser.div(:id, 'bar').when_present.click }.to raise_error(Watir::Wait::TimeoutError,
        /^timed out after 1 seconds$/
      )
    end

    it "is used by Element#wait_until_present" do
      expect { browser.div(:id, 'bar').wait_until_present }.to raise_error(Watir::Wait::TimeoutError,
        /^timed out after 1 seconds$/
      )
    end

    it "is used by Element#wait_while_present" do
      expect { browser.div(:id, 'content').wait_while_present }.to raise_error(Watir::Wait::TimeoutError,
        /^timed out after 1 seconds$/
      )
    end
  end
end
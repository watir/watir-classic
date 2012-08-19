require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Browser" do
  before do
    browser.goto(WatirSpec.url_for("images.html"))
  end

  context "#attach" do
    it "attaches to existing browser by title" do
      Browser.attach(:title, /Images/).hwnd.should == browser.hwnd
    end

    it "attaches to existing browser by url" do
      Browser.attach(:url, /images\.html/).hwnd.should == browser.hwnd
    end

    it "attaches to existing browser by handle" do
      Browser.attach(:hwnd, browser.hwnd).hwnd.should == browser.hwnd
    end

    it "fails with an error if specified browser was not found" do
      begin
        original_timeout = browser.class.attach_timeout
        browser.class.attach_timeout = 0.1

        expect {
          Browser.attach(:title, "not-existing-window")
        }.to raise_error(NoMatchingWindowFoundException)
      ensure
        browser.class.attach_timeout = original_timeout
      end
    end
  end
end

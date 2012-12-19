# encoding: utf-8
require File.expand_path("watirspec/spec_helper", File.dirname(__FILE__))

describe "Frame" do

  before :each do
    browser.goto(WatirSpec.url_for("frames.html"))
  end

  it "handles clicking elements without waiting" do
    browser.frame(:id, "frame_1").text_field(:name, 'senderElement').value.should == 'send_this_value'
    browser.frame(:id, "frame_2").text_field(:name, 'recieverElement').value.should == 'old_value'
    browser.frame(:id, "frame_1").button(:id, 'send').click_no_wait
    browser.frame(:id, "frame_2").text_field(:name, 'recieverElement').value.should == 'old_value'
    browser.frame(:id, "frame_2").text_field(:name => 'recieverElement', :text => 'send_this_value').wait_until_present(10).should_not raise_error(Watir::Wait::TimeoutError)
  end

end

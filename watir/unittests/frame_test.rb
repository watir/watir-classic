# feature tests for Frames

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
  include Watir::Exception

  def setup
    goto_page "frame_buttons.html"
  end

  def test_frame_no_what
    assert_raises(UnknownObjectException) { browser.frame(:name => "missingFrame").button(:id, "b2").enabled?  }
    assert_raises(UnknownObjectException) { browser.frame(:name => "buttonFrame2").button(:id, "b2").enabled?  }
    assert(browser.frame(:name => "buttonFrame").button(:id, "b2").enabled?)
    assert_false(browser.frame(:name => "buttonFrame").button(:caption, "Disabled Button").enabled?)
  end

  def test_frame_using_name
    assert_raises(UnknownObjectException) { browser.frame(:name, "missingFrame").button(:id, "b2").enabled?  }
    assert_raises(UnknownObjectException) { browser.frame(:name, "buttonFrame2").button(:id, "b2").enabled?  }
    assert(browser.frame(:name, "buttonFrame").button(:id, "b2").enabled?)
    assert_false(browser.frame(:name, "buttonFrame").button(:caption, "Disabled Button").enabled?)
  end

  def test_frame_using_name_and_regexp
    assert_raises(UnknownObjectException) { browser.frame(:name, /missingFrame/).button(:id, "b2").enabled?  }
    assert(browser.frame(:name, /button/).button(:id, "b2").enabled?)
  end

  def test_frame_using_index
    assert_raises(UnknownObjectException) { browser.frame(:index, 7).button(:id, "b2").enabled?  }
    assert_raises(UnknownObjectException) { browser.frame(:index, 1).button(:id, "b2").enabled?  }
    assert(browser.frame(:index, 0 ).button(:id, "b2").enabled?)
    assert_false(browser.frame(:index, 0).button(:caption, "Disabled Button").enabled?)
    assert_equal('blankpage.html', browser.frame(:index, 1).src)
  end

  tag_method :test_frame_with_invalid_attribute, :fails_on_firefox

  def test_frame_with_invalid_attribute
    assert_raises(MissingWayOfFindingObjectException) { browser.frame(:blah, 'no_such_thing').button(:id, "b2").enabled?  }
  end

  def test_preset_frame
    assert browser.frame(:name => "buttonFrame").button(:id, "b2").enabled?
    assert !browser.frame(:name => "buttonFrame").button(:caption, "Disabled Button").enabled?
  end
end


class TC_Frames2 < Test::Unit::TestCase
  include Watir::Exception

  def setup
    goto_page "frame_multi.html"
  end

  def test_frame_with_no_name
    assert_raises(UnknownObjectException) { browser.frame(:name, "missingFrame").button(:id, "b2").enabled?  }
  end

  def test_frame_by_id
    assert_raises(UnknownObjectException) { browser.frame(:id, "missingFrame").button(:id, "b2").enabled?  }
    assert(browser.frame(:id, 'first_frame').button(:id, "b2").enabled?)
  end

  def test_frame_by_src
    assert(browser.frame(:src, /pass/).button(:value, 'Close Window').exists?)
  end

end

class TC_NestedFrames < Test::Unit::TestCase
  tags :fails_on_firefox

  def setup
    goto_page "nestedFrames.html"
  end

  def test_frame
    assert_raises(UnknownObjectException) { browser.frame(:name => "missingFrame").button(:id, "b2").enabled?  }
    assert_raises(UnknownObjectException) { browser.frame(:name => "nestedFrame").frame(:name => "subFrame").button(:id, "b2").enabled?  }
    assert(browser.frame(:name => "nestedFrame").frame(:name => "senderFrame").button(:name, "sendIt").enabled?)
    browser.frame(:name => "nestedFrame").frame(:name => "senderFrame").text_field(:index, "0").set("Hello")
    browser.frame(:name => "nestedFrame").frame(:name => "senderFrame").button(:name, "sendIt").click
    assert(browser.frame(:name => "nestedFrame").frame(:name => "receiverFrame").text_field(:name, "receiverText").verify_contains("Hello"))
  end

end

class TC_IFrames < Test::Unit::TestCase
  tags :fails_on_firefox

  def setup
    goto_page "iframeTest.html"
  end

  def test_Iframe
    browser.frame(:name => "senderFrame").text_field(:name, "textToSend").set( "Hello World")
    browser.frame(:name => "senderFrame").button(:index, 0).click
    assert( browser.frame(:name => "receiverFrame").text_field(:name, "receiverText").verify_contains("Hello World") )
    assert_equal(browser.frame(:src, /iframeTest2/).text_field(:name, 'receiverText').value, "Hello World")
  end

  def test_iframes_id
    browser.frame(:id, "sf").text_field(:name, "textToSend").set( "Hello World")
    browser.frame(:id, "sf").button(:name, 'sendIt').click
    assert( browser.frame(:name => "receiverFrame").text_field(:name, "receiverText").verify_contains("Hello World") )
  end

end

class TC_show_frames < Test::Unit::TestCase
  include CaptureIOHelper

  def capture_and_compare(page, expected)
    goto_page page
    actual = capture_stdout { browser.showFrames }
    assert_equal(expected, actual)
  end

  tag_method :test_show_nested_frames, :fails_on_firefox

  def test_show_nested_frames
    capture_and_compare("nestedFrames.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: nestedFrame
frame  index: 2 name: nestedFrame2
END_OF_MESSAGE
  end

  tag_method :test_button_frames, :fails_on_firefox

  def test_button_frames
    capture_and_compare("frame_buttons.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: buttonFrame
frame  index: 2 name: buttonFrame2
END_OF_MESSAGE
  end

  tag_method :test_iframes, :fails_on_firefox

  def test_iframes
    capture_and_compare("iframeTest.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: senderFrame
frame  index: 2 name: receiverFrame
END_OF_MESSAGE
  end

end

class TC_Frames_click_no_wait < Test::Unit::TestCase
  def setup
    goto_page "frame_buttons.html"
  end

  def test_frame_click_no_wait
    frame = browser.frame(:name => "buttonFrame")
    assert !frame.text.include?("PASS")
    frame.button(:id => "b2").click_no_wait
    assert_nothing_raised {
      Watir::Wait.until {frame.text.include?("PASS")}
    }
  end
end

class TC_Frame_multiple_attributes < Test::Unit::TestCase
  def setup
    goto_page "frame_multi.html"
  end

  def test_get_frame_by_name_and_id
    assert_equal('blankpage.html', browser.frame(:id => 'second_frame', :name => 'buttonFrame2').src)
  end
end

class TC_frames_method_for_container < Test::Unit::TestCase
  def setup
    goto_page "frame_multi.html"
  end

  def test_frames_collection
    frames = browser.frames
    assert_equal(3, frames.length)
    assert_equal('first_frame', frames[1].id)
    assert_equal('pass.html', frames[3].src)
  end
end

class TC_iframe_access < Test::Unit::TestCase
  def setup
    goto_page "iframe.html"
  end

  def test_frame_without_access_should_still_show_properties
    frame = browser.frame(:name, 'iframe')
    assert_nothing_raised {frame.src}
    assert_equal('http://www.google.com', frame.src)
    assert_raises(FrameAccessDeniedException) {frame.button(:index, 0).click}
  end

end

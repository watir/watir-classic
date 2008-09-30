# feature tests for Frames
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') unless $SETUP_LOADED
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "frame_buttons.html"
  end
  
  def test_frame_no_what
    assert_raises(UnknownFrameException) { browser.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { browser.frame("buttonFrame2").button(:id, "b2").enabled?  }  
    assert(browser.frame("buttonFrame").button(:id, "b2").enabled?)   
    assert(!browser.frame("buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name
    assert_raises(UnknownFrameException) { browser.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { browser.frame(:name, "buttonFrame2").button(:id, "b2").enabled?  }  
    assert(browser.frame(:name, "buttonFrame").button(:id, "b2").enabled?)   
    assert(!browser.frame(:name , "buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name_and_regexp
    assert_raises(UnknownFrameException) { browser.frame(:name , /missingFrame/).button(:id, "b2").enabled?  }  
    assert(browser.frame(:name, /button/).button(:id, "b2").enabled?)   
  end
  
  def test_frame_using_index
    assert_raises(UnknownFrameException) { browser.frame(:index, 8).button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { browser.frame(:index, 2).button(:id, "b2").enabled?  }  
    assert(browser.frame(:index, 1 ).button(:id, "b2").enabled?)   
    assert(!browser.frame(:index, 1).button(:caption, "Disabled Button").enabled?)
  end
  
  tag_method :test_frame_with_invalid_attribute, :fails_on_firefox
  def test_frame_with_invalid_attribute
    assert_raises(ArgumentError) { browser.frame(:blah, 'no_such_thing').button(:id, "b2").enabled?  }  
  end
  
  def test_preset_frame
    # with ruby's instance_eval, we are able to use the same frame for several actions
    results = browser.frame("buttonFrame").instance_eval do [
      button(:id, "b2").enabled?, 
      button(:caption, "Disabled Button").enabled?
      ]
    end
    assert_equal([true, false], results)
  end
end
  

class TC_Frames2 < Test::Unit::TestCase
  include Watir::Exception
  
  def setup
    goto_page "frame_multi.html"
  end
  
  def test_frame_with_no_name
    assert_raises(UnknownFrameException) { browser.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
  end            
  
  def test_frame_by_id
    assert_raises(UnknownFrameException) { browser.frame(:id , "missingFrame").button(:id, "b2").enabled?  }  
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
    assert_raises(UnknownFrameException) { browser.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownFrameException) { browser.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  
    assert(browser.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   
    browser.frame("nestedFrame").frame("senderFrame").text_field(:index, "1").set("Hello")
    browser.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click
    assert(browser.frame("nestedFrame").frame("receiverFrame").text_field(:name, "receiverText").verify_contains("Hello"))   
  end
  
end

class TC_IFrames < Test::Unit::TestCase
  tags :fails_on_firefox

  def setup
    goto_page "iframeTest.html"
  end
  
  def test_Iframe
    browser.frame("senderFrame").text_field(:name , "textToSend").set( "Hello World")
    browser.frame("senderFrame").button(:index, 1).click
    assert( browser.frame("receiverFrame").text_field(:name , "receiverText").verify_contains("Hello World") )
    assert_equal(browser.frame(:src, /iframeTest2/).text_field(:name, 'receiverText').value, "Hello World")    
  end

  def test_iframes_id 
    browser.frame(:id, "sf").text_field(:name , "textToSend").set( "Hello World")
    browser.frame(:id, "sf").button(:name,'sendIt').click
    assert( browser.frame("receiverFrame").text_field(:name , "receiverText").verify_contains("Hello World") )  
  end   
  
end   

require 'unittests/iostring'
class TC_show_frames < Test::Unit::TestCase
  include MockStdoutTestCase                
  
  def capture_and_compare(page, expected)
    browser.goto($htmlRoot + page)
    $stdout = @mockout
    browser.showFrames
    assert_equal(expected, @mockout)
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


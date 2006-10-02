# feature tests for Frames
# revision: $Revision$

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "frame_buttons.html")
  end
  
  def test_frame_no_what
    assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ie.frame("buttonFrame2").button(:id, "b2").enabled?  }  
    assert($ie.frame("buttonFrame").button(:id, "b2").enabled?)   
    assert(!$ie.frame("buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name
    assert_raises(UnknownFrameException) { $ie.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ie.frame(:name, "buttonFrame2").button(:id, "b2").enabled?  }  
    assert($ie.frame(:name, "buttonFrame").button(:id, "b2").enabled?)   
    assert(!$ie.frame(:name , "buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name_and_regexp
    assert_raises(UnknownFrameException) { $ie.frame(:name , /missingFrame/).button(:id, "b2").enabled?  }  
    assert($ie.frame(:name, /button/).button(:id, "b2").enabled?)   
  end
  
  def test_frame_using_index
    assert_raises(UnknownFrameException) { $ie.frame(:index, 8).button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ie.frame(:index, 2).button(:id, "b2").enabled?  }  
    assert($ie.frame(:index, 1 ).button(:id, "b2").enabled?)   
    assert(!$ie.frame(:index, 1).button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_with_invalid_attribute
    assert_raises(ArgumentError) { $ie.frame(:blah, 'no_such_thing').button(:id, "b2").enabled?  }  
  end
  
  def test_preset_frame
    # with ruby's instance_eval, we are able to use the same frame for several actions
    results = $ie.frame("buttonFrame").instance_eval do [
      button(:id, "b2").enabled?, 
      button(:caption, "Disabled Button").enabled?
      ]
    end
    assert_equal([true, false], results)
  end
  
end

class TC_Frames2 < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "frame_multi.html")
  end
  
  def test_frame_with_no_name
    assert_raises(UnknownFrameException) { $ie.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
  end            
  
  def test_frame_by_id
    assert_raises(UnknownFrameException) { $ie.frame(:id , "missingFrame").button(:id, "b2").enabled?  }  
    assert($ie.frame(:id, 'first_frame').button(:id, "b2").enabled?)
  end
end

class TC_NestedFrames < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "nestedFrames.html")
  end
  
  def test_frame
    assert_raises(UnknownFrameException) { $ie.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownFrameException) { $ie.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  
    assert($ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   
    $ie.frame("nestedFrame").frame("senderFrame").text_field(:index, "1").set("Hello")
    $ie.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click
    assert($ie.frame("nestedFrame").frame("receiverFrame").text_field(:name, "receiverText").verify_contains("Hello"))   
  end
  
end

class TC_IFrames < Test::Unit::TestCase
  include Watir
  
  def setup
    $ie.goto($htmlRoot + "iframeTest.html")
  end
  
  def test_Iframe
    $ie.frame("senderFrame").text_field(:name , "textToSend").set( "Hello World")
    $ie.frame("senderFrame").button(:index, 1).click
    assert( $ie.frame("receiverFrame").text_field(:name , "receiverText").verify_contains("Hello World") )
  end

  #VALIDATE THAT WE CAN GET THERE VIA id  
  def test_iframes_id 
    $ie.frame(:id, "sf").text_field(:name , "textToSend").set( "Hello World")
    $ie.frame(:id, "sf").button(:name,'sendIt').click
    assert( $ie.frame("receiverFrame").text_field(:name , "receiverText").verify_contains("Hello World") )  
  end   
  
end   

require 'unittests/iostring'
class TC_show_frames < Test::Unit::TestCase
  include MockStdoutTestCase                
  
  def capture_and_compare(page, expected)
    $ie.goto($htmlRoot + page)
    $stdout = @mockout
    $ie.showFrames
    assert_equal(expected, @mockout)
  end
  
  def test_show_nested_frames
    capture_and_compare("nestedFrames.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: nestedFrame
frame  index: 2 name: nestedFrame2
END_OF_MESSAGE
  end
  
  def test_button_frames
    capture_and_compare("frame_buttons.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: buttonFrame
frame  index: 2 name: buttonFrame2
END_OF_MESSAGE
  end
  
  def test_iframes
    capture_and_compare("iframeTest.html", <<END_OF_MESSAGE)
there are 2 frames
frame  index: 1 name: senderFrame
frame  index: 2 name: receiverFrame
END_OF_MESSAGE
  end
  
end


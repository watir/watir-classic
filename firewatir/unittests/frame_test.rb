# feature tests for Frames
# revision: $Revision: 1.0 $

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..') if $0 == __FILE__
require 'unittests/setup'

class TC_Frames < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "frame_buttons.html")
  end
  
  def test_frame_no_what
    assert_raises(UnknownFrameException) { $ff.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ff.frame("buttonFrame2").button(:id, "b2").enabled?  }  
    assert($ff.frame("buttonFrame").button(:id, "b2").enabled?)   
    assert(!$ff.frame("buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name
    assert_raises(UnknownFrameException) { $ff.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ff.frame(:name, "buttonFrame2").button(:id, "b2").enabled?  }  
    assert($ff.frame(:name, "buttonFrame").button(:id, "b2").enabled?)   
    assert(!$ff.frame(:name , "buttonFrame").button(:caption, "Disabled Button").enabled?)
  end
  
  def test_frame_using_name_and_regexp
    assert_raises(UnknownFrameException) { $ff.frame(:name , /missingFrame/).button(:id, "b2").enabled?  }  
    assert($ff.frame(:name, /button/).button(:id, "b2").enabled?)   
  end
  
  def test_frame_using_index
    assert_raises(UnknownFrameException) { $ff.frame(:index, 8).button(:id, "b2").enabled?  }  
    assert_raises(UnknownObjectException) { $ff.frame(:index, 2).button(:id, "b2").enabled?  }  
    assert($ff.frame(:index, 1 ).button(:id, "b2").enabled?)   
    assert(!$ff.frame(:index, 1).button(:caption, "Disabled Button").enabled?)
  end
  
#  def test_frame_with_invalid_attribute
#    assert_raises(ArgumentError) { $ff.frame(:blah, 'no_such_thing').button(:id, "b2").enabled?  }  
#  end
  
  def test_preset_frame
    # with ruby's instance_eval, we are able to use the same frame for several actions
    results = $ff.frame("buttonFrame").instance_eval do [
     button(:id, "b2").enabled?, 
     button(:caption, "Disabled Button").enabled?
     ]
  end
    assert_equal([true, false], results)
  end
  
end

class TC_Frames2 < Test::Unit::TestCase
  include FireWatir
 
  def setup
    $ff.goto($htmlRoot + "frame_multi.html")
  end
  
  def test_frame_with_no_name
    assert_raises(UnknownFrameException) { $ff.frame(:name , "missingFrame").button(:id, "b2").enabled?  }  
  end            
  
  def test_frame_by_id
    assert_raises(UnknownFrameException) { $ff.frame(:id , "missingFrame").button(:id, "b2").enabled?  }  
    assert($ff.frame(:id, 'first_frame').button(:id, "b2").enabled?)
    assert(/.*Test page for buttons.*/ =~ $ff.frame(:id, 'first_frame').html)
  end
end

class TC_NestedFrames < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "nestedFrames.html")
  end
  
  def test_frame
    assert_raises(UnknownFrameException) { $ff.frame("missingFrame").button(:id, "b2").enabled?  }  
    assert_raises(UnknownFrameException) { $ff.frame("nestedFrame").frame("subFrame").button(:id, "b2").enabled?  }  
    assert($ff.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").enabled?)   
    $ff.frame("nestedFrame").frame("senderFrame").text_field(:index, "1").set("Hello")
    $ff.frame("nestedFrame").frame("senderFrame").button(:name, "sendIt").click
    assert($ff.frame("nestedFrame").frame("receiverFrame").text_field(:name, "receiverText").verify_contains("Hello"))   
  end
  
end

class TC_IFrames < Test::Unit::TestCase
  include FireWatir
  
  def setup
    $ff.goto($htmlRoot + "iframeTest.html")
  end
  
  def test_Iframe
    f = $ff.frame("senderFrame")
    f.text_field(:name, "textToSend").set("Hello World")
    $ff.frame("senderFrame").text_field(:name , "textToSend").set( "Hello World")
    $ff.frame("senderFrame").button(:index, 1).click
    assert( $ff.frame("receiverFrame").text_field(:name , "receiverText").verify_contains("Hello World") )
  end
  
end   

require 'unittests/iostring'
class TC_show_frames < Test::Unit::TestCase
  include MockStdoutTestCase                
 
  def capture_and_compare(page, expected)
    $ff.goto($htmlRoot + page)
    $stdout = @mockout
    $ff.showFrames
    assert_equal(expected, @mockout)
  end
 
  def test_show_nested_frames
    capture_and_compare("nestedFrames.html", <<END_OF_MESSAGE)
There are 2 frames
frame: name: nestedFrame
      index: 1
frame: name: nestedFrame2
      index: 2
END_OF_MESSAGE
  end
  
  def test_button_frames
    capture_and_compare("frame_buttons.html", <<END_OF_MESSAGE)
There are 2 frames
frame: name: buttonFrame
      index: 1
frame: name: buttonFrame2
      index: 2
END_OF_MESSAGE
  end
 
  def test_iframes
    capture_and_compare("iframeTest.html", <<END_OF_MESSAGE)
There are 2 frames
frame: name: senderFrame
      index: 1
frame: name: receiverFrame
      index: 2
END_OF_MESSAGE
  end
  
end


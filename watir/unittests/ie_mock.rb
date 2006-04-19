# mock library for testing the IE controller
require 'watir'

class FakeFrame
  def length
    return 0
  end
end

class FakeDoc
  
  attr_accessor :links, :all
  
  def initialize()
    @links = ""
    @doc = self
  end
  
  def getElementsByTagName(tag)
    @doc.links
  end
  
  def frames
    return FakeFrame.new()
  end
  
  def readyState
    return "complete"
  end
  
  def addLink(value)
    if @links.nil?
      @links = value
    else
      @links << value
    end
  end
  
  def url
    return "file://fake"
  end
  
end

class StubExplorer
  
  attr_accessor :timeToWait
  
  def initialize()
    @timeToWait = 1
    @visible = $HIDE_IE
    @document = FakeDoc.new()
  end
  
  def document
    return @document
  end
  
  def busy
    sleep @timeToWait
    return FALSE
  end
  
  def readyState
    return 4
  end
  
  def visible=(value)
  end
  
end

class TestIE < Watir::IE
  
  def create_browser_window
    @ie = StubExplorer.new()
  end
  
  def addLink(link)
    @ie.document.addLink(link)
  end
  
  def setTimeToWait(time = 1)
    @ie.timeToWait = time
  end
  
end

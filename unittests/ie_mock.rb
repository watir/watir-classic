require 'watir'

class FakeFrame
	def length
		return 0
	end
end

class FakeDoc

   attr_accessor :links
   
   def initialize()
      @links = ""
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
	
	def busy ()
		sleep @timeToWait
		return FALSE
	end
	
	def readyState
		return 4
	end
	
	def visible=(value)
	end
	
end

class TestIE < IE

   def createBrowser
      return StubExplorer.new()
   end
   
   def addLink(link)
      @ie.document.addLink(link)
   end
	
   def setTimeToWait(time = 1)
      @ie.timeToWait = time
   end
	
end

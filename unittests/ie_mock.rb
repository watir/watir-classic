require 'watir'

class FakeFrame
	def length
		return 0
	end
end

class FakeDoc

   attr_accessor :links
   
   def initialize()
      @links = nil
   end
   
	def frames
		return FakeFrame.new()
	end
	
	def readyState
		return "complete"
	end
	
	def links
		return nil
	end
	
end

class StubExplorer

	attr_accessor :timeToWait

	def initialize()
		@timeToWait = 1
		@visible = $HIDE_IE
	end
	
	def document
		return FakeDoc.new()
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
      if (@ie.document.links == nil)
         @ie.document.links = [link]
      else
         @ie.document.links = @ie.document.links + [link]
      end
   end
	
   def setTimeToWait(time = 1)
      @ie.timeToWait = time
   end
	
end

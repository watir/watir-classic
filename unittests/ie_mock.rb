require 'watir.rb'

class FakeFrame
	def length
		return 0
	end
end

class FakeDoc

	def frames
		return FakeFrame.new()
	end
	
	def readyState
		return "complete"
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
	
	def setTimeToWait(time = 1)
		@ie.timeToWait = time
	end
	
end

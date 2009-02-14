module Watir
  # POPUP object
  class PopUp
    def initialize(container)
      @container = container
      @page_container = container.page_container
    end
    
    def button(caption)
      return JSButton.new(@container.getIE.hwnd, caption)
    end
  end
  
  class JSButton
    def initialize(hWnd, caption)
      @hWnd = hWnd
      @caption = caption
    end
    
    def startClicker(waitTime=3)
      clicker = WinClicker.new
      clicker.clickJSDialog_Thread
      # clickerThread = Thread.new(@caption) {
      #   sleep waitTime
      #   puts "After the wait time in startClicker"
      #   clickWindowsButton_hwnd(hwnd, buttonCaption)
      #}
    end
  end
end
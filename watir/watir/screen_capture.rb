
require 'Win32API'

module Watir
  module ScreenCapture
    
    KEYEVENTF_KEYUP = 0x2
    SW_HIDE         = 0
    SW_SHOW         = 5
    SW_SHOWNORMAL   = 1
    VK_CONTROL      = 0x11
    VK_F4           = 0x73
    VK_MENU         = 0x12
    VK_RETURN       = 0x0D
    VK_SHIFT        = 0x10
    VK_SNAPSHOT     = 0x2C
    VK_TAB      = 0x09
    GMEM_MOVEABLE = 0x0002
    CF_TEXT = 1

    # this method saves the current window or whole screen as either a bitmap or a jpeg
    # It uses paint to save the file, so will barf if a duplicate filename is selected, or  the path doesnt exist etc
    #    * filename        - string  -  the name of the file to save. If its not fully qualified the current directory is used
    #    * active_window   - boolean - if true, the whole screen is captured, if false,  just the active window is captured
    #    * save_as_bmp     - boolean - if true saves the file as a bitmap, saves it as a jpeg otherwise
    def screen_capture(filename , active_window_only=false, save_as_bmp=false)


      keybd_event = Win32API.new("user32", "keybd_event", ['I','I','L','L'], 'V')
      vkKeyScan = Win32API.new("user32", "VkKeyScan", ['I'], 'I')
      winExec = Win32API.new("kernel32", "WinExec", ['P','L'], 'L')
      openClipboard = Win32API.new('user32', 'OpenClipboard', ['L'], 'I')
      setClipboardData = Win32API.new('user32', 'SetClipboardData', ['I', 'I'], 'I')
      closeClipboard = Win32API.new('user32', 'CloseClipboard', [], 'I')
      globalAlloc = Win32API.new('kernel32', 'GlobalAlloc', ['I', 'I'], 'I')
      globalLock = Win32API.new('kernel32', 'GlobalLock', ['I'], 'I')
      globalUnlock = Win32API.new('kernel32', 'GlobalUnlock', ['I'], 'I')
      memcpy = Win32API.new('msvcrt', 'memcpy', ['I', 'P', 'I'], 'I')

     
      filename = Dir.getwd.tr('/','\\') + '\\' + filename unless filename.index('\\')

      if active_window_only ==false
          keybd_event.Call(VK_SNAPSHOT,0,0,0)   # Print Screen
      else
          keybd_event.Call(VK_SNAPSHOT,1,0,0)   # Alt+Print Screen
      end 

      winExec.Call('mspaint.exe', SW_SHOW)
      sleep(1)
     
      # Ctrl + V  : Paste
      keybd_event.Call(VK_CONTROL, 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?V), 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?V), 1, KEYEVENTF_KEYUP, 0)
      keybd_event.Call(VK_CONTROL, 1, KEYEVENTF_KEYUP, 0)


      # Alt F + A : Save As
      keybd_event.Call(VK_MENU, 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?F), 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?F), 1, KEYEVENTF_KEYUP, 0)
      keybd_event.Call(VK_MENU, 1, KEYEVENTF_KEYUP, 0)
      keybd_event.Call(vkKeyScan.Call(?A), 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?A), 1, KEYEVENTF_KEYUP, 0)
      sleep(1)

      # copy filename to clipboard
      hmem = globalAlloc.Call(GMEM_MOVEABLE, filename.length+1)
      mem = globalLock.Call(hmem)
      memcpy.Call(mem, filename, filename.length+1)
      globalUnlock.Call(hmem)
      openClipboard.Call(0)
      setClipboardData.Call(CF_TEXT, hmem) 
      closeClipboard.Call 
      sleep(1)
      
      # Ctrl + V  : Paste
      keybd_event.Call(VK_CONTROL, 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?V), 1, 0, 0)
      keybd_event.Call(vkKeyScan.Call(?V), 1, KEYEVENTF_KEYUP, 0)
      keybd_event.Call(VK_CONTROL, 1, KEYEVENTF_KEYUP, 0)

      if save_as_bmp == false
        # goto the combo box
        keybd_event.Call(VK_TAB, 1, 0, 0)
        keybd_event.Call(VK_TAB, 1, KEYEVENTF_KEYUP, 0)
        sleep(0.5)

        # select the first entry with J
        keybd_event.Call(vkKeyScan.Call(?J), 1, 0, 0)
        keybd_event.Call(vkKeyScan.Call(?J), 1, KEYEVENTF_KEYUP, 0)
        sleep(0.5)
      end  

      # Enter key
      keybd_event.Call(VK_RETURN, 1, 0, 0)
      keybd_event.Call(VK_RETURN, 1, KEYEVENTF_KEYUP, 0)
      sleep(1)
     
      # Alt + F4 : Exit
      keybd_event.Call(VK_MENU, 1, 0, 0)
      keybd_event.Call(VK_F4, 1, 0, 0)
      keybd_event.Call(VK_F4, 1, KEYEVENTF_KEYUP, 0)
      keybd_event.Call(VK_MENU, 1, KEYEVENTF_KEYUP, 0)
      sleep(1) 

    end
  end

end


#screenCapture( "f.bmp", false , true)


module Watir
  module Win32
    # this will find the IEDialog.dll file in its build location
    @@iedialog_file = (File.expand_path(File.dirname(__FILE__) + '/..') + "/watir/IEDialog/Release/IEDialog.dll").gsub('/', '\\')

    GetUnknown = Win32API.new(@@iedialog_file, 'GetUnknown', ['l', 'p'], 'v')    
    User32 = DL.dlopen('user32')
    FindWindowEx = User32['FindWindowEx', 'LLLpp']    
    # method for this found in wet-winobj/wet/winobjects/WinUtils.rb
    GetWindow = User32['GetWindow', 'ILL']
    
    ## GetWindows Constants
    GW_HWNDFIRST = 0
    GW_HWNDLAST = 1
    GW_HWNDNEXT = 2
    GW_HWNDPREV = 3
    GW_OWNER = 4
    GW_CHILD = 5
    GW_ENABLEDPOPUP = 6
    GW_MAX = 6

    IsWindow = User32['IsWindow', 'II']
    # Does the window with the specified window handle (hwnd) exist?
    def self.window_exists? hwnd
      rtn, junk = IsWindow[hwnd]
      rtn == 1
    end
  end
end  
=begin rdoc
   This is Watir's window clicker helper class, uses Win32 api
   calls to access buttons and windows. 

   Typical usage:
    # include this file in your script
    require "watir/winClicker.rb"

    # create a new instance of WinClicker and use it
    wc = WinClicker.new
    wc.clickWindowsButton("My Window", "Click Me", 30)

=end

#
#   class to click javascript dialog boxes, file requester dialogs etc 
require 'dl/import'
require 'dl/struct'
require "timeout"
require 'Win32API'

class WinClicker

  WM_CLOSE    = 0x0010
  WM_KEYDOWN  = 0x0100
  WM_KEYUP    = 0x0101
  WM_CHAR     = 0x0102
  BM_CLICK    = 0x00F5
  WM_COMMAND  = 0x0111
  WM_SETTEXT  = 0x000C
  WM_GETTEXT  = 0x000D

  HWND_TOP = 0
  HWND_BOTTOM = 1
  HWND_TOPMOST = -1
  HWND_NOTOPMOST = -2

  SWP_SHOWWINDOW   = 0x40
  SWP_NOSIZE = 1
  SWP_NOMOVE = 2

  TRUE_1 = 1

  # these are constants for commonly used windows windows
  WINCLASS_DIALOG = "32770"

  # these are the most used methods

  def initialize
    @User32 = DL.dlopen("user32")
    # we must determine the path we are in
    @path_to_clicker = '"' + File.expand_path(File.dirname(__FILE__)) + '"'
  end


  # The system function passes command to the command interpreter, which executes the string as an operating-system command
  # http://msdn.microsoft.com/library/default.asp?url=/library/en-us/vccore98/html/_crt_system.2c_._wsystem.asp
  # using win32api
  def winsystem(command)
    pid  =  Win32API.new("crtdll", "system", ['P'], 'L').Call(command)
  end

  # returns the short path version of a long path
  # 8.3 style
  def getShortFileName(longName)
    size = 255
    buffer = " " * 255
    returnSize = Win32API.new("kernel32" , "GetShortPathNameA" , 'ppl'  , 'L').Call(longName ,  buffer , size )
    a = ""
    a = a + buffer[0...returnSize]        
    return a
  end

  # Set the first edit box in the Choose file dialog to textToSet
  # we may need to play with the default try count.  3 is a reasonably safe value.
  def setFileRequesterFileName( textToSet, tryCount = 3 )
    for i in (1..tryCount)
      # first set the Choose File Window to be active
      hWnd = getWindowHandle("Choose file" )
      if hWnd != -1
        makeWindowActive(hWnd)
        setTextValueForFileNameField( hWnd , textToSet) 
        clickWindowsButton_hwnd(hWnd, "&Open")
        return true
      end            
    end
    return false
  end

  # fire off setting the file name for the Choose file dialog
  # in a new process
  def setFileRequesterFileName_newProcess ( textToSet )
    myapp = "rubyw #{@path_to_clicker}/setFileDialog.rb #{textToSet}"
    # first argument to system call is a window title, in this case blank ""      
    winsystem( "start \"\" #{myapp}" )
  end

  # Return the text value from the first combo box 
  # on the Choose file dialog or nil if not found
  def getFileRequesterFileName()
    # first set the Choose File Window to be active
    hWnd = getWindowHandle("Choose file" )
    if hWnd != -1
      makeWindowActive(hWnd)
      return getTextValueForFileNameField( hWnd ) 
    else
      return nil
    end
  end

  # Click on a dialog with title of "Internet Explorer"
  # Default button to click is "OK"
  # parenthWnd not used
  def clickJavaScriptDialog(button="OK" , parenthWnd = -1)
    clickWindowsButton("Internet Explorer" , button )
  end

  # Calls system to launch a new process to click on the button
  # defaults to "OK" button
  def clickJSDialog_NewProcess(button = "OK" )
    myapp = "rubyw #{@path_to_clicker}/clickJSDialog.rb #{button}"
    log "Starting win clicker in a new process. Looking for button #{button}"
    log "Starting app: #{myapp}"
    # first argument to system call is a window title, in this case blank ""
    winsystem( "start \"\" #{myapp}" )
  end


  # as a thread
  def clickJSDialog_Thread(button = "OK" )
    sleep 3
    n = 0
    while n < 3
      sleep 1
      clickWindowsButton("Internet Explorer" , button )
      n=n+1
    end
  end

  # Looks for a window titled "Security Alert", clicks
  # on Yes button
  def clearSecurityAlertBox
    clickWindowsButton("Security Alert" , "&Yes" )
  end
  alias :clear_security_alert :clearSecurityAlertBox

  # Returns the parent handle for the given child handle
  def getParent (childhWnd )
    # pass a hWnd into this function and it will return the parent hWnd
    getParentWindow = @User32['GetParent' , 'II' ]
    a , b = getParentWindow.call(childhWnd )
    return a
  end
  alias :get_parent :getParent

  def with_dl_callback(type, prc)
    callback = DL.callback(type, &prc)
    error = nil
    begin
      yield callback
    ensure
      DL.remove_callback(callback)
    end
  end

  # Enumerates open windows and
  # returns a window handle from a given title and window class
  # Window class and title are matched regexes
  def getWindowHandle(title, winclass = "" )
    enum_windows = @User32['EnumWindows', 'IPL']
    get_class_name = @User32['GetClassName', 'ILpI']
    get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
    get_caption = @User32['GetWindowTextA', 'iLsL' ] 

    len = 32
    buff = " " * len
    classMatch = false

    bContinueEnum = -1  # Windows "true" to continue enum_windows.
    found_hwnd = -1

    enum_windows_proc = lambda {|hwnd,lparam|
      sleep 0.05
      r,rs = get_class_name.call(hwnd, buff, buff.size)

      if winclass != "" then
        if /#{winclass}/ =~ rs[1].to_s
          classMatch = true
        end
      else
        classMatch = true
      end

      if classMatch ==true
        textLength, a = get_caption_length.call(hwnd)
        captionBuffer = " " * (textLength+1)
        t ,  textCaption  = get_caption.call(hwnd, captionBuffer  , textLength+1)    
        if /#{title}/ =~ textCaption[1].to_s
          found_hwnd = hwnd
          bContinueEnum = 0 # False, discontinue enum_windows
        end
        bContinueEnum
      else
        bContinueEnum
      end
    }
    with_dl_callback('ILL',enum_windows_proc) do |callback|
      r,rs = enum_windows.call(callback, 0)
    end 
    return found_hwnd
  end
  alias :get_window_handle :getWindowHandle 

  # Call SwitchToThisWindow win32api which will 
  # The SwitchToThisWindow function is called to switch focus to a specified window
  # and bring it to the foreground
  def makeWindowActive (hWnd)
    switch_to_window = @User32['SwitchToThisWindow' , 'pLI'  ]
    # set it to be the one with focus
    switch_to_window.call(hWnd , 1)
  end
  alias :make_window_active :makeWindowActive 

  # Posts a message to the handle passed in to click 
  def clickButtonWithHandle(buttonhWnd)
    post_message = @User32['PostMessage', 'ILILL']
    r,rs = post_message.call(buttonhWnd, BM_CLICK, 0, 0)
  end
  alias :click_button_with_handle :clickButtonWithHandle 

  # Based on the parent window handle passed in, 
  # click on the button with the given caption.      
  def clickWindowsButton_hwnd (hwnd , buttonCaption )
    makeWindowActive(hwnd)
    d = getChildHandle( hwnd , buttonCaption )
    if d != -1 
      makeWindowActive(hwnd)
      clickButtonWithHandle(d)
    else
      return false
    end
    return true
  end
  alias :click_windows_button_hwnd :clickWindowsButton_hwnd 

  # this clicks the button with the name in the window with the caption. It keeps looking for the button until
  # until the timeout expires
  def clickWindowsButton (windowCaption , buttonCaption , maxWaitTime=30 )
    sleep 1
    hwnd = -1
    begin 
      timeout(maxWaitTime) do
        hwnd = getWindowHandle(windowCaption)
        while hwnd == -1 
          hwnd = getWindowHandle(windowCaption)
          sleep 0.5
        end
        makeWindowActive(hwnd)
      end
    rescue Timeout::Error 
      return false
    rescue => e
      raise e
    end
    if hwnd != -1 
      makeWindowActive(hwnd)
    else
    end
    d = getChildHandle( hwnd , buttonCaption )
    if d != -1 
      makeWindowActive(hwnd)
      clickButtonWithHandle(d)
    else
      return false
    end
    return true
  end
  alias :click_windows_button :clickWindowsButton 

  # Enumerate through children of the parent hwnd, pass back 
  # the handle for the control with the given caption
  # the caption is compared as a regex
  def getChildHandle ( hWnd , childCaption )
    enum_childWindows = @User32['EnumChildWindows' , 'IIPL' ]
    get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
    get_caption = @User32['GetWindowTextA', 'iLsL' ] 
    match_hwnd = -1  # hWnd of handle matching childCaption
    buff = " " * 16
    get_class_name = @User32['GetClassName', 'ILpI']

    bContinueEnum = -1
    enum_childWindowsProc = lambda {|chwnd,lparam|
      r,rs = get_class_name.call(chwnd, buff, buff.size)
      textLength, a = get_caption_length.call(chwnd)
      captionBuffer = " " * (textLength+1)

      t ,  textCaption  = get_caption.call(chwnd, captionBuffer  , textLength+1)    
      if /#{childCaption}/ =~ textCaption[1].to_s then
        match_hwnd = chwnd
        bContinueEnum = 0  # Windows "false" to discontinue enum_childWindow
      end
      bContinueEnum
    }
    with_dl_callback('ILL',enum_childWindowsProc) do |callback|
      r  = enum_childWindows.call(hWnd, callback  ,0)
    end
    return match_hwnd
  end
  alias :get_chwnd :getChildHandle

  # Convenience method to return Static text for 
  # children of the window with the given caption
  def getStaticText(caption)
    return getStaticTextFromWindow(caption, -1)
  end
  alias :get_static_text :getStaticText 

  # Convenience method to return Static text for 
  # children of the window handle
  def getStaticText_hWnd (hWnd)
    return getStaticTextFromWindow("" , hWnd)
  end
  alias :get_static_text_hwnd :getStaticText_hWnd 

  # Return text as an array from child controls of the window
  # given as either a handle or with the given caption
  # that have a class type of Static 
  def getStaticTextFromWindow( windowCaption  , hWnd)
    enum_childWindows = @User32['EnumChildWindows' , 'IIPL' ]
    get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
    get_caption = @User32['GetWindowTextA', 'iLsL' ] 

    staticText = []
    buff = " " * 16
    get_class_name = @User32['GetClassName', 'ILpI']

    if hWnd == -1
      hWnd = getWindowHandle(windowCaption)
    end

    if hWnd == -1 
      return staticText
    end

    bContinueEnum = -1
    enum_childWindows_proc = lambda {|hWnd,lparam|
      r,rs = get_class_name.call(hWnd, buff, buff.size)
      if rs[1].to_s == "Static"  # there must be a better way of detecting this
        textLength, a = get_caption_length.call(hWnd)
        captionBuffer = " " * (textLength+1)
        t ,  textCaption  = get_caption.call(hWnd, captionBuffer  , textLength+1)    
        staticText << textCaption[1].to_s
      end
      bContinueEnum
    }
    with_dl_callback('ILL',enum_childWindows_proc) do |callback|
      r  = enum_childWindows.call(hWnd, callback  ,0)
    end
    return staticText
  end
  alias :get_static_text_from_window :getStaticTextFromWindow 

  # returns the handle (or -1 if its not found) of the 
  # nth control of this class in the parent window specified 
  # by the window handle
  def getHandleOfControl (hWnd , controlClass, position )
    enum_childWindows = @User32['EnumChildWindows' , 'IIPL' ]
    get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
    get_caption = @User32['GetWindowTextA', 'iLsL' ] 
    control_hWnd = []
    buff = " " * 16
    get_class_name = @User32['GetClassName', 'ILpI']

    bContinueEnum = -1
    enum_childWindows_proc = lambda {|hWnd,lparam|
      r,rs = get_class_name.call(hWnd, buff, buff.size)
      if rs[1].to_s == controlClass  # there must be a better way of detecting this
        control_hWnd << hWnd
      end
      bContinueEnum
    }
    with_dl_callback('ILL',enum_childWindows_proc) do |callback|
      r  = enum_childWindows.call(hWnd, callback ,0)
    end
    controlHwnd = control_hWnd[position]
    if controlHwnd == nil then
      controlHwnd = -1
    end
    return controlHwnd 
  end
  alias :get_handle_of_ctrl :getHandleOfControl 

  # Call set text on the given window handle
  def setComboBoxText(hWnd , textToSet)
    set_text(hWnd, textToSet)
  end
  alias :set_combo_txt :setComboBoxText 

  # Call set text on the given window handle
  def setTextBoxText(hWnd , textToSet)
    set_text(hWnd, textToSet)
  end
  alias :set_textbox_txt :setTextBoxText 

  # Private method to set text called by the two methods above    
  def set_text(hWnd, textToSet)
    send_message = @User32['SendMessage',  'ILISS']  
    r  ,rs  = send_message.call(hWnd , WM_SETTEXT ,'',textToSet)    
  end
  private :set_text

  # Get the text in the handle for the given control
  def getControlText(hWnd)
    buff = " " * 256
    send_message = @User32['SendMessage',  'ILIIS']  
    r  ,rs  = send_message.call(hWnd , WM_GETTEXT , 256 , buff )
    return buff.to_s
  end
  alias :get_ctrl_txt :getControlText 

  # get the title for the specified hwnd
  def getWindowTitle(hWnd)
    buff = " " * 256
    getWindowText = @User32['GetWindowText' , 'ILSI']
    r , rs = getWindowText.call( hWnd , buff , 256 )
    return buff.to_s
  end
  alias :get_win_title :getWindowTitle

  # Get the text in the first combo box 
  # file requester methods returns nil on failure to 
  # locate the 1st combobox
  def getTextValueForFileNameField(parenthWnd) 
    f = getHandleOfControl(parenthWnd, "ComboBox", 1)
    if f == -1 then
      # unable to find the first combobox
      return nil
    else
      # we have the control and now
      # can send it some messages
      return getWinText(f )
    end
  end
  alias :get_file_name :getTextValueForFileNameField 

  # this sets the filename field to text to set
  def setTextValueForFileNameField( parenthWnd , textToSet ) 
    # get the handle of the nth control that is an Edit box
    f = getHandleOfControl(parenthWnd, "Edit" , 0 )
    if f == -1 then
      # unable to get a handle on the first edit control
      return false
    else
      # we found the control and can now send it some messages
      setComboBoxText(f , textToSet)
      return true
    end
  end
  alias :set_file_name :setTextValueForFileNameField 
end 

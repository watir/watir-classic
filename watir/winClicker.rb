# winClickers.rb
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

    def initialize()
       @User32 = DL.dlopen("user32")

       # we must determine the path we are in
       @path_to_clicker = File.expand_path(File.dirname(__FILE__))
    end



    def winsystem(command)
 

      # http://msdn.microsoft.com/library/default.asp?url=/library/en-us/vccore98/html/_crt_system.2c_._wsystem.asp
      # using win32api
      pid  =  Win32API.new("crtdll", "system", ['P'], 'L').Call(command)

      # using DL
      #winapi= DL.dlopen("crtdll")
      #sys = winapi['system' , '??']

    end

    def getShortFileName(longName)
        size = 255
        buffer = " " * 255
        returnSize = Win32API.new("kernel32" , "GetShortPathNameA" , 'ppl'  , 'L').Call(longName ,  buffer , size )
        a = ""
        a = a + buffer[0...returnSize]        

        return a

    end

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
        puts 'File Requester not found'
        return false
    end

    def setFileRequesterFileName_newProcess ( textToSet )
        myapp = "#{@path_to_clicker}/setFileDialog.rb #{textToSet}"
        puts "Starting win setFileDialog in new process. Setting text #{textToSet}"
        puts "Starting app: #{myapp}"
        winsystem( "start #{myapp}" )
    end



    def getFileRequesterFileName ( )

        # first set the Choose File Window to be active
        hWnd = getWindowHandle("Choose file" )
        if hWnd != -1

           makeWindowActive (hWnd)
           return getTextValueForFileNameField( hWnd ) 

        else
            puts 'File Requester not found'
            return nil
        end
    end

    # Click Javascript Dialog

    def clickJavaScriptDialog(button="Ok" , parenthWnd = -1)

       clickWindowsButton("Microsoft Internet Explorer" , button )

    end



    # use this method to launch a clicker in a new process

    def clickJSDialog_NewProcess(button = "OK" )

        myapp = "#{@path_to_clicker}clickJSDialog.rb #{button}"
        log "Starting win clicker in a new process. Looking for button #{button}"
        log "Starting app: #{myapp}"
        winsystem( "start #{myapp}" )

        #if winsystem( myapp ) == false
        #    log "Clicker failed to start..."  
        #    log  $?   # some sort of lasterror ?????
        #end
    end


    # as a thread
    def clickJSDialog_Thread(button = "OK" )

           puts "clickJSDialog_Thread Starting waiting.."
           sleep 3
           puts " clickJSDialog_Thread ... resuming"
           n = 0
           while n < 3
               sleep 1
               clickWindowsButton("Microsoft Internet Explorer" , button )
               n=n+1
           end

    end


    def clearSecurityAlertBox()
         clickWindowsButton("Security Alert" , "&Yes" )
    end


    # the following methods are used internally, they may have uses elsewhere

    def getParent (childhWnd )
        # pass a hWnd into this function and it will return the parent hWnd
        getParentWindow = @User32['GetParent' , 'II' ]

        puts " Finding Parent for: " + childhWnd.to_s
        a , b = getParentWindow.call(childhWnd )
        #puts "a = " a.to_s , b.to_s
        return a

    end

    def getWindowHandle(title, winclass = "" )

        enum_windows = @User32['EnumWindows', 'IPL']
        get_class_name = @User32['GetClassName', 'ILpI']
        get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
        get_caption = @User32['GetWindowTextA', 'iLsL' ] 

        #if winclass != ""
        #    len = winclass.length + 1
        #else
        len = 32
        #end
        buff = " " * len
        classMatch = false
       
           puts("getWindowHandle - looking for: " + title.to_s )

            bContinueEnum = -1

            enum_windows_proc = DL.callback('ILL') {|hwnd,lparam|
              sleep 0.05
              r,rs = get_class_name.call(hwnd, buff, buff.size)
              puts "Found window: " + rs[1].to_s

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
                    puts "Caption =" +  textCaption[1].to_s

                    if /#{title}/ =~ textCaption[1].to_s
                        puts "Found Window with correct caption (" + textCaption[1].to_s + " hwnd=" + hwnd.to_s + ")"
                        return hwnd
                    end
                    bContinueEnum
                else
                    bContinueEnum
                end
            }
            r,rs = enum_windows.call(enum_windows_proc, 0)
            return bContinueEnum
    end


    def makeWindowActive (hWnd)

        switch_to_window = @User32['SwitchToThisWindow' , 'pLI'  ]

        # set it to be the one with focus
        switch_to_window.call(hWnd , 1)

    end

    def clickButtonWithHandle(buttonhWnd)

         post_message = @User32['PostMessage', 'ILILL']
         #post_message = @User32['SendMessage', 'ILILL']
         puts "posting mesage"
         r,rs = post_message.call(buttonhWnd, BM_CLICK, 0, 0)

         puts "return #{r} #{rs} "
    end


     def clickWindowsButton_hwnd (hwnd , buttonCaption )

         makeWindowActive(hwnd)

         d = getChildHandle( hwnd , buttonCaption )
         puts ("clickWindowsButton: handle for button: " + buttonCaption + " is " + d.to_s )

         if d != -1 
             makeWindowActive(hwnd)
             clickButtonWithHandle (d)
         else
             return false
         end

         return true
     end


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
         rescue
             puts "clickWindowsButton: Cant make window active in specified time ( " + maxWaitTime.to_s + ") - no handle"
             return false
         end

         puts ' Window handle is : ' + hwnd.to_s
         if hwnd != -1 
             puts "clickWindowsButton: Handle for window: " + windowCaption + " is: " + hwnd.to_s
             makeWindowActive(hwnd)
         else
         end

         d = getChildHandle( hwnd , buttonCaption )
         puts ("clickWindowsButton: handle for button: " + buttonCaption + " is " + d.to_s )

         if d != -1 
             makeWindowActive(hwnd)
             clickButtonWithHandle (d)
         else
             return false
         end

         return true

     end

    
    def getChildHandle ( hWnd , childCaption )

         enum_childWindows = @User32['EnumChildWindows' , 'IIPL' ]
         get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
         get_caption = @User32['GetWindowTextA', 'iLsL' ] 
        
         buff = " " * 16
         get_class_name = @User32['GetClassName', 'ILpI']

         bContinueEnum = -1
         enum_childWindows_proc = DL.callback('ILL') {|chwnd,lparam|
              r,rs = get_class_name.call(chwnd, buff, buff.size)
              puts "Found window: " + rs[1].to_s + " Handle: " + chwnd.to_s

              textLength, a = get_caption_length.call(chwnd)
              captionBuffer = " " * (textLength+1)

              t ,  textCaption  = get_caption.call(chwnd, captionBuffer  , textLength+1)    
              puts "Caption =" +  textCaption[1].to_s

              if /#{childCaption}/ =~ textCaption[1].to_s then
                  return chwnd
              end
              bContinueEnum
         }
         r  = enum_childWindows.call(hWnd, enum_childWindows_proc  ,0)
         return -1

    end



    
    def getStaticText(caption)
        return getStaticTextFromWindow(caption, -1)
    end

    def getStaticText_hWnd (hWnd)
        return getStaticTextFromWindow("" , hWnd)
    end


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
         enum_childWindows_proc = DL.callback('ILL') {|hWnd,lparam|
              r,rs = get_class_name.call(hWnd, buff, buff.size)
              puts "Found window: " + rs[1].to_s + " Handle: " + hWnd.to_s

              if rs[1].to_s == "Static"  # there must be a better way of detecting this

                  textLength, a = get_caption_length.call(hWnd)
                  captionBuffer = " " * (textLength+1)

                  t ,  textCaption  = get_caption.call(hWnd, captionBuffer  , textLength+1)    
                  #puts "Caption =" +  textCaption[1].to_s
                  staticText << textCaption[1].to_s
              end
              bContinueEnum
         }
         r  = enum_childWindows.call(hWnd, enum_childWindows_proc  ,0)
         return staticText
    end


    def getHandleOfControl (hWnd , controlClass, position )

         # returns the handle (or -1 if its not found) of the nth control of this class
         enum_childWindows = @User32['EnumChildWindows' , 'IIPL' ]
         get_caption_length = @User32['GetWindowTextLengthA' ,'LI' ]    # format here - return value type (Long) followed by parameter types - int in this case -      see http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/ext/dl/doc/dl.txt?
         get_caption = @User32['GetWindowTextA', 'iLsL' ] 
        
         control_hWnd = []

         buff = " " * 16
         get_class_name = @User32['GetClassName', 'ILpI']

         bContinueEnum = -1
         enum_childWindows_proc = DL.callback('ILL') {|hWnd,lparam|
              r,rs = get_class_name.call(hWnd, buff, buff.size)
              puts "Found window: " + rs[1].to_s + " Handle: " + hWnd.to_s

              if rs[1].to_s == controlClass  # there must be a better way of detecting this

                  # we have found a control of the specified type - add it to an array of hwnd
                  control_hWnd << hWnd
                
              end
              bContinueEnum
         }
         r  = enum_childWindows.call(hWnd, enum_childWindows_proc  ,0)
         controlHwnd = control_hWnd[position]
         if controlHwnd == nil then
            controlHwnd = -1
         end
         
         return controlHwnd 
    end


    def setComboBoxText(hWnd , textToSet)

        send_message = @User32['SendMessage',  'ILISS']  
        r  ,rs  = send_message.call(hWnd , WM_SETTEXT , '' ,  textToSet   )
        puts 'send message returned: ' + r.to_s 
     
    end

    def setTextBoxText(hWnd , textToSet)

        send_message = @User32['SendMessage',  'ILISS']  
        r  ,rs  = send_message.call(hWnd , WM_SETTEXT ,   '' ,    textToSet   )
        puts 'setTextBoxText: send message returned: ' + r.to_s 
     
    end

    def getControlText( hWnd)
         buff = " " * 256

        send_message = @User32['SendMessage',  'ILIIS']  
        r  ,rs  = send_message.call(hWnd , WM_GETTEXT , 256 , buff )
        puts 'send message returned: ' + r.to_s + ' text is: ' + buff.to_s
        return buff.to_s
    end



    def getWindowTitle(hWnd )
        # get the title for the specified hwnd

         buff = " " * 256
        getWindowText = @User32['GetWindowText' , 'ILSI']
        r , rs = getWindowText.call( hWnd , buff , 256 )
        puts 'send message returned: ' + r.to_s + ' text is: ' + buff.to_s
        return buff.to_s

    end





    # file requester methods
    def getTextValueForFileNameField( parenthWnd  ) 

        # this sets the filename field to text to set

        # get the handle of the nth control that is a combo box
        f = getHandleOfControl(parenthWnd, "ComboBox" , 1 )

        puts "Handle for filename field is: " + f.to_s

        if f == -1 then
            puts "Unable to obtain handle for filename chooser"
        else
            # we can now send it some messages
            return getWinText(f )
        end
    end


    def setTextValueForFileNameField( parenthWnd , textToSet ) 

        # this sets the filename field to text to set

        # get the handle of the nth control that is a combo box
        f = getHandleOfControl(parenthWnd, "Edit" , 0 )

        puts "Handle for filename field is: " + f.to_s

        if f == -1 then
            puts "Unable to obtain handle for filename chooser"
            return false
        else
            # we can now send it some messages
            setComboBoxText(f , textToSet)
            return true
        end
    end





end #winClicker

require 'fox12'
require 'fox12/colors'
include Fox


require 'win32ole'
require 'ftools'
require 'FileUtils'
include FileUtils::Verbose
require 'rbconfig'
    



# Copy files from a directory to another directory
def copy_file( from , to )
    c = File.cp(from , to, true)
    if !c
        puts "Problem copying #{from}"
        exit
    end
end


# Creates a new start menu shortcut under Programs > Watir
def make_startmenu_shortcut(name , targetURL )
    #http://msdn.microsoft.com/library/default.asp?url=/library/en-us/script56/html/wsobjwshshortcut.asp
    wshShell = WIN32OLE.new("WScript.Shell")
    strStartMenu = wshShell.SpecialFolders("AllUsersStartMenu")
    d = File.makedirs(strStartMenu + '/Programs/Watir/' )
    oShellLink = wshShell.CreateShortcut(strStartMenu +  '\\Programs\\' + "watir\\#{name}.lnk")
    oShellLink.TargetPath =  targetURL 
    oShellLink.WindowStyle = 1
    oShellLink.Hotkey = "CTRL+SHIFT+F"
    oShellLink.Description = name
    oShellLink.WorkingDirectory = strStartMenu 
    oShellLink.Save
    wshShell = nil
end

# Creates a new desktop shortcut with name and targetURL
def make_desktop_shortcut( name , targetURL )
    wshShell = WIN32OLE.new("WScript.Shell")
    strDesktop = wshShell.SpecialFolders("Desktop")
    oShellLink = wshShell.CreateShortcut(strDesktop +  '\\' + name +  '.lnk')
    oShellLink.TargetPath =  targetURL 
    oShellLink.WindowStyle = 1
    oShellLink.Hotkey = "CTRL+SHIFT+F"
    oShellLink.Description = name
    oShellLink.WorkingDirectory = strDesktop
    oShellLink.Save
    wshShell = nil
end


# Directory browser
def directoryBrowser(application, fileName)
    dlg = FXDirDialog.new(application, "Please select Watir install directory")
    dlg.directory = fileName
    
    if dlg.execute == 1
        return dlg.directory 
    else
        return nil
    end   
end

# Load and return FXGIFIcon
def loadGifIcon(application, filename) 
    begin
        icon = nil
        file = File.dirname(__FILE__) + "/" + filename
       
        puts file
       
        File.open(file.to_s, "rb") { |f|
            icon = FXGIFIcon.new(application, f.read, 0, 0, 16, 16) 
        }
        icon
    rescue
        raise RuntimeError, "Couldn't load icon: #{file}"
    end
end


# This method copies samples, unittests, documentation and Rdocs to the selected directory 'dirSelected'
# A start menu item and desktop icon will be created if 'startMenu' and 'deskTop' are true
def install(dirSelected, startMenu, deskTop)
    puts "Going to install to #{dirSelected} with startMenu=#{startMenu}  desktop=#{deskTop}"

    siteLib = Config::CONFIG['sitelibdir']

    # copy the watir libs to siteLib 
    puts "Copying Files"
    d = File.makedirs(siteLib + '/watir/')
    copy_file( 'watir.rb' , siteLib )
    FileUtils.cp_r('watir', siteLib, {:verbose=> true} )

    # copy the samples to dirSelected
    d = File.makedirs(dirSelected)
    FileUtils.cp_r('examples' , dirSelected, {:verbose=> true} )

    # copy the unittests to dirSelected
    FileUtils.cp_r('unitTests' , dirSelected, {:verbose=> true} )

    # copy the documentation to dirSelected
    FileUtils.cp_r('doc' , dirSelected, {:verbose=> true} )
    
    # copy the Rdocs to dirSelected
    FileUtils.cp_r('rdoc', dirSelected, {:verbose=> true} )

    # make shortcuts if the flags are true
    puts "Creating start menu shortcuts" if startMenu
    make_startmenu_shortcut( "Watir Documentation" , dirSelected + "/doc/watir_user_guide.html" ) if startMenu 
    make_startmenu_shortcut( "RDocs", dirSelected + "/rdoc/index.html" ) if startMenu
    
    puts "Creating desktop shortcuts" if deskTop
    make_desktop_shortcut( "Watir Documentation" , dirSelected + "/doc/watir_user_guide.html" )   if deskTop
    make_desktop_shortcut( "RDocs", dirSelected + "/rdoc/index.html" ) if deskTop

end



# Get info from client computer
homeDrive = ENV["HOMEDRIVE"]
bonus_location = homeDrive + "/watir_bonus/"   # the default bonus location


# Creat an FXApplication
application = FXApp.new("mainWindow", "Watir Installer")    
main = FXMainWindow.new(application, "Watir Installer", nil, nil, DECOR_ALL, 0, 0, 380, 150)

# Load mini icons
icon=loadGifIcon(application, "watir.gif")
main.setMiniIcon(icon)
        

# Text book - can add additional information here
infoTextValue = "\n Choose an installation path"
infoTextBox = FXLabel.new(main, infoTextValue, nil, LAYOUT_SIDE_TOP | JUSTIFY_LEFT)


    
# Directory browsing
browseFrame = FXHorizontalFrame.new(main)
browseText = FXTextField.new(browseFrame, 50)
browseText.text=bonus_location                               # set browserText to default directory
browseButton = FXButton.new(browseFrame, "Browse...", nil, application)
browseButton.connect(SEL_COMMAND) do |sender, sel, checked|    
    dirSelected = directoryBrowser(main, browseText.text)
    if dirSelected != nil
        browseText.text = dirSelected  # set browseText to new directory
    end
end

 
# Create a verticle frame for Checkboxes and Install Button
vFrame = FXVerticalFrame.new(main)



# check boxes for desktop and start menu
desktopIcon = FXCheckButton.new(vFrame, "Desktop Icon", nil)
desktopIcon.checkState = true

startMenuShortcut = FXCheckButton.new(vFrame, "Start Menu Shortcut\n", nil)
startMenuShortcut.checkState = true


# install button
installButton = FXButton.new(vFrame, "Install", nil, application, BUTTON_NORMAL)
installButton.connect(SEL_COMMAND) do |sender, sel, checked|    
    install(browseText.text, desktopIcon.checkState, startMenuShortcut.checkState)
    puts "Installation Completed"
    application.exit()   
end



application.create()
main.show(PLACEMENT_SCREEN)
application.run()

# Support both versions of fxRuby
require 'rubygems'
begin
    require 'fox'
    require 'fox/colors'
rescue Exception
    begin
        require 'fox12'
        require 'fox12/colors'
    rescue Exception
        puts "Installer can not be executed on your system."
        exit
    end
end

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
    d = File.makedirs(strStartMenu + '\\Programs\\Watir\\' )
    oShellLink = wshShell.CreateShortcut(strStartMenu +  '\\Programs\\' + "watir\\#{name}.lnk")
    oShellLink.TargetPath =  targetURL 
    oShellLink.WindowStyle = 1
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
        file = File.dirname(__FILE__) + "\\" + filename
       
        puts file.gsub("/" , "\\")
       
        File.open(file.to_s, "rb") { |f|
            icon = FXGIFIcon.new(application, f.read, 0, 0, 16, 16) 
        }
        icon
    rescue
        raise RuntimeError, "Couldn't load icon: #{file}"
    end
end


# This method copies samples, unittests, documentation and Rdocs to the selected directory 'dirSelected'
# A start menu item and desktop icon will be created if 'startMenu' and 'desktop' are true
def install(dirSelected, startMenu, desktop , register_AutoIt )
    puts "Going to install to #{dirSelected} with startMenu=#{startMenu} and desktop=#{desktop}"

    siteLib = (Config::CONFIG['sitelibdir']).gsub("/" , "\\")
    watir_sub_dir = siteLib + '\\watir\\'

    # copy the watir libs to siteLib 
    puts "Copying Files"
    d = File.makedirs(watir_sub_dir )
    copy_file( 'watir.rb' , siteLib)
    FileUtils.cp_r('watir', siteLib, {:verbose=> true} )

    # copy the samples to dirSelected
    d = File.makedirs(dirSelected)
    FileUtils.cp_r('examples' , dirSelected, {:verbose=> true} )

    # copy the unittests to dirSelected
    FileUtils.cp_r('unitTests' , dirSelected, {:verbose=> true} )

    # copy the documentation to dirSelected
    FileUtils.cp_r('doc' , dirSelected, {:verbose=> true} )
    
    # copy the Rdocs to dirSelected
    begin
        FileUtils.cp_r('rdoc', dirSelected, {:verbose=> true} )
    rescue # in case being installed from dev (when there are no rdocs)
        puts 'Rdoc not installed'
    end

    # Create start menu shortcut
    if startMenu==1
        puts "Creating start menu shortcuts"
        make_startmenu_shortcut( "Documentation" , dirSelected + "\\doc\\index.html" ) 
        make_startmenu_shortcut( "User Guide" , dirSelected + "\\doc\\watir_user_guide.html" ) 
        make_startmenu_shortcut( "Sample Test" , dirSelected + "\\doc\\example_testcase.html" ) 
        make_startmenu_shortcut( "API Reference", dirSelected + "\\rdoc\\index.html" )
    end
    
    # Create desktop shortcut
    if desktop==1
        puts "Creating desktop shortcuts"
        make_desktop_shortcut( "Watir Documentation" , dirSelected + "\\doc\\index.html" ) 
        make_desktop_shortcut( "Watir User Guide" , dirSelected + "\\doc\\watir_user_guide.html" ) 
        make_desktop_shortcut( "Watir Sample Test" , dirSelected + "\\doc\\example_testcase.html" ) 
        make_desktop_shortcut( "Watir API Reference", dirSelected + "\\rdoc\\index.html" ) 
    end

    if register_AutoIt==1
    
        # register the autoit dll
        # this doesnt seem to return any useful error levels, so Im going to display the regsvr dialog box
        system("regsvr32.exe #{watir_sub_dir}AutoItX3.dll")

        make_startmenu_shortcut( "AutoIt Reference", watir_sub_dir+ "\\AutoItX.chm" ) if startMenu==1
    end
end

# Get info from client computer
homeDrive = ENV["HOMEDRIVE"]
bonus_location = homeDrive + "\\watir_bonus\\"   # the default bonus location

# Creat an FXApplication
application = FXApp.new("mainWindow", "Watir Installer")    
main = FXMainWindow.new(application, "Watir Installer", nil, nil, DECOR_ALL, 0, 0, 380, 250)

# Load mini icons
icon = loadGifIcon(application, "watir.gif")
main.setMiniIcon(icon)
        
# Text book - can add additional information here
infoTextValue = "\n Choose an installation path"
infoTextBox = FXLabel.new(main, infoTextValue, nil, LAYOUT_SIDE_TOP | JUSTIFY_LEFT)
    
# Directory browsing
browseFrame = FXHorizontalFrame.new(main)
browseText = FXTextField.new(browseFrame, 50)
browseText.text = bonus_location                               # set browserText to default directory
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

installAUtoIt = FXCheckButton.new(vFrame, "Install AutoIt\n", nil)
installAUtoIt.checkState = true

# install button
installButton = FXButton.new(vFrame, "Install", nil, application, BUTTON_NORMAL)
installButton.connect(SEL_COMMAND) do |sender, sel, checked|    
    install(browseText.text, startMenuShortcut.checkState, desktopIcon.checkState ,installAUtoIt.checkState  )
    puts "Installation Completed"
    application.exit()   
end

application.create()
main.show(PLACEMENT_SCREEN)
application.run()

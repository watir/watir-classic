#
#  Installer for Watir
#

def getNewLocation( forWhat, default)
    puts "New location for #{forWhat}: [ #{default} ] "
    n = gets.chomp!
    n = default if n == ""
    return n
end

def getBooleanOption(label, default)
    n = nil
    while n != 'true' and n != 'false'
        puts "New value for #{label}: [#{default}] "
        n = gets.chomp!.downcase
        n = default.to_s if n == ""
    end
    return false if n == "false"
    return true if n == "true"
    return nil # should never execute
end

def copyFile( from , to )
    c = File.cp(from , to, true)
    if !c
        puts "Problem copying #{from}"
        exit
    end
end

def showBanner( bonusLocation , desktopIcon , startMenuIcon )

    puts "\n"
    puts "*******************************************************************************"
    puts "*                                                                             *"
    puts "* Installer for WATIR                                                         *"
    puts "*                                                                             *"
    puts "*  These settings will be used, press c and then enter to                     *"
    puts "*  change them or just press enter to use these defaults.                     *"
    puts "*                                                                             *"
    puts "*  Bonus files include examples, documentation and unit tests.                *"
    puts "*  " + ("Bonus files:     " + bonusLocation.gsub("/" , "\\")).ljust(75) + "*"
    puts "*                                                                             *"
    puts "*  Create a desktop shortcut:    " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*  Create a start menu shortcut: " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*                                                                             *"
    puts "*******************************************************************************"

    n = gets.chomp!
    return n
end

def makeStartMenuShortCut( name , targetURL )

    #http://msdn.microsoft.com/library/default.asp?url=/library/en-us/script56/html/wsobjwshshortcut.asp
    wshShell = WIN32OLE.new("WScript.Shell")
    strStartMenu = wshShell.SpecialFolders("AllUsersStartMenu")
    d = File.makedirs(strStartMenu + '/Programs/watir/' )
    oShellLink = wshShell.CreateShortcut(strStartMenu +  '\\Programs\\' + "watir\\#{name}.lnk")
    oShellLink.TargetPath =  targetURL 
    oShellLink.WindowStyle = 1
    oShellLink.Hotkey = "CTRL+SHIFT+F"
    oShellLink.Description = name
    oShellLink.WorkingDirectory = strStartMenu 
    oShellLink.Save
    wshShell = nil
end

def makeDeskTopShortCut( name , targetURL )

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


require 'win32ole'
require 'ftools'
require 'FileUtils'
include FileUtils::Verbose

require 'rbconfig'
siteLib = Config::CONFIG['sitelibdir']
display_lib = siteLib.gsub("/" , "\\")

# defaults
homeDrive = ENV["HOMEDRIVE"]
bonusLocation = homeDrive + "/watir_bonus/"
deskTop  = true
startMenu = true

n = showBanner(bonusLocation , deskTop , startMenu  )
while n.downcase == "c"
    puts "New directories selected!"
    bonusLocation  = getNewLocation("Bonus Files"    , bonusLocation.gsub("/" , "\\"))
    deskTop = getBooleanOption("Create a desktop shortcut", deskTop)
    startMenu = getBooleanOption("Create a start menu shortcut" , startMenu)
    n = showBanner(bonusLocation , deskTop , startMenu)
end

# TODO: check to see if stuff already exists

# copy the watir libs to siteLib 
puts "Copying Files"
d = File.makedirs(siteLib + '/watir/' )
copyFile( 'watir.rb' , siteLib )
copyFile( 'watir/winClicker.rb' , siteLib + '/watir/' )
copyFile( 'watir/clickJSDialog.rb' , siteLib + '/watir/' )
copyFile( 'watir/testUnitAddons.rb' , siteLib + '/watir/' )

# copy the samples
d = File.makedirs(bonusLocation  )
FileUtils.cp_r('examples' , bonusLocation, {:verbose=> true} )

# copy the unittests
FileUtils.cp_r('unitTests' , bonusLocation, {:verbose=> true} )

# copy the documentation
FileUtils.cp_r('doc' , bonusLocation, {:verbose=> true} )

# make shortcuts
puts "Creating Shortcuts" if startMenu or deskTop
makeStartMenuShortCut( "Watir Documentation" , bonusLocation + "/doc/watir_user_guide.html" ) if startMenu 
makeDeskTopShortCut( "Watir Documentation" , bonusLocation + "/doc/watir_user_guide.html" )   if deskTop


#
#
#  Installer for Watir
#


def getNewLocation( forWhat, default)

    puts "New location for #{forWhat}: [ #{default} ] "
    n = gets.chomp!
    n = default if n == ""
    return n
end

def getTrueFalseOption( forWhat , default)
    puts "New value for #{forWhat}: [#{default}] "
    n = gets.chomp!
    n = default if n == ""
    return n   
end


def copyFile( from , to )

    c = File.cp(from , to, true)
    if !c
        puts "Problem copying #{from}"
        exit
    end
end

def toTrueFalse( n )
   return false if n.downcase == "false"
   return true if n.downcase == "true"
   return nil
end


def showBanner( unitTestLocation , sampleLocation , docLocation , desktopIcon , startMenuIcon )


    puts "\n\n\n\n\n\n"
    puts "********************************************************************************"
    puts "*                                                                              *"
    puts "* Installer for WATIR                                                          *"
    puts "*                                                                              *"
    puts "*   These settings will be used, press c and then press return to              *"
    puts "*   change them or just press enter to use these                               *"
    puts "*                                                                              *"
    puts "*   " + ("unittests install location:     " + unitTestLocation.gsub("/" , "\\")).ljust(75) + "*"
    puts "*   " + ("samples install location:       " + sampleLocation.gsub("/" , "\\")).ljust(75) + "*"
    puts "*   " + ("documentation install location: " + docLocation.gsub("/" , "\\")).ljust(75) + "*"
    puts "*                                                                              *"
    puts "*                                                                              *"
    puts "*   Create a desktop shortcut:    " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*   Create a start menu shortcut: " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*                                                                              *"
    puts "********************************************************************************"

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

homeDrive = ENV["HOMEDRIVE"]
watir_base = homeDrive + "/watir_install_test/"

require 'rbconfig'
siteLib = Config::CONFIG['sitelibdir']
display_lib = siteLib.gsub("/" , "\\")


docLocation = watir_base  + "doc/"
exampleLocation= watir_base + "examples/"
unitTestLocation = watir_base + "unittests/"

watir_install_location = watir_base

deskTop  = true
startMenu = true

n = showBanner(unitTestLocation , exampleLocation   , docLocation , deskTop , startMenu  )


while n.downcase == "c"
    puts "New directories selected!"
    unitTestLocation  = getNewLocation("Unit Tests"    , unitTestLocation.gsub("/" , "\\"))
    docLocation       = getNewLocation("Documentation" , docLocation.gsub("/" , "\\")     )
    exampleLocation   = getNewLocation("Examples"      , exampleLocation.gsub("/" , "\\") )
    deskTop  = getTrueFalseOption("Create A desktop Shortcut" , deskTop) 
    while !( deskTop.to_s.downcase == "true" or deskTop.to_s.downcase == "false" )
        deskTop  = getTrueFalseOption("Create A desktop Shortcut" , deskTop) 
    end
    deskTop = toTrueFalse( deskTop )
    startMenu= getTrueFalseOption("Create A startmenu Shortcut" , startMenu)
    while !( startMenu.to_s.downcase == "true" or startMenu.to_s.downcase == "false" )
        startMenu  = getTrueFalseOption("Create A StartMenu Shortcut" , deskTop) 
    end
    startMenu = toTrueFalse( startMenu)

    n = showBanner(unitTestLocation , exampleLocation   , docLocation , deskTop , startMenu)
end

# check to see if stuff already exists
#
#    eventually.....


# copy the watir libs to siteLib 

puts "Copying Files"
d = File.makedirs(siteLib + '/watir/' )
copyFile( 'watir.rb' , siteLib + '/watir/' )
copyFile( 'winClicker.rb' , siteLib + '/watir/' )
copyFile( 'clickJSDialog.rb' , siteLib + '/watir/' )



# copy the samples
d = File.makedirs(exampleLocation  )
FileUtils.cp_r('examples' ,exampleLocation     )

# copy the unittests
d = File.makedirs(unitTestLocation  )
FileUtils.cp_r('unitTests' ,unitTestLocation  )

# copy the documentation
d = File.makedirs(docLocation       )
FileUtils.cp_r('doc' ,docLocation       )

puts "Creating Shortcuts" if startMenu or deskTop
makeStartMenuShortCut( "Watir Documentation" , docLocation + "doc/watir_user_guide.html" ) if startMenu 
makeDeskTopShortCut( "Watir Documentation" , docLocation + "doc/watir_user_guide.html" )   if deskTop




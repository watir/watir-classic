#
#  Installer for Watir
#

def get_new_location( forWhat, default)
    puts "New location for #{forWhat}: [ #{default} ] "
    n = gets.chomp!
    n = default if n == ""
    return n
end

def get_boolean_option(label, default)
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

def copy_file( from , to )
    c = File.cp(from , to, true)
    if !c
        puts "Problem copying #{from}"
        exit
    end
end

def show_banner( bonus_location , desktopIcon , startMenuIcon )

    puts "\n"
    puts "*******************************************************************************"
    puts "*                                                                             *"
    puts "* Installer for WATIR                                                         *"
    puts "*                                                                             *"
    puts "*  These settings will be used, press c and then enter to                     *"
    puts "*  change them or just press enter to use these defaults.                     *"
    puts "*                                                                             *"
    puts "*  Bonus files include examples, documentation and unit tests.                *"
    puts "*  " + ("Bonus files:     " + bonus_location.gsub("/" , "\\")).ljust(75) + "*"
    puts "*                                                                             *"
    puts "*  Create a desktop shortcut:    " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*  Create a start menu shortcut: " +  desktopIcon.to_s.ljust(45)  + "*"
    puts "*                                                                             *"
    puts "*******************************************************************************"

    n = gets.chomp!.downcase
    return n
end

def make_startmenu_shortcut( name , targetURL )
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


require 'win32ole'
require 'ftools'
require 'FileUtils'
include FileUtils::Verbose

require 'rbconfig'
siteLib = Config::CONFIG['sitelibdir']
display_lib = siteLib.gsub("/" , "\\")

# defaults
homeDrive = ENV["HOMEDRIVE"]
bonus_location = homeDrive + "/watir_bonus/"
deskTop  = true
startMenu = true

while show_banner(bonus_location, deskTop, startMenu) == "c"
    puts "New directories selected!"
    bonus_location  = get_new_location("Bonus Files", bonus_location.gsub("/" , "\\"))
    deskTop = get_boolean_option("Create a desktop shortcut", deskTop)
    startMenu = get_boolean_option("Create a start menu shortcut", startMenu)
end

# TODO: check to see if stuff already exists

# copy the watir libs to siteLib 
puts "Copying Files"
d = File.makedirs(siteLib + '/watir/')
copy_file( 'watir.rb' , siteLib )
FileUtils.cp_r('watir', siteLib, {:verbose=> true} )

# copy the samples
d = File.makedirs(bonus_location)
FileUtils.cp_r('examples' , bonus_location, {:verbose=> true} )

# copy the unittests
FileUtils.cp_r('unitTests' , bonus_location, {:verbose=> true} )

# copy the documentation
FileUtils.cp_r('doc' , bonus_location, {:verbose=> true} )

# make shortcuts
puts "Creating Shortcuts" if startMenu or deskTop
make_startmenu_shortcut( "Watir Documentation" , bonus_location + "/doc/watir_user_guide.html" ) if startMenu 
make_desktop_shortcut( "Watir Documentation" , bonus_location + "/doc/watir_user_guide.html" )   if deskTop


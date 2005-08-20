# This bat file is used in conjunction with the NSIS installer to determine the location of the local ruby installation
# This file must be next to the watir_installer.exe for the installer to work.
# Kingsley Hendrickse @ thoughtworks (20/08/2005)

ruby -e ' f=File.new("ruby_env.txt", "w") ; f.puts Config::CONFIG[\'sitelibdir\'].gsub("/" , "\\") ; f.close'
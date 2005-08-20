rmdir /s /q doc\rdoc
rdoc --title "Watir API Reference" -A def_wrap -m ReadMe -o "doc/rdoc" --exclude "unittests|examples|install.rb|camel_case.rb|testUnitAddons.rb" 


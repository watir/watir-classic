# note use -Adef_wrap=R -Adef_wrap_guard=R flags to gen RDOC for those things in Elements
rdoc -m ReadMe --title "Watir API Reference" -o doc\rdoc --exclude "unittests|examples|install.rb|camel_case.rb|testUnitAddons.rb" 


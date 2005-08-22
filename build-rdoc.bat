rem   bug: does not include README.txt, need to rewrite as a Rake task, see
rem   http://dev.conio.net/repos/nutmeg/Rakefile for an example
rmdir /s /q doc\rdoc
rem   Note: We have too many arguments to rdoc for the rdoc batch script to work correctly (it won't pass more than 9)
rem   This is why we call ruby directly
ruby c:\ruby\bin\rdoc -t "Watir API Reference" -A "def_wrap=R,def_wrap_guard=R" -m ReadMe -o "doc/rdoc" -x "pkg|rakefile.rb|unittests|examples|install.rb|camel_case.rb|testUnitAddons.rb"	


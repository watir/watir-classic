$WATIR_RDOC_OPTIONS = [] << 
      '--title' << 'Watir API Reference' <<
  		'--accessor' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R' <<
  		'--main' << 'Watir::IE' << 
  		'--exclude' << 'unittests|camel_case.rb|testUnitAddons.rb'
$WATIR_EXTRA_RDOC_FILES = ['readme.rb', 'changes.rb', 'license.rb'] 		


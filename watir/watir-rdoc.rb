$WATIR_RDOC_OPTIONS = [] << 
      '--title' << 'Watir API Reference' <<
  		'--accessor' << 'def_wrap=R,def_wrap_guard=R,def_creator=R,def_creator_with_default=R' <<
  		'--main' << 'Watir::IE' << 
  		'--exclude' << 'unittests|camel_case.rb'
$WATIR_EXTRA_RDOC_FILES = ['lib/readme.rb', 'lib/changes.rb', 'lib/license.rb'] 		


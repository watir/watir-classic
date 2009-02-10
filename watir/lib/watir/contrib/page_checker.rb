#  This module includes checkers which are run on every page load
# 
#  In order to use this module, add a require to one of your test scripts: 
#  require 'watir/contrib/page_checker' 
#  To add checkers, call the ie.add_checker method
#
#  ie.add_checker(PageCheckers::NAVIGATION_CHECKER)
#
#  Checkers are Ruby proc objects which are called within Watir::IE and passed 
#  the current instance of ie. 

module PageCheckers        

	# This checker iterates through  the current document including any frames
	# and checks for http errors, 404, 500 etc
	NAVIGATION_CHECKER = lambda do |ie|
		if ie.document.frames.length > 1
			1.upto ie.document.frames.length do |i|
				begin
					ie.frame(:index, i).check_for_http_error
				rescue Watir::Exception::UnknownFrameException
					# frame can be already destroyed
				end          
			end
		else
			ie.check_for_http_error
		end
	end
end

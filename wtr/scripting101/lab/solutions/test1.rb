require 'toolkit'
start_ie
login_form = forms[0]
login_form.name = "STANZ"
login_form.submit
wait

if $iec.locationname != "Stanz's Timeclock"
	print "FAIL - #{$iec.locationname}"
end













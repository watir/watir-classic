require 'toolkit'
start_ie("http://localhost:8080")
login_form = get_forms[0]
login_form.name = "STANZ"
login_form.submit
@iec.wait

if @iec.locationname != "Stanz's Timeclock"
	print "FAIL - #{@iec.locationname}"
end













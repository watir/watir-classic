require 'win32ole'

ie = WIN32OLE.new('InternetExplorer.Application')
ie.visible = true
ie.gohome
ie.navigate "http://google.com"

while ie.busy
end

# sometimes this isn't necessary, but I've found in some cases ie.busy
# returns too quickly. But checking for READYSTATE_COMPLETE by itself isn't
# enough, because the browser won't go out of READYSTATE_COMPLETE quickly
# enough just after a new navigate call.
READYSTATE_COMPLETE = 4
until ie.readyState == READYSTATE_COMPLETE
end

form = ie.document.forms(0)
form.q.value = 'web testing ruby'
form.submit

# time clock test


LINE="-------------------------------------------------------------------------------------------------------\n\n"
URL = "http://localhost:8080"



require 'helpers'
require 'IEController'
require 'tc_methods'

userName = "faee"

$debuglevel = 3
ie = IEController.new()

puts LINE

clock =TimeClockTestCode.new(ie )
job = Jobs.new(ie ,userName  )

puts LINE

clock.startTimeClock( URL )
clock.loginToTimeClock(userName )

puts LINE

if Util.onFirstJobPage?(ie )
    job.createFirstJob("one")
end

puts LINE

# start the day
clock.startTheDay

puts LINE

# create a new job
jobName = "2_-_Its_getting_Late"
job.createJob(jobName)

# start the job
a, messages = job.startJob(jobName)
if !a
    displayMessages(messages)
end

puts LINE

job.getRecentRecords
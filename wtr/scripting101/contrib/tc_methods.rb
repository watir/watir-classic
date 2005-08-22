class TimeClockTestCode

    def initialize(ie)
        @ie = ie
    end

    def startTimeClock( url )
        @ie.goto( url )
    end

    def log(s)
        puts s
    end

    def loginToTimeClock( loginName )

       messages = []

        # we store the name in a instance var, as we want to check some other pages
        @tcOwner = loginName.capitalize 

        # we assume the time clock is running
        if !@ie.pageContainsText("Timeclock Login Page")
            log "Couldnt be sure I was on the login page!"
            exit
        end

        a, messages = @ie.setField("name" , loginName  , "" , "")
        if a

            # we must now submit the form
            # we would usually click a button to do that, but here we would press enter
            #  we have to do @ie.getIE.document.forms[0].submit()
            #  I personally dont like that as its not what a user would do.

            @ie.getIE.document.forms["0"].submit()

            # we need to wait for IE to load
            @ie.waitForIE

            # check we went to the correct page

            if  Util.onClockMainPage?(@ie , @tcOwner)
                return true, messages  
            elsif Util.onFirstJobPage?(@ie )
                return true, messages
            end

            return false, ["Not sure we went to the correct page"]

            
        else
            l = "Problem with the login field"
            log l
            messages << l
            return false, messages
        end

        

    end


    def startTheDay()

        return false, ["couldnt be sure I was on the clock main page "] if !Util.onClockMainPage?(@ie ,  @tcOwner)

        messages = []
        a, messages = @ie.clickButtonWithCaption("Start The Day" , "" , "" )
        if !a
            l = "problem with the start the day button"
            puts l
            messages << l
            return false, messages
        end

        # did we really start the day?
        return true , messages if @ie.isButtonOnPage_Caption("Stop the Day" , "" )

        return false, ["wasnt sure the day was started correctly"]
        
    
    end



    def stopTheDay()

        return false, ["couldnt be sure I was on the clock main page "] if !Util.onClockMainPage?(@ie)

        messages = []
        a, messages = @ie.clickButtonWithCaption("Stop The Day" , "" , "" )
        if !a
            l = "problem with the stop the day button"
            puts l
            messages << l
            return false, messages
        end

        # did we really start the day?
        return true , messages if @ie.isButtonOnPage_Caption("Start the Day" , "" )

        return false, ["wasnt sure the day was started correctly"]
    
    end



end

class Util

    def Util.onClockMainPage?(ie , tcOwner )
       return  ie.pageContainsText( tcOwner + "'s Timeclock" , "" )
    end

    def Util.onFirstJobPage?(ie )
        return ie.pageContainsText("Create the First Job")
    end

    def Util.getErrorText(ie)

        pageText = ie.getFrameHTML()
        re = /<P style="COLOR: #009900">(.*?)<\/P>/
 
        m = pageText.match(re)
        return nil if m==nil

        errorText = m[1]

    end

end



class Jobs

    def initialize(  ie , loginName  )
        @ie = ie
        @loginName   = loginName  
    end

    def createJob(  jobName)

        # we assume we are in the correct place

        a, messages = @ie.setField("name", jobName , @ie.getFormIndexFromAction("job")  ) 
        if !a 
            l = "Problem creating a new job"
            log l 
            messages << l 
            return false, messages
        end

        # now submit the form

        @ie.getIE.document.forms[ @ie.getFormIndexFromAction("job").to_s  ].submit()

        # we need to wait for IE to load
        @ie.waitForIE


    end

    def createFirstJob( jobName ,     backGroundJob = IEController::CHECKBOX_CHECKED )


        if !@ie.pageContainsText("Create the First Job")


            puts "COuldnt be sure I was on the Create the First Job page!"
            exit
        end

        a, messages = @ie.setField("name" , jobName, "" , "")
        if !a
            log "Problem with the login field"
            return false, messages
        end
        a, messages = @ie.setCheckBox("background" , "" , backGroundJob , "" , "" )
        if !a
            log "Problem with the checkbox"
            displayMessages(messages)
            return false, messages
        end


        # submit the form
        @ie.getIE.document.forms[ "0" ].submit()

        # we need to wait for IE to load
        @ie.waitForIE


        # we should go to the main page

        if     Util.onClockMainPage?(@ie , @loginName )
            return true, messages
        end
        return false, [" not sure we went to the correct page"]
    end

    def startJob(jobToStart)
        # we assume we are on the correct page
        a, messages = @ie.clickButtonWithCaption( jobToStart )
        if !a
            l = " problem with the button to start the job - #{jobToStart}" 
            puts l
            messages << l
            return false, l
        end

        # did the job really start?
        if !@ie.pageContainsText("Job '#{jobToStart}' started")
            l = "Problem starting job #{jobToStart}"
            puts l
            messages << l
            m = Util.getErrorText(@ie)
            messages << "Reason: #{ m }"
            return false, messages
        end
 
        return true, messages
    end
   
    def getRecentRecords()

        records = HTMLHelpers.tableToArray( @ie ,  "Recent Records" , true )
        if records

            records.each do |r|
                r.each do|n|
                    puts n.to_s 
                end
            end
        else
            log "Problem getting the records"
        end
    end

end



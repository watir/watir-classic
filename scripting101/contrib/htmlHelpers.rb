#
#   This file contains methods that help us deal with HTML
#
#


# This is the main class for HTML helpers
#
class HTMLHelpers

    attr_reader(:VERSION)
    VERSION = "$Revision$"

    def initialize()
        logVersion
    end

    def logVersion
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil
    end


    # this method is used by the current and control pages. It returns the color for the supplied HTML class, or nil if the class was not found
    #   *  thisClass  is a string
    def HTMLHelpers.getColorForDataFromClass( thisClass )

        return "blue"  if thisClass.downcase == "status-stale"
        return "green" if thisClass.downcase == "status-current"
        return nil

    end

    # this method returns the alarm color associated with an HTML class (red for alarm, black for no alarm) , or nil if the class was not found
    #   *  thisClass is a string
    def HTMLHelpers.getColorForAlarmFromClass( thisClass )


        return "red"  if thisClass.downcase == "is-in-alarm-text"
        return "black"     if thisClass.downcase == "is-not-in-alarm-text"
        return nil

    end


    # this method converts an HTML table of text into an array 
    # fails miserably if there are nested tables, or if there are spanned cells
    #   * ie        - an IEController 
    #   * keyText   - String - looks for this text to locate the table
    #   * frameName - String - the frame to look in
    def HTMLHelpers.tableToArray( ie ,  keyText, headerRow = false , frameName = "" )
    
        pageText = ie.getFrameHTML( frameName)
        
        return nil if pageText.index( keyText ) == nil

        
        tableText = pageText[ pageText.index(keyText) .. pageText.length ]
        re = /<TABLE.*?>(.*?)<\/TABLE>/

        if headerRow
            #puts "Using a header row"
            tableText = pageText

            re = /<TABLE.*?#{keyText}.*?<TR.*?>(.*?)<\/TBODY><\/TABLE>/m
        end

        m = tableText.match(re)

        return nil if m == nil

        tableText = m[1]
        rows = tableText.split("<TR>")

        tableArray = []
        rows.each_with_index do |row , thisRow|
            tableArray[ thisRow ] = []
            cells = row.split("<TD>")
            cells.each_with_index do |c , thisCell|
                c = c.gsub("</TD>" , "")
                c = c.gsub("</TR>"  , "")
                tableArray[thisRow][thisCell] = c
            end
        end

        return tableArray


    end


    # this method returns the html from the current table cell, or nil if it couldnt do it
    #    *  ie            a reference to the IEController
    #    *  frameName     the name of the frame to look in
    #    *  string        the string that we use to search on
    def HTMLHelpers.getCurrentTableCellContents(ie, string , frameName = "" )

        pageText = ie.getFrameHTML( frameName )
  
        # find the text
        textStart = pageText.index(string)
        return nil if textStart == nil
        
        puts "textStart = #{textStart}" if $debuglevel >= 7
  
        # the html will look something like  <td class="a">Contents We Want</td><td class=b>LookForMe
        # the alarms contact page has stuff that prevents a regular expression (seems to be ok now. Peter July 19 2004)
        
        
        # Find <td or dt< (because it is reversed) proceeding the start string 
        truncatePage = pageText[0..textStart]
        reversePage = truncatePage.reverse

        tdStart = reversePage.index(/dt</i) # this index is incorrect because its the reverse page index        
        
        if tdStart == nil
            puts "tdStart is nil"
            return nil
        end
    
        tdStart = textStart - tdStart # this is the corrected start index
        puts "tdStart = #{tdStart}" if $debuglevel >= 7
        
        
        # find </td> starting from textStart
        tdEnd = pageText.index(/<\/td>/i, textStart) 
        puts "tdEnd = #{tdEnd}" if $debuglevel >= 7
        
        # this should be the entire cell
        cellText = pageText[tdStart-2..tdEnd+4]
        
        return cellText
    end
    
    
    
    

    # this method returns the html from the previous table cell, or nil if it couldnt do it
    #    *  ie            a reference to the IEController
    #    *  frameName     the name of the frame to look in
    #    *  startString   the string that we use to start searching on
    def HTMLHelpers.getPreviousTableCellContents(ie,  startString , frameName = "" )

        pageText = ie.getFrameHTML( frameName )
  
        # find the text
        textStart = pageText.index(startString)
        return nil if textStart == nil

        # find the previous <TD   - remember that IE will mangle it
        pageText = pageText[0 .. textStart ]


        # the html will look something like 
        #  <TD class="a">Contents We Want</TD><TD class=b>LookForMe
        # the alarms contact page has stuff that prevents a regular expression

        reversePage = pageText.reverse
        #Find the first <TD  or DT<

        #puts "\n\n\n" + reversePage + "\n\n\n"


        tdStart = reversePage.index("DT<")
        if tdStart == nil
            puts "tdStart is nil"
            return nil
        end

        puts "tdStart = #{tdStart}"

        # find the next <TD>  really its DT<
        tdStart2 = reversePage.index("DT<" , tdStart+1)
        if tdStart2 == nil
            puts "second tdStart is nil"
            return nil
        end
        puts "tdStart2 = #{tdStart2}"

        cellText = reversePage[tdStart .. tdStart2 ].reverse
        # this now contains the end of the first cell and the begining of the second cell
        cellText = cellText[ cellText.index(">")+1 .. cellText.length-11 ]  # -11 is due to </TD><TD> etc

        return cellText
    end


   

    # this method returns the html from the next table cell, or nil if it couldnt do it
    #   *  ie            a reference to the ie controller/ or XML text
    #   *  frameName     the name of the frame to look in
    #   *  startString   the string that we use to start searching on
    def HTMLHelpers.getNextTableCellContents(ie,  startString , frameName = "", cell = 1 )


  
        if ie.is_a?(IEController)
            puts "received IE object" if $debuglevel >= 7
            pageText = ie.getFrameHTML( frameName )
        else
            puts "received HTML" if $debuglevel >=7
            pageText = ie  # if we pass in html text
        end
        
        
        # find the text
        textStart = pageText.index(startString)
        return nil if textStart == nil

        tdStart=textStart
         
        
        #puts tdStart
         
        cell.times do |i|
            tdStart = pageText.index(/<td/i , tdStart+1)   
            return nil if tdStart == nil                       
        end
        
        
        # find the next >
        tdEnd = pageText.index(">" , tdStart)
        return nil if tdEnd == nil
        

     

        # find the closing </TD>

        cellTextEnd = pageText.index(/<\/td>/i , tdEnd)    # make me index(/<\/td>/i , tdEnd) to get rid of case dependencies, so it can be used on email and on the current page
        return nil if cellTextEnd == nil

        cellText = pageText[ tdEnd+1 .. cellTextEnd-1]
        return cellText

    end
    
    

    # this method extracts the text that follows a certain attribute on a certain tag
    # eg: <h2 name=foo>Extract Me</h2>
    # in this case we would supply the tag as h2 and the name attribute as foo and expect Extract Me to be returned
    #   *  ie               a reference to the ie controller
    #   *  tag              the html tag we look for
    #   *  attribute        the attribute of the tag we look for
    #   *  attributeValue   the value of the attribute
    #   *  frameName        the name of the frame to look in
    def HTMLHelpers.extractTextUsingTagAnAttribute(ie, tag, attribute, attributeValue, frameName = "" )

        tagText = nil
        pageText = ie.getFrameHTML( frameName )

        #puts "================================================================="
        #puts pageText
        #puts "=================================================================\n\n\n"
        #puts "Tag: #{tag} attribute #{attribute} value #{attributeValue}"

         re = /<#{tag}[^>]*>[^<]*</i

         linesArray = pageText.scan( re ) 

         if linesArray.length > 0 
             #puts "lines > 0"
             #puts linesArray.join("\n")
             linesArray.each do |l|
                 m = /#{attribute}=#{attributeValue}/i
                 if m.match(l) != nil
                     tagText = />([^<]*)</.match(l)[1]
                 end
             end
         end
         #puts " returning: #{tagText}"
         return tagText
    end

    # this method returns the html for the tag followed by a string, or nil if it couldnt do it
    #   *  ie            a reference to the IEController
    #   *  frameName     the name of the frame to look in
    #   *  startString   the string that we use to start searching on
    def HTMLHelpers.getPreviousHtmlTag(ie,  startString , frameName = "" )

        pageText = ie.getFrameHTML( frameName )

        # find the text
        textStart = pageText.index(startString)
        return "nil" if textStart == nil
        

        # find the previous < 
        pageText = pageText[0 .. textStart ]


        # the html will look something like 
        # <input type=checkbox name="name" value="value>LookForMe


        reversePage = pageText.reverse
        #Find the first >

        #puts "\n\n\n" + reversePage + "\n\n\n"


        tagStart = reversePage.index("<")
        if tagStart == nil
            puts "tagStart is nil"
            return nil
        end
   
        puts "tagStart = #{tagStart}"

        tagText = reversePage[1 .. tagStart ].reverse

        return tagText
    end





    # this method returns the name of the select box that follows the text, or nil if it couldnt do it
    #   *  ie            a reference to the ie controller
    #   *  frameName     the name of the frame to look in
    #   *  startString   the string that we use to start searching on
    #   *  caseSensitive is the text search case sensitive
    # be careful with the case sensitive flag - the IEController may not find items if the cases are different
    def HTMLHelpers.getSelectBoxAfterText(ie, frameName, startString, caseSensitive = true)

        # returns the name of the select box following the supplied text, or nil

        fname = getFunctionName()
        log fname + ' Starting. Looking for drop down after text: ' + startString.to_s  if $debuglevel >= 0


        pageText = ie.getFrameHTML( frameName )
        
        
        pageText.downcase! if caseSensitive == false
        startString.downcase!     if caseSensitive == false

        textToFind = startString
        textStart = pageText.index( textToFind ) 

        if textStart == nil
            log "#{fname} text #{ textToFind }  not found"
            return nil     
        end

        #puts "textStart = #{textStart} "

        # now go forward until we find <Select
        selectStart = pageText.downcase.index("<sel" , textStart )
        if selectStart == nil
            puts "Select not found"
            return nil 
        end

        #puts "selectStart  = #{selectStart }"

        # go forward until we find >

        selectEnd = pageText.index(">" , selectStart )

        #puts "selectEnd = #{selectEnd}"

        # get the text

        selectText = pageText[selectStart..selectEnd]

        #puts "selectText  = #{selectText } "

        # get the name from it

        # re = /name\s*=\s*("|')*\s*([^\1]*)\1/
        # this will match name = 'blah' or name="blah"
        # that re is no good, because of the way ie mangles the page
        # in the case im writing it for iE creates this: <select name=0.1.3.1.1.3.3.7.0.0.12.5.2.3.0.0> (but in uppercase)

        # the result ends in the [2] part of the array ([0] is the complete match, [1] is the internal part(' or " ) [2] is the second bracket


        re = /name\s*=\s*([^>]*)>/

        m = re.match(selectText )

        # for this one, the return is [1]
        
        if m == nil
            log "#{fname} Couldnt find select box name"
            return nil    
        end
        return m[1]

    end


    #this method tries to get the title from the html page
    # returns nil or the title (without the title tags)
    def HTMLHelpers.getTitleTag( pageHTML )
        re = /<title>([^<\/]*)<\/title>/i
        result = nil
        m = re.match(pageHTML)
        if m!= nil
            result = m[1]
        end
        return result
    end
    
    
    # This method returns a WRXCheckBox object, extracted from the page, or nil if it was unable to locate a checkbox with the specified name
    #  *   ie    - instance of the IEController
    #  *   name  - the name of the checkbox to find
    def HTMLHelpers.getCheckBoxWithName( ie, name )
        checkBoxText = HTMLHelpers.getPreviousHtmlTag(ie, name, $contentFrameName)

        checkBox = WRXCheckBox.new
        checkBoxAvailable = checkBox.textToCheckBox(checkBoxText)

        if checkBoxAvailable ==nil
            log "Unable to locate the check box details for text: #{name}"            
            checkBox = nil
        elsif $debuglevel >=6
            log "checkBox name = #{checkBox.name}"
            log "checkBox value = #{checkBox.value}"
            log "checkBox id = #{checkBox.id}"
        end

        return checkBox
    end

end #class







#--
# classes for html objects....
#++





# this class is a ruby representation of a text Field
class WRXTextField

    # the name of the text Field
    attr_accessor :name

    # the value of the text Field
    attr_accessor :value
  
    # the id associated with the text Field
    attr_accessor :id

    # The class version
    VERSION = "$Revision$"

    def initialize()
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil
    end



    # This method attempts to convert the supplied text to text Field attributes
    # return nil if it cant do it
    # This method will probably become some sort of a general HTML parsing class, as its likely to be needed by all of the html objects
    #     * text   - string The text we will try to parse into name, value and ID 
    # name, value or ID will be nil if it failed to parse them
    def textToTextField(text)

        # a radio button looks like this when it comes from IE
        #<INPUT type=Text value='value with a space in it' name=SelectContact >

        # make sure it really is a text
        return nil if text.match("<INPUT type=text") == nil

        # remove the < > from the begining and end of the tag
        text.gsub!(/^</ , "")
        text = text.strip
        text.gsub!(/>$/ , "")

        #this code came from: http://groups.google.ca/groups?dq=&hl=en&lr=&ie=UTF-8&threadm=2hvkirFgmpdiU1%40uni-berlin.de&prev=/groups%3Fhl%3Den%26lr%3D%26ie%3DUTF-8%26oe%3DUTF-8%26group%3Dcomp.lang.ruby
        text.scan(  %r{ (name|value|id)                       =     (?: '((?:[^'\\]|\\')*)' | (\S+) ) }x ) do |m|
        #               match name or val or id   followed by =     match 'xxxx'       or non-space    x means use extended mode 
        #                                                                     ^
        #                                                                     |
        #                                                                     +- note use of ? : | inside the brackets here!!!          
          key = m[0]    # name|value|id
          val = (m[1]||m[2]).gsub(/\\(.)/, '\\1')
          puts "key=#{key}"
          puts "value=#{val}"

          case  key.upcase
              when "NAME"
                  log "Setting name to #{val}"
                  @name = val
              when "ID"
                  @id = val
                  log "Setting ID to #{val}"
              when "VALUE"
                  @value = val
                  log "Setting value to #{val}"
              else
                 log "Unknown key for text Field =  #{key} "
          end #select
        end

    end

end









# this class is a ruby representation of a Radio Button
class WRXRadioButton

    # the name of the radio button
    attr_accessor :name

    # the value of the radio button 
    attr_accessor :value
  
    # the id associated with the radio button  
    attr_accessor :id

    # The class version
    VERSION = "$Revision$"

    def initialize()
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil
    end



    # This method attempts to convert the supplied text to radio button attributes
    # return nil if it cant do it
    # This method will probably become some sort of a general HTML parsing class, as its likely to be needed by all of the html objects
    #     * text   - string The text we will try to parse into name, value and ID 
    # name, value or ID will be nil if it failed to parse them
    def textToRadioButton(text)

        # a radio button looks like this when it comes from IE
        #<INPUT type=radio value='value with a space in it' name=SelectContact >

        # make sure it really is a radio
        return nil if text.match("<INPUT type=radio") == nil

        # remove the < > from the begining and end of the tag
        text.gsub!(/^</ , "")
        text = text.strip
        text.gsub!(/>$/ , "")

        #this code came from: http://groups.google.ca/groups?dq=&hl=en&lr=&ie=UTF-8&threadm=2hvkirFgmpdiU1%40uni-berlin.de&prev=/groups%3Fhl%3Den%26lr%3D%26ie%3DUTF-8%26oe%3DUTF-8%26group%3Dcomp.lang.ruby
        text.scan(  %r{ (name|value|id)                       =     (?: '((?:[^'\\]|\\')*)' | (\S+) ) }x ) do |m|
        #               match name or val or id   followed by =     match 'xxxx'       or non-space    x means use extended mode 
        #                                                                     ^
        #                                                                     |
        #                                                                     +- note use of ? : | inside the brackets here!!!          
          key = m[0]    # name|value|id
          val = (m[1]||m[2]).gsub(/\\(.)/, '\\1')
          puts "key=#{key}"
          puts "value=#{val}"

          case  key.upcase
              when "NAME"
                  log "Setting name to #{val}"
                  @name = val
              when "ID"
                  @id = val
                  log "Setting ID to #{val}"
              when "VALUE"
                  @value = val
                  log "Setting value to #{val}"
              else
                 log "Unknown key for radio button =  #{key} "
          end #select
        end

    end

end






# this class is a ruby representation of a Check Box
class WRXCheckBox

    # the name of the check box
    attr_accessor :name

    # the value of the check box
    attr_accessor :value
  
    # the id associated with the check box
    attr_accessor :id

    # The class version
    VERSION = "$Revision$"

    def initialize()
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil
    end



    # This method attempts to convert the supplied text to check box attributes
    # return nil if it cant do it
    # This method will probably become some sort of a general HTML parsing class, as its likely to be needed by all of the html objects
    #     * text   - string The text we will try to parse into name, value and ID 
    # name, value or ID will be nil if it failed to parse them
    def textToCheckBox(text)

        # a check box looks like this when it comes from IE
        #<INPUT type=checkbox value='value' name=name >

        # make sure it really is a radio
        return nil if text.match("<INPUT type=checkbox") == nil

        # remove the < > from the begining and end of the tag
        text.gsub!(/^</ , "")
        text = text.strip
        text.gsub!(/>$/ , "")

        #this code came from: http://groups.google.ca/groups?dq=&hl=en&lr=&ie=UTF-8&threadm=2hvkirFgmpdiU1%40uni-berlin.de&prev=/groups%3Fhl%3Den%26lr%3D%26ie%3DUTF-8%26oe%3DUTF-8%26group%3Dcomp.lang.ruby
        text.scan(  %r{ (name|value|id)                       =     (?: '((?:[^'\\]|\\')*)' | (\S+) ) }x ) do |m|
        #               match name or val or id   followed by =     match 'xxxx'       or non-space    x means use extended mode 
        #                                                                     ^
        #                                                                     |
        #                                                                     +- note use of ? : | inside the brackets here!!!          
          key = m[0]    # name|value|id
          val = (m[1]||m[2]).gsub(/\\(.)/, '\\1')
          puts "key=#{key}" if $debuglevel >=4
          puts "value=#{val}" if $debuglevel >=4

          case  key.upcase
              when "NAME"
                  log "Setting name to #{val}"
                  @name = val
              when "ID"
                  @id = val
                  log "Setting ID to #{val}"
              when "VALUE"
                  @value = val
                  log "Setting value to #{val}"
              else
                 log "Unknown key for radio button =  #{key} "
          end #select
        end
    end
   


end




# this class is a ruby representation of an html link
class WRXLink

    # the ID associated with the link
    attr_accessor  :id 

    # the name associated with the link
    attr_accessor  :name

    # the HTML of the link
    attr_accessor  :innerHTML

    # the Text of the Link
    attr_accessor  :innerText 

    # the URL the link points to
    attr_accessor  :href 

    # the target of the link
    attr_accessor  :target


    VERSION = "$Revision$"

    def initialize()
        version = "#{self.class} Version is: #{VERSION}"
        log version 
        $classVersions << version unless $classVersions ==nil
    end


    # This method attempts to convert the supplied text to link attributes
    # return nil if it cant do it
    # This method will probably become some sort of a general HTML parsing class, as its likely to be needed by all of the html objects
    #     * text   - string The text we will try to parse into name, url , ID , text
    # name, value or ID will be nil if it failed to parse them
    def textToLink(text)

        # a check box looks like this when it comes from IE
        #<a href = "http://www.blah.com/page" >
        # make sure it really is a radio
        return nil if text.match("<A") == nil

        # get the innerText
        re = />(.*?)</
        m = re.match(text)
        if m!=nil
            log "Setting InnerText to #{m[1]}"
            @innerText = m[1]
        end

        # remove the link text and closing </a>
        text= text[0..text.index(">")]

        # remove the < and >
        text.gsub!(/^</ , "")
        text = text.strip
        text.gsub!(/>$/ , "")


        #this code came from: http://groups.google.ca/groups?dq=&hl=en&lr=&ie=UTF-8&threadm=2hvkirFgmpdiU1%40uni-berlin.de&prev=/groups%3Fhl%3Den%26lr%3D%26ie%3DUTF-8%26oe%3DUTF-8%26group%3Dcomp.lang.ruby
        text.scan(  %r{ (href|name|value|id)                       =     (?: "((?:[^"\\]|\\")*)" | (\S+) ) }x ) do |m|
        #               match name or val or id   followed by =     match 'xxxx'       or non-space    x means use extended mode 
        #                                                                     ^
        #                                                                     |
        #                                                                     +- note use of ? : | inside the brackets here!!!          
          key = m[0]    # name|value|id
          val = (m[1]||m[2]).gsub(/\\(.)/, '\\1')
          puts "key=#{key}" if $debuglevel >=4
          puts "value=#{val}" if $debuglevel >=4

          case  key.upcase
              when "NAME"
                  log "Setting name to #{val}"
                  @name = val
              when "ID"
                  @id = val
                  log "Setting ID to #{val}"
              when "HREF"
                  @href= val
                  log "Setting href to #{val}"
              when "TARGET"
                  @href= val
                  log "Setting target to #{val}"
              else
                 log "Unknown key for link =  #{key} "
          end #select
        end
    end


end



=begin


t =<<TEND
<TABLE cellSpacing=0 cellPadding=3 width="66%" align=center border=1>
<TBODY>
<TR bgColor=#66ffff>
<TD align=middle colSpan=4>Recent Records </TD></TR>
<TR bgColor=#ccffff>
<TD>2_-_Its_getting_Late </TD>
<TD>11:17 PM </TD>
<TD>0.57 hours </TD>
<TD><B>running</B> </TD></TR></TBODY></TABLE>

TEND



records = HTMLHelpers.tableToArray( t , "Recent" , true )

        if records

            records.each do |r|
                r.each do|n|
                    puts n.to_s 
                end
            end
        else
            puts "Problem getting the records"
        end
=end
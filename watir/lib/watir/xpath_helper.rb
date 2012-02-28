module Watir
  module XpathHelper
    # IE inserts some element whose tagName is empty and just acts as block level element
    # Probably some IE method of cleaning things
    # To pass the same to the xml parser we need to give some name to empty tagName
    EMPTY_TAG_NAME = "DUMMY"

    # Functions written for using xpath for getting the elements.
    def xmlparser_document_object
      @xml_parser_doc ||= create_xml_parser_doc
    end

    # Create the Nokogiri object if it is nil. This method is private so can be called only
    # from xmlparser_document_object method.
    def create_xml_parser_doc
      require 'nokogiri'
      if @xml_parser_doc == nil
        htmlSource ="<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<HTML>\n"
        htmlSource = html_source(document.body,htmlSource," ")
        htmlSource += "\n</HTML>\n"
        # Angrez: Resolving Jira issue WTR-114
        htmlSource = htmlSource.gsub(/&nbsp;/, '&#160;')
          begin
            @xml_parser_doc = Nokogiri.parse(htmlSource)
          rescue => e
            output_xml_parser_doc("error.xml", htmlSource)
            raise e
          end
      end
    end

    #Function Tokenizes the tag line and returns array of tokens.
    #Token could be either tagName or "=" or attribute name or attribute value
    #Attribute value could be either quoted string or single word
    def tokenize_tagline(outerHtml)
      outerHtml = outerHtml.gsub(/\n|\r/," ")
      #removing "< symbol", opening of current tag
      outerHtml =~ /^\s*<(.*)$/
      outerHtml = $1
      tokens = Array.new
      i = startOffset = 0
      length = outerHtml.length
      #puts outerHtml
      parsingValue = false
      while i < length do
        i +=1 while (i < length && outerHtml[i,1] =~ /\s/)
        next if i == length
        currentToken = outerHtml[i,1]

        #Either current tag has been closed or user has not closed the tag >
        # and we have received the opening of next element
        break if currentToken =~ /<|>/

        #parse quoted value
        if(currentToken == "\"" || currentToken == "'")
          parsingValue = false
          quote = currentToken
          startOffset = i
          i += 1
          i += 1 while (i < length && (outerHtml[i,1] != quote || outerHtml[i-1,1] == "\\"))
          if i == length
            tokens.push quote + outerHtml[startOffset..i-1]
          else
            tokens.push outerHtml[startOffset..i]
          end
        elsif currentToken == "="
          tokens.push "="
          parsingValue = true
        else
          startOffset = i
          i += 1 while (i < length && !(outerHtml[i,1] =~ /\s|=|<|>/)) if !parsingValue
          i += 1 while (i < length && !(outerHtml[i,1] =~ /\s|<|>/)) if parsingValue
          parsingValue = false
          i -= 1
          tokens.push outerHtml[startOffset..i]
        end
        i += 1
      end
      return tokens
    end

    # This function get and clean all the attributes of the tag.
    def all_tag_attributes(outerHtml)
      tokens = tokenize_tagline(outerHtml)
      #puts tokens
      tagLine = ""
      count = 1
      tokensLength = tokens.length
      expectedEqualityOP= false
      while count < tokensLength do
        if expectedEqualityOP == false
          #print Attribute Name
          # If attribute name is valid. Refer: http://www.w3.org/TR/REC-xml/#NT-Name
          if tokens[count] =~ /^(\w|_|:)(.*)$/
            tagLine += " #{tokens[count]}"
            expectedEqualityOP = true
          end
        elsif tokens[count] == "="
          count += 1
          if count == tokensLength
            tagLine += "=\"\""
          elsif(tokens[count][0,1] == "\"" || tokens[count][0,1] == "'")
            tagLine += "=#{tokens[count]}"
          else
            tagLine += "=\"#{tokens[count]}\""
          end
          expectedEqualityOP = false
        else
          #Opps! equality was expected but its not there.
          #Set value same as the attribute name e.g. selected="selected"
          tagLine += "=\"#{tokens[count-1]}\""
          expectedEqualityOP = false
          next
        end
        count += 1
      end
      tagLine += "=\"#{tokens[count-1]}\" " if expectedEqualityOP == true
      #puts tagLine
      return tagLine
    end

    # This function is used to escape the characters that are not valid XML data.
    def xml_escape(str)
      str = str.gsub(/&/,'&amp;')
      str = str.gsub(/</,'&lt;')
      str = str.gsub(/>/,'&gt;')
      str = str.gsub(/"/, '&quot;')
      str
    end

    def output_xml_parser_doc(name, text)
      file = File.open(name,"w")
      file.print(text)
      file.close
    end

    # Returns HTML Source
    # Traverse the DOM tree rooted at body element
    # and generate the HTML source.
    # element: Represent Current element
    # htmlString:HTML Source
    # spaces:(Used for debugging). Helps in indentation
    def html_source(element, htmlString, spaceString)
      begin
        tagLine = ""
        outerHtml = ""
        tagName = ""
        begin
          tagName = element.tagName.downcase
          tagName = EMPTY_TAG_NAME if tagName == ""
          # If tag is a mismatched tag.
          if !(tagName =~ /^(\w|_|:)(.*)$/)
            return htmlString
          end
        rescue
          #handling text nodes
          if element.toString(0) == '[object Text]'   #IE9 has a different method for getting text
            element_text = element.wholeText
          else
            element_text = element.toString(0)
          end
          htmlString += xml_escape(element_text)
          return htmlString
        end
        #Skip comment and script tag
        if tagName =~ /^!/ || tagName== "script" || tagName =="style"
          return htmlString
        end
        #tagLine += spaceString
        outerHtml = all_tag_attributes(element.outerHtml) if tagName != EMPTY_TAG_NAME
        tagLine += "<#{tagName} #{outerHtml}"

        canHaveChildren = element.canHaveChildren
        if canHaveChildren
          tagLine += ">"
        else
          tagLine += "/>" #self closing tag
        end
        #spaceString += spaceString
        htmlString += tagLine
        childElements = element.childnodes
        childElements.each do |child|
          htmlString = html_source(child,htmlString,spaceString)
        end
        if canHaveChildren
          #tagLine += spaceString
          tagLine ="</" + tagName + ">"
          htmlString += tagLine
        end
        return htmlString
      rescue => e
        puts e.to_s
      end
      return htmlString
    end

    # Method that iterates over IE DOM object and get the elements for the given
    # xpath.
    def element_by_absolute_xpath(xpath)
      curElem = nil
      xpath = xpath.scan(/^.*\/body\[?\d*\]?\/(.*)/).flatten.first
      return unless xpath

      arr = xpath.split("/")
      return nil if arr.length == 0

      doc = document
      curElem = doc.getElementsByTagName("body").item(0)
      lastTagName = arr.last.to_s.upcase

      # lastTagName is like tagName[number] or just tagName. For the first case we need to
      # separate tagName and number.
      lastTagName = lastTagName.scan(/(\w*)\[?\d*\]?/).flatten.first

      arr.each do |element|
        element =~ /(\w*)\[?(\d*)\]?/
        tagname = $1
        tagname = tagname.upcase

        if $2 != nil && $2 != ""
          index = $2
          index = "#{index}".to_i - 1
        else
          index = 0
        end

        allElemns = tagname == "FRAME" ? [curElem] : curElem.childnodes
        next if allElemns == nil || allElemns.length == 0

        allElemns.each do |child|
          begin
            curTag = child.tagName
            curTag = EMPTY_TAG_NAME if curTag.empty?
          rescue
            next
          end

          if curTag == tagname
            index -= 1
            if index < 0
              curElem = child
              break
            end
          end
        end
      end

      curElem.tagName == lastTagName ? curElem : nil rescue nil
    end

    # execute css selector and return an array of (ole object) elements
    def elements_by_css(selector)
      xmlparser_document_object # Needed to ensure Nokogiri has been loaded
      xpath = Nokogiri::CSS.xpath_for(selector)[0]
      elements_by_xpath(xpath)
    end

    # return the first (ole object) element that matches the css selector
    def element_by_css(selector)
      elements_by_css(selector)[0]
    end

    # return the first element that matches the xpath
    def element_by_xpath(xpath)
      elements_by_xpath(xpath)[0]
    end

    # execute xpath and return an array of elements
    def elements_by_xpath(xpath)
      doc = xmlparser_document_object

      # strip any trailing slash from the xpath expression (as used in watir unit tests)
      xpath.chop! if xpath =~ /\/$/

      doc.xpath(xpath).reduce([]) do |memo, element|
        memo << element_by_absolute_xpath(element.path)
      end.compact
    end    

  end
end

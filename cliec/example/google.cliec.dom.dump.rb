require 'google.cliec'

# Google's result page doesn't have ideal html for automation. cliec assists
# with this scenario by providing DOM helper classes. The following script
# executes the previous Google example, then uses the DOM Viewer to dump
# the complete paths to each object in the DOM tree. 

dv = ClIEDomViewer.new(@iec)
File.open('google.dom.dump.txt', 'w') do |f| dv.outputDom(f) end
@iec.close

# Digging through google.dom.dump.txt, we can find the first link here:
#
# [snip]
# nodeName: -HTML-BODY1-DIV1-P1-A1
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text1
# nodeValue: RubyForge: Project Info- 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B1
# nodeName: -HTML-BODY1-DIV1-P1-A1-B1-#text1
# nodeValue: Web
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text2
# nodeValue:# 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B2
# nodeName: -HTML-BODY1-DIV1-P1-A1-B2-#text1
# nodeValue: Testing
# nodeName: -HTML-BODY1-DIV1-P1-A1-#text3
# nodeValue:# with 
# nodeName: -HTML-BODY1-DIV1-P1-A1-B3
# nodeName: -HTML-BODY1-DIV1-P1-A1-B3-#text1
# nodeValue: Ruby
# [snip]
#
# so, we now have a path to the first link: "-HTML-BODY1-DIV1-P1-A1" and we
# can use this in a subsequent script --> see google.cliec.link.click.rb

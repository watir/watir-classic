require 'google.cliec'

dv = ClIEDomViewer.new(@iec)
root = dv.htmlRootNode
dv.buildNodeWrapperTree(root)
link = dv.getNodeWrapperFromPath('HTML-BODY1-DIV1-P1-A1', root)
link.node.click
@iec.wait

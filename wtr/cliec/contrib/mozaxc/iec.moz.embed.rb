require 'cl/iec'

@iec = ClIEController.new
@iec.visible=true
fn = File.join(Dir.pwd, 'ie.embed.html')
@iec.navigate 'file://' + fn
@moz = @iec.document.all.browser1
@moz_doc = @iec.document.all.browser1.document


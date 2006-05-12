require 'cl/iec'

@iec = ClIEController.new
@iec.visible=true
fn = File.join(Dir.pwd, 'ie.embed.html')
@iec.navigate 'file://' + fn
sleep 2
@moz = @iec.document.all.browser1
@moz_doc = @moz.object.document
@moz_doc.write('<html><body>success! written via <a href="http://clabs.org/wtr">IEC</a></body></html>')


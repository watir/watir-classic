require 'iec.moz.embed'

@iec.wait
sleep 10
domv = CLabs::IEC::ClIEDomViewer.new(@moz)
File.open('dom.dump.txt', 'w+') do |f|
  domv.outputDom(f)
end 
@iec.close


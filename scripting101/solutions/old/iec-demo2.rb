require 'cl/iec'
iec = ClIEController.new(true)
iec.navigate ("http://localhost:8080")
form = IEDomFormWrapper.new(iec.form)
sleep 2
form.name = "Marick"
sleep 2
form.submit; iec.wait
lunch = nil; test = nil
10.times do
  all_jobs_form = IEDomFormWrapper.new(iec.document.forms(0))
  all_jobs_form.elements.each {|x| lunch = x if x.value == 'lunch'}
  lunch.click
  sleep 5
  all_jobs_form = IEDomFormWrapper.new(iec.document.forms(0))
  all_jobs_form.elements.each {|x| test = x if x.value == 'test'}
  test.click
  sleep 5
end








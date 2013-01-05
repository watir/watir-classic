#--
# watir/browsers
# Define browsers supported by Watir

Watir::Browser.support :name => 'ie', :class => 'Watir::IE', 
  :library => 'watir-classic/ie', :gem => 'watir-classic',
  :options => [:speed, :visible]

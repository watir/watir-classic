#--
# watir/browsers
# Define browsers supported by Watir

Watir::Browser.support :name => 'ie', :class => 'Watir::IE', 
  :library => 'watir-classic/ie', :gem => 'watir-classic',
  :options => [:speed, :visible, :zero_based_indexing]

Watir::Browser.support :name => 'firefox', :class => 'FireWatir::Firefox',
  :library => 'firewatir'

Watir::Browser.support :name => 'safari', :class => 'Watir::Safari',
  :library => 'safariwatir'

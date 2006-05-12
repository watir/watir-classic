class WSMIndex < WSMComponent

  def actions
    return [
      'View Package', :viewPackage,
      'Edit Package', :editPackage,
      'Add Package', :addPackage
    ]
  end

  def addPackage
    name = self.request: 'Name of new package:'
    card = SMCard.new initialize name: name
    self.editCard: card
    card map: self.squeakMap id: UUID.new
    if card.password.nil? then
      self.setPassword: card
    end
    self.session squeakMap addCard: card
    self.viewCard: card
  end

  def editPackage
    card = self.pickACard
    self.editCard: card
    self.viewCard: card
  end

  def header
    return "Welcome to the web-based SqueakMap Browser
  <p>
  This is an extended example of the Seaside framework;  It requires the SqueakMap package from <a href=\"http://anakin;bluefish;se:8000/gohu/11\">http://anakin;bluefish;se:8000/gohu/11</a>;  Currently, it provides only limited facilities for browsing and editing your local copy of the SqueakMap data;</p>
  <p>Some things you might want to look at in the code:</p>
  
  <ul>
  <li><b>WSMFrame</b> embodies a common pattern in Seaside applications: it provides a permanent navigation bar around a changing embedded child;</li>
  <li><b>WSMCardEditor</b> follows another common pattern - the use of the same component for creating and editing records;</li>
  <li><b>WSMCardList>>report</b> demonstrates the new, unfinished reporting component;</li>
  <li><b>WSMCardEditor>>renderOn:</b> makes use of some of HtmlRenderer''s convenience methods for generating tables and forms;</li>
  <li><b>WSMIndex>>addPackage</b> and other methods are good examples of clean, linear flow, and making appropiate use of the call/answer mechanism;</li>
  </ul>"
  end

  def viewPackage
    self.viewCard: self.pickACard
  end

end


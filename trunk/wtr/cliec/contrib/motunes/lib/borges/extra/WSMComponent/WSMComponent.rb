class WSMComponent < Component

  @@sandbox = nil

  def actions
    return []
  end

  def checkPasswordFor(aCard)
    return aCard.password.nil? || self.call(WSMPasswordCheck.new.card(aCard))
  end

  def editCard(aCard)
    if (self.checkPasswordFor: aCard) then
      self.call: (WSMCardEditor new card: aCard)
    end
  end

  def pickACard()
    return self.call: (WSMCardList new cards: self.squeakMap cardsByName)
  end

  def setPassword(card)
    pw = self.call: WSMPasswordEditor new
    card setPassword: pw
  end

  def squeakMap()
    if @@sandbox.nil? then
      @@sandbox = (SMSqueakMap newIn: 'sm=sandbox')
      loadFull
      yourself
    end
  end

  def viewCard(aCard)
    self.call: (WSMCardViewer new card: aCard)
  end

end


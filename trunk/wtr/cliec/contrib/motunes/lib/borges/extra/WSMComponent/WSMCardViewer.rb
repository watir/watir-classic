class WSMCardViewer < WSMComponent

  def actions
    return ['Edit', :edit, 'Delete', :delete]
  end

  def card(aCard)
    @card = aCard
  end

  def delete
    if (self.confirm: "Are you sure you want to delete #{@card.name}?") &&
       self.checkPasswordFor: @card then
      self.squeakMap deleteCard: @card
      self.answer
    end
  end

  def edit
    self.editCard: @card
  end

  def renderContentOn(html)
    html heading: @card name
    html preformatted: @card fullDescription
  end

end


class WSMPasswordCheck < WSMComponent

  def card(aCard)
    @card = aCard
  end

  def checkPassword
    if @card correctPassword: @password then
      self.answer: true
    else
      self.inform: 'Sorry, that password is incorrect;'
      self.answer: false
    end
  end

  def renderContentOn(html)
    html heading: "Please enter the password for #{@card.name}:"
    level: 3
    html form: do
      html defaultAction: do self.checkPassword end
      html passwordInputWithCallback: do |v| @password = v end
      html submitButton
    end
  end

end


class WSMCardEditor < WSMComponent

  def actions
    return ['Set Password', setPassword]
  end

  def card(aCard)
    @card = aCard
  end

  def renderContentOn(html)
    html heading: @card.name
    html form: do
      html table: do
        html
          labelledRowForTextInputOn: :name of: @card
          labelledRowForTextInputOn: :summary of: @card
          labelledRowForTextInputOn: :description of: @card
          tableRowWith: do html space end
          labelledRowForTextInputOn: :author of: @card
          labelledRowForTextInputOn: :maintainer of: @card
          tableRowWith: do html space end
          labelledRowForTextInputOn: :currentVersion of: @card
          labelledRowForTextInputOn: :versionComment of: @card
          tableRowWith: do html space end
          labelledRowForTextInputOn: :url of: @card
          labelledRowForTextInputOn: :downloadUrl of: @card
          tableRowWith: do html space end
          attributeAt: 'align' put: 'center'
          tableRowWith: do html submitButtonOn: :save of: self
        end
        span: 2
      end         
    end
  end

  def save()
    self.answer: true
  end

  def setPassword()
    self.setPassword: @card
  end

  def style()
    return 
    ' 
    #name {width: 200px}
    #summary {width: 300px}
    #description {width: 300px}
    #author {width: 200px}
    #maintainer {width: 200px}
    #currentVersion {width: 100px}
    #versionComment {width: 300px}
    #url {width: 300px}
    #downloadUrl {width: 300px}
    '
  end

end


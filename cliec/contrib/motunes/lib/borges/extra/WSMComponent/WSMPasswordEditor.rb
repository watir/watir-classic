class WSMPasswordEditor < WSMComponent

  def confirmPassword
    if @password == @confirmation then
      self.answer(@password)
    else
      self.inform('Sorry, the confirmation did not match the password.')
    end
  end

  def renderContentOn(r)
    r.form do
      r.defaultAction do self.confirmPassword end
      r.heading_level('Enter a new password:', 3)
      r.passwordInputWithCallback do |v| @password = v end
      r.heading_level('Confirm password:', 3)
      r.passwordInputWithCallback do |c| @confirmation = c end
      r.paragraph
      r.submitButton
    end
  end

end


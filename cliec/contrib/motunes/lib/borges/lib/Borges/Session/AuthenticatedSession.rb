class Borges::AuthenticatedSession < Borges::ControllerSession

  def authenticate(username, password)
    return username == application.preferences[:username] &&
      password == application.preferences[:password]
  end

  def self.default_preferences
    prefs = superclass.default_preferences
    prefs[:username] = Borges::StringPreference.new('seaside')
    prefs[:password] = Borges::StringPreference.new('admin')

    return prefs
  end

  def start(req)
    basic_auth_do(proc do |user, password|
        authenticate(user, password)
      end) do
        super.start(req)
    end
  end

end


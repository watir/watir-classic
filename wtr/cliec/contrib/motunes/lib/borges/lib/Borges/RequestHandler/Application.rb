class Borges::Application < Borges::Registry

  attr_reader :name, :preferences, :session_class

  def handle_default_request(req)
    session = @session_class.application(self)
    return session.enter_session_with(req)
  end

  def initialize(path)
    super()
    self.base_path = path

    @session_class = Borges::Session

    @preferences = Borges::Preferences.new
    @preferences.update(@session_class.default_preferences)

    @name = base_path.split('/').last
  end

  def session_class=(klass)
    @session_class = klass
    @preferences.update(@session_class.default_preferences)

    @session_class
  end

end


class Borges::Controller

  @@subclasses = []

  class << self
    alias orig_new new

    def new(*args, &block)
      inst = orig_new(*args, &block)
      inst.initialize_controller
      return inst
    end

    def inherited(klass)
      @@subclasses << klass
    end

    def all_subclasses
      return @@subclasses
    end
  end

  ##
  # TODO make this a loop

  def active_controller
    if self.delegate.nil? then
      return self
    else
      return self.delegate.active_controller
    end
  end

  ##
  # Return control to caller
  #
  # Called when a controller has completed, and needs to return a value.

  def answer(val = self)
    return val if @continuation.nil?

    @continuation.call(val)
  end

  def self.application_with_path(path, klass = nil)
    app = Borges::Application.new(path)
    app.session_class = klass unless klass.nil?
    app.preferences[:entry_point] = self

    return app
  end

  ##
  # Pass control
  #
  # Called when a controller desires to pass control to another
  # controller.
  #
  # If no controller is specified, then self is being called.  If
  # self is not going to answer, then don't save a continuation.
  #
  # Otherwise, delegate to the controller passed in, then call it.

  def call(controller = nil)
    if controller.nil? then
      unless will_answer? then
        raise Borges::RenderNotification.new

      else
        return callcc do |cc|
          @continuation = cc
          raise Borges::RenderNotification.new
        end

      end

    else
      return delegate_to(controller) do controller.call end

    end
  end

  def clear_delegate
    self.delegate = nil
  end

  def confirm(str)
    return call(Borges::Dialog.confirmation(str))
  end

  def self.default_session_class
    return Borges::ControllerSession
  end

  def delegate
    return will_call? ? @delegate.contents : nil
  end

  def delegate=(controller)
    if @delegate.nil?
      @delegate = Borges::StateHolder.new(controller)
    else
      @delegate.contents = controller
    end

    return self.delegate
  end

  def delegate_to(controller, &block)
    saved = self.delegate
    self.delegate = controller
    value = block.call
    self.delegate = saved
    return value
  end

  def inform(str)
    call(Borges::Dialog.message(str))
  end

  def initialize_controller
    @delegate = Borges::StateHolder.new(nil)
    @continuation = nil
  end

  def on_answer(&block)
    @continuation = block
  end

  def self.register_application(app_name, session_class = default_session_class)
    app = application_with_path(app_name, session_class)
    Borges::Dispatcher.default.register(app, app_name)
    return app
  end

  def self.register_authenticated_application(app_name, user, password)
    app = register_application(app_name, Borges::AuthenticatedSession)

    app.preferences[:username] = Borges::Preference.new(user)
    app.preferences[:password] = Borges::Preference.new(password)

    return app
  end

  def render_active_controller_with(context)
    del = self.delegate

    if del.nil? then
      render_with(context)
    else
      del.render_active_controller_with(context)
    end
  end

  ##
  # for compatibility

  def render_on(r)
    render_active_controller_with(r.context)
  end

  def render_with(context)
  end

  ##
  # XXX Fix InputDialog

  def request(request, label = nil, initial = '')
    input_dialog = Borges::InputDialog.new
    input_dialog.message = request
    input_dialog.label = label
    input_dialog.default = initial

    call(input_dialog)
  end

  def session
    return Borges::Session.current_session
  end

  ##
  # Will this component ever call #answer?  Used to optimize calling of
  # Controllers.
  #
  # Redefine to return false if this Controller will not call #answer.

  def will_answer?
    return true
  end

  ##
  # Will this component ever call #call?  Used to optimize calling of
  # Controllers.
  #
  # Redefine to return false if this Controller will not call #call.

  def will_call?
    return true
  end

end


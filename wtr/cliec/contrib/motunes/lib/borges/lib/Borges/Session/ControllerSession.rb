class Borges::ControllerSession < Borges::Session

  def always_redirect
    return application.preferences[:always_redirect]
  end

  def create_root_from_request(req)
    component = application.preferences[:entry_point].new

    if application.preferences[:show_toolbar] then
      return Borges::ToolFrame.on(component)
    else
      return component
    end
  end

  def self.default_preferences
    prefs = superclass.default_preferences
    prefs[:entry_point] = Borges::ListPreference.new(Borges::Counter, self.entry_points)
    return prefs
  end

  ##
  # TODO Fix so that all subclasses are available dynamically

  def self.entry_points
    return Borges::Controller.all_subclasses.sort_by do |a| a.name end
  end

  def render
    begin
      bookmark_for_expiry
      redirect if always_redirect

      callbacks = Borges::CallbackStore.new

      request = nil

      begin
        request = respond do |url|
          response_with_url_callbacks(url, callbacks)
        end

      rescue Borges::SimulatedRequestNotification => e
        request = e.request

      end

      callbacks.process_request(request)

    rescue Borges::RenderNotification => n
      n
    end
  end

  def response_with_url_callbacks(url, callback_store)
    document = Borges::HtmlResponse.new

    rc = Borges::RenderingContext.new(document, url, callback_store)

    @root.render_active_controller_with(rc)

    return document
  end

  def start(req)
    @root = create_root_from_request(req)
    loop do render end
  end

end


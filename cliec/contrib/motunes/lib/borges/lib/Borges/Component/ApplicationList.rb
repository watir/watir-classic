class Borges::ApplicationList < Borges::Component

  def initialize
    @app_name = nil
  end

  def add_application
    app = Borges::Counter.registerAsApplication(@app_name)
    configure(app)
  end

  # XXX unused?

  def authenticate(user, password)
    return user == 'seaside' && password == 'admin'
  end

  def clear_caches
    Borges::Dispatcher.default.entry_points.each do |ea|
      ea.clear_handlers if ea.respond_to?(:clear_handlers)
    end

    GC.start
  end

  def configure(app)
    call(Borges::ApplicationEditor.new(app))
  end

  def remove(app)
    Borges::Dispatcher.default.remove(app)
  end

  def render_content_on(r)
    r.heading('Borges Server')
    
    r.form do
      r.table do
        Borges::Dispatcher.default.entry_points.each do |app_name, app|
          render_row_for_application_on(app, r)
        end
      end
    end

    r.paragraph
    
    # TODO allow loading of apps
=begin
    r.form do
      r.default_action do add_application end
      r.text 'Application: '
      r.text_input('') do |n| @app_name = n end
      r.submit_button('Add') do add_application end
    end
=end
  
    r.anchor('Clear Caches') do clear_caches end
    r.paragraph
    
    #r.preformatted(SeasidePlatformSupport.vmStatisticsReportString)
  end

  def render_row_for_application_on(app, r)
    return unless app.kind_of? Borges::Application

    r.table_row_with do
        r.url_anchor(app.base_path, app.name)
    end

    r.table_row_with do
      r.anchor('configure') do configure(app) end
      r.space
      r.anchor('remove') do remove(app) end
    end
  end

  # TODO make this externally configurable
  register_authenticated_application('config', 'seaside', 'admin')

end


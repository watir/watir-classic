class Borges::ApplicationEditor < Borges::Component

  attr_accessor :application

  def initialize(app)
    @application = app
  end

  def component_classes
    return Borges::Component.allSubclasses.sort do |x, y|
      x.name <=> y.name
    end
  end

  def done
    answer
  end

  def render_content_on(r)
    r.heading("Application: #{@application.name}")

    r.form do
      r.text('Session Class:')
      r.space

      r.select(session_classes, @application.session_class) do |c|
        @application.session_class = c
      end

      r.space

      r.submit_button('OK') do end
    end

    r.paragraph
    r.form do
      r.table do  
        @application.preferences.each do |name, pref|
          render_preference_on(name, pref, r)
        end
        
        r.table_row do r.space end
        r.table_row_labeled('Base Path') do
          r.text_input_on('base_path', @application)
        end
  
        r.table_row do r.space end

        r.attributes['align'] = 'center'
        r.table_row_span(2) do
          r.submit_button_on('done', self)
        end

      end
    end
  end

  def render_preference_on(name, pref, r)
    r.table_row_labeled(r.label_for(name), pref)
  end

  def session_classes
    return Borges::Session.all_subclasses.sort do |x, y|
      x.name <=> y.name
    end
  end

end


class Borges::Dialog < Borges::Component

  attr_accessor :message

  def self.confirmation(str)
    dialog = self.new(str)

    dialog.on_answer('Yes') do true end
    dialog.on_answer('No') do false end

    return dialog
  end

  def self.example_confirmation
    return self.confirmation('Tea?')
  end

  def self.example_message
    return self.message('Hello World')
  end

  def initialize(message)
    @message = message
    @actions = Hash.new
  end

  def self.message(str)
    dialog = self.new(str)
    dialog.on_answer('OK') do true end

    return dialog
  end

  def on_answer(str, &block)
    @actions[str] = block
  end

  def render_content_on(r)
    r.heading_level(@message, 3)
    r.form do
      @actions.each do |name, action|
        r.submit_button(name) do
          answer(action.call)
        end
      end
    end
  end

end


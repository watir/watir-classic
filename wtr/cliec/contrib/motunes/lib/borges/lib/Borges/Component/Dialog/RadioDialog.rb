class Borges::RadioDialog < Borges::Dialog

  attr_accessor :label

  def initialize(actions, message, label)
    @actions = actions
    @message = message
    @label = label
      
    actions.each do |key, value|
      self.on_answer(key, value)
    end
  end

  def render_content_on(r)
    r.heading_level(@message, 3)
    
    group = r.radioGroup
    
    r.form do
      @actions.each do |assoc|
        r.radioButtonInGroup_selected_callback(group, false, proc do |value|
          self.answer(assoc.value.value)
        end)

        r.escapeText(assoc.key)
        r.break
      end
      
      r.submitButtonWithText(@label)
    end
  end

=begin
  def self.select_from_message_label(aCollection, messageString, labelString)
    return self.new.initializeWithActions_message_label(aCollection,
      @messageString, labelString)
  end
=end

end


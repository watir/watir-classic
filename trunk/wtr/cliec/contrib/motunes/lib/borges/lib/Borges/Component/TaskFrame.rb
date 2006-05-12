class Borges::TaskFrame < Borges::Component

  def initialize
    @task = Borges::PluggableTask.new do go end
    @task.on_answer do |v| answer(v) end
  end

  ##
  # XXX Written this way to handle recursive calling of TaskFrames

  def call(controller = nil)
    unless controller.nil? then
      return @task.call(controller)
    else
      return @task.call
    end
  end

  def render_content_on(r)
    r.render(@task)
  end

end


class Borges::CallbackStore

  def action(&action_callback)
    @action = action_callback
  end

  def evaluate_callback_with(callback, obj)
    @callbacks[callback].evaluate_with_store(obj, self)
  end

  def initialize
    @callbacks = {}
    @count = 0
  end

  def process_request(req)
    @action = nil

    sort_request(req.fields).each do |key, val|
      evaluate_callback_with(key, val)
    end

    unless @action.nil? then
      return @action.call
    else
      return nil
    end
  end

  def register_action_callback(&block)
    return store(Borges::ActionCallback.new(&block))
  end

  def register_callback(&block)
    return store(Borges::ValueCallback.new(&block))
  end

  def register_dispatch_callback
    return store(Borges::DispatchCallback.new)
  end

  def sort_request(fields)
    sorted = []

    unless fields.nil? then
      fields.each do |k, v|
        unless k.to_i.nil? then
          sorted << [k, value_for_field(v)]
        end
      end
    end

    return sorted.sort_by do |i| i.at(0).to_i end
  end

  def store(callback)
    key = (@count += 1).to_s
    @callbacks[key] = callback
    return key
  end

  def value_for_field(field)
    if field.nil? then
      return ''

    elsif field.respond_to?(:first) && field.respond_to?('empty?'.intern) then
      if field.empty? then
        return ''
      else
        return field.first
      end

    else
      return field

    end
  end

end


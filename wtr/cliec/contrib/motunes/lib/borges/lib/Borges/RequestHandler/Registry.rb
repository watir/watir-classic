class Borges::Registry < Borges::RequestHandler

  HANDLER_KEY_SEPARATOR = '/@'

  attr_accessor :base_path

  def initialize
    @base_path = nil
    clear_handlers
  end

  def clear_handlers
    @handlers_by_key = Hash.new
    @keys_by_handler = Hash.new
  end

  def handle_default_request(req)
    raise NotImplementedError.new("Subclass responsibility")
  end

  def handle_key_request(req)
    key = req.handler_key

    handler = @handlers_by_key[key] || nil

    if (not handler.nil?) && handler.active? then
      return handler.handle_request(req)
    else
      return handle_expired_request(req)
    end
  end

  def handle_request_intern(req)
    unless req.handler_key.nil? then
      return handle_key_request(req)
    else
      return handle_default_request(req)
    end
  end

  def register_request_handler(obj)
    key = Borges::ExternalID.create(16)

    collect_expired_handlers if collect_handlers?

    @handlers_by_key[key] = obj
    @keys_by_handler[obj] = key

    return key
  end

  ##
  # XXX We've gotta do something better than this - ab

  def collect_handlers?
    return 1 # rand(10) == 1
  end

  def collect_expired_handlers
    # XXX is this hack correct?
    @handlers_by_key.each_value do |handler|
      unless handler.respond_to?('active?'.intern) && handler.active? then
        unregister_request_handler(handler)
      end
    end
  end

  def unregister_request_handler(obj)
    @handlers_by_key.delete(@keys_by_handler[obj])
    @keys_by_handler.delete(obj)
  end

  def url_for_request_handler(handler, path = @base_path)
    key = @keys_by_handler[handler]
    key = register_request_handler(handler) if key.nil?

    return "#{path}#{HANDLER_KEY_SEPARATOR}#{key}"
  end

  ##
  # Can't alias

  def handle_expired_request(req)
    return handle_default_request(req)
  end

end


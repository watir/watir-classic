class Borges::Session < Borges::RequestHandler

  @@subclasses = []

  class << self
    def inherited(klass)
      @@subclasses << klass
    end

    def all_subclasses
      return @@subclasses
    end
  end

  def action_url_for_continuation(cont)
    return action_url_for_key(@continuations.store(wrap_continuation(cont)))
  end

  def action_url_for_key(str)
    return "#{@application.url_for_request_handler(self, self.path)}/#{str}"
  end

  def add_filter(filter)
    @filters.contents.push filter
  end

  def add_to_path(str)
    @path.contents("#{base_path}/#{str}")
  end

  def application
    return @application
  end

  def self.application(app)
    ses = self.new
    ses.initialize_with(app)
    return ses
  end

  def base_path
    return @application.base_path
  end

  def basic_auth_do(auth_block, &block)
    filter(Borges::BasicAuthentication.new(&auth_block), &block)
  end

  def bookmark_for_expiry
    return callcc do |cc|
      @expiry_continuation = wrap_continuation(proc do |v|
        redirect_with_message_in('That page has expired.', 3)
        cc.call(v)
      end)
    end 
  end

  ##
  # HACK This is totally bogus!

  def self.current_session
    #context = thisContext
    #until context.nil? do
    #  return context.receiver if context.receiver.kind_of? self
    #  context = context.sender
    #end

    #return nil

    return Thread.current[:session]
  end

  def self.default_preferences
    prefs = Borges::Preferences.new

    prefs[:show_toolbar] = Borges::BooleanPreference.new(true)
    prefs[:always_redirect] = Borges::BooleanPreference.new(true)
    prefs[:error_page] = Borges::ListPreference.new(Borges::WalkbackPage, [Borges::WalkbackPage]) # XXX Hack
    prefs[:session_expiry_seconds] = Borges::NumberPreference.new(600)

    return prefs
  end

  def enter_session(&block)
    rv = nil

    in_thread do
      rv = with_escape_continuation do
        val = with_error_handler do
          redirect
          block.call
        end
      end
    end

    return rv
  end

  def enter_session_with(req)
    return enter_session do start(req) end
  end

  def error_page_class
    return @application.preferences[:error_page]
  end

  def filter(filter, &block)
    add_filter(filter)
    block.call
    remove_filter(filter)
  end

  def handle_error(e)
    #e.reactivateHandler # XXX
    return error_page_class.exception(e).show
  end

  def start_handler_thread
    @session_mutex = Mutex.new
    @thread_mutex = Mutex.new.lock

    @thread = Thread.start do
      cur_thr = Thread.current
      THREAD_GROUP.add cur_thr
      cur_thr[:session] = self
      cur_thr[:in_handler_thread] = true
      cur_thr.abort_on_exception = true

      begin
        loop do
          @thread_mutex.synchronize do
            cur_thr[:return] = cur_thr[:block].call
            cur_thr[:response_done].unlock
          end
          @thread_mutex.lock
        end

      rescue Exception => err
        err_str = %^Exception in #{cur_thr.inspect}:\n#{err}\n#{err.backtrace.join("\n")}\n!!^
        puts err_str
        #cur_thr[:return].error(err_str, cur_thr[:request])
        #cur_thr[:return] = 
        cur_thr[:response_done].unlock
        cur_thr.kill

      end
    end
  end

  def in_thread(&block)
    val = nil

    if Thread.current[:in_handler_thread] then
      #val = handle_request_intern(req)
      val = block.call

    else
      start_handler_thread unless defined? @thread

      @session_mutex.synchronize do
        response_lock = Mutex.new.lock # unlocked by #perform_request_intern
        #@thread[:request] = req
        @thread[:block] = block
        @thread[:response_done] = response_lock
        @thread_mutex.unlock
        response_lock.lock
        val = @thread[:return]
      end

    end

    return val
  end

  def handle_request(req)
    in_thread do
      handle_request_intern(req)
    end
  end

  def handle_request_intern(req)
    return response_for_request(req)
  end

  ##
  # TODO Refactor into initialize
  #
  # HACK Thread.current[:session] is a hack

  def initialize_with(application)
    critical = Thread.critical
    Thread.critical = true
    current_ses = Thread.current[:session]
    Thread.current[:session] = self

    @application = application
    @continuations = Borges::LRUCache.new
    @state = Borges::StateRegistry.new
    @expiry_continuation = proc do |r| start end
    @last_access = Time.now.to_i
    @filters = Borges::StateHolder.new([])
    @path = Borges::StateHolder.new(base_path)

    Thread.current[:session] = current_ses
    Thread.critical = critical
  end

  def active?
    return (Time.now.to_i - @last_access) < application.preferences[:session_expiry_seconds]
  end

  def isolate(&block)
    txn = Borges::Transaction.new
    filter(txn, &block)
    txn.close
    bookmark_for_expiry
  end

  def once(&block)
    filter(Borges::Once.new, &block)
  end

  def page_expired
    @expiry_continuation.call(nil)
  end

  def path
    return @path.contents
  end

  def perform_request(req)
    @last_access = Time.now.to_i
    cont = @continuations.fetch(req.action_key)

    if cont.nil? then
      return unknown_request(req)
    else
      return cont.call(req)
    end
  end

  def redirect
    respond do |url|
      Borges::RedirectResponse.new(url)
    end
  end

  def redirect_to(url)
    return_response(Borges::RedirectResponse.new(url))
  end

  def redirect_with_message_in(message, seconds)
    respond do |url|
      Borges::RefreshResponse.new(message, url, seconds)
    end
  end

  def register_for_backtracking(obj)
    @state.register(obj)
  end

  def remove_filter(filter)
    @filters.contents.delete(filter)
  end

  def respond(&block)
    request = callcc do |cc|
      return_response(block.call(action_url_for_continuation(cc)))
    end

    @filters.contents.each do |ea|
      ea.handle_request_in(request, self)
    end

    return request 
  end

  def response_for(&block)
    return with_escape_continuation do block.call end
  end

  def response_for_request(req)
    return response_for do perform_request(req) end
  end

  def return_response(res)
    @escape_continuation.call(res)
  end

  def start(req = nil)
    raise NotImplementedError.new("Subclass Responsibility")
  end

  def unknown_request(req)
    page_expired
  end

  def with_error_handler(&block)
    begin
      block.call
    rescue Exception => e
      handle_error(e)
    end
  end

  def with_escape_continuation(&block)
    return callcc do |cc|
      @escape_continuation = cc
      block.call
    end
  end

  def wrap_continuation(cont)
    snap = @state.snapshot

    return proc do |v|
      @state.restore_snapshot(snap)
      cont.call(v)
    end
  end

end


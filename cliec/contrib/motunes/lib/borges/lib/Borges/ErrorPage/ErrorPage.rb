class Borges::ErrorPage

  def self.exception(anException)
    inst = self.new
    inst.exception(anException)
    return inst
  end

  def exception(anException)
    @exception = anException
  end

  def print_exception_description_on(res)
    res << "<h1>#{@exception.message.gsub('<', '&lt;').gsub('>', '&gt;')}</h1>"
  end

  def print_header_for_stack_frame_on(aContext, res)
    res << "<li>#{aContext}"
  end

  def print_stack_frame_on(context, res)
    print_header_for_stack_frame_on(context, res)
  end

  def print_stack_frame_list_end_on(res)
    res << '</ul>'
  end

  def print_stack_frame_list_start_on(res)
    res << '<ul>'
  end

  def print_walkback_on(res)
    print_exception_description_on(res)
    print_stack_frame_list_start_on(res)
  
    @exception.backtrace.each do |context|
      print_stack_frame_on(context, res)
    end
  
    print_stack_frame_list_end_on(res)
  end

  def session
    return Borges::Session.current_session
  end

  def show
    res = GenericResponse.new('text/html')
    res << "<h1>500 - Error</h1><p>There has been an internal error.  The system administrator has been notified."
    session.return_response(res)
  end

end


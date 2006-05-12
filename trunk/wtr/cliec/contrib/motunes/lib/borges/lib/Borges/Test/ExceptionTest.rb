class ExceptionTest < Borges::Task

  class ExceptionTestException < Exception; end

  def go
    begin
      if confirm('Raise an exception?') then
        raise ExceptionTestException.new('foo')
      end
    rescue ExceptionTestException => e
      inform("Caught: #{e}")
    end
  end

end


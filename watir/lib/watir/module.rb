module Watir
  include Watir::Exception

# Directory containing the watir.rb file
  @@dir = File.expand_path(File.dirname(__FILE__))

  ATTACHER = Waiter.new
# Like regular Ruby "until", except that a TimeOutException is raised
# if the timeout is exceeded. Timeout is IE.attach_timeout.
  def self.until_with_timeout # block
    ATTACHER.timeout = IE.attach_timeout
    ATTACHER.wait_until { yield }
  end

  @@autoit = nil

  def self.autoit
    unless @@autoit
      begin
        @@autoit = WIN32OLE.new('AutoItX3.Control')
      rescue WIN32OLERuntimeError
        _register('AutoItX3.dll')
        @@autoit = WIN32OLE.new('AutoItX3.Control')
      end
    end
    @@autoit
  end

  def self._register(dll)
    system("regsvr32.exe /s "    + "#{@@dir}/#{dll}".gsub('/', '\\'))
  end

  def self._unregister(dll)
    system("regsvr32.exe /s /u " + "#{@@dir}/#{dll}".gsub('/', '\\'))
  end

end
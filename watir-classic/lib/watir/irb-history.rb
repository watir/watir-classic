# snarfed from http://blog.nicksieger.com/articles/2006/04/23/tweaking-irb
module Readline
  module History
    @@log ||= File.join(Dir.pwd, 'console.log')
    
    def self.log= log
      @@log = log
    end
    
    def self.write_log(line)
      begin
        File.open(@@log, 'ab') {|f| f << "#{line}\n"}
      rescue
      end
    end 

    def self.start_session_log
      write_log("# session start: #{Time.now}")
      at_exit { write_log("# session stop: #{Time.now}\n") }
    end
  end

  alias :old_readline :readline
  def readline(*args)
    ln = old_readline(*args)
    History.write_log(ln)
    ln
  end
end

Readline::History.start_session_log
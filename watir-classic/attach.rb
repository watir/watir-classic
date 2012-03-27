require 'irb/completion'
ARGV.concat [ "--readline", "--prompt-mode", "simple" ]
RUBY_PLATFORM =~ /mswin/ ? history_file = '\.irb_history' : history_file ='~/.irb_history'
IRB.conf[:EVAL_HISTORY] = 1000
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = File::expand_path(history_file)

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

title = ENV['window_title'] || '.'
require 'watir-classic/ie'
@ie = Watir::IE.attach :title, /#{title}/
puts "Attached to: #{@ie.title}"
puts "Your browser instance is: ie, browser"

def ie
 @ie
end
alias :browser :ie

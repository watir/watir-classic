#$: = ($LOAD_PATH.collect {|d| d.downcase}).uniq
# how does toolkit.rb get away with modifying $:??

require 'logger'
require 'English'

def start_log(level=nil)
  if (not defined?($log)) then $log = Logger.new(STDOUT) end

  if (not level)
    if $DEBUG then level = Logger::DEBUG
    else level = Logger::INFO
    end
  end
  $log.level = level
  
  $log.debug("(Re)Start log at level " + level.to_s)
end


def seed_rand(seed = nil)
  $log.debug 'beginning seed_rand(' + seed.inspect + ')'
  if (!seed) 
    if $debug then seed = 1
    else 
      srand
      seed = srand
    end
  end
  srand(seed)
  $log.info 'seed_rand seed = ' + seed.inspect
end

=begin 
def rand_in_range(range)
  #TBD: Handle non-integer ranges
  $log.debug 'beginning rand_in_range(' + range.inspect + ')'
  if not (range.first.kind_of? Integer and range.last.kind_of? Integer)
    range = Range.new(range.first.to_i, range.last.to_i, range.exclude_end?)
    $log.debug 'adjusted range = ' + range.inspect
  end
    
  if (range.min == range.max) then value = range.min
  else
=end   
  
  
def capture_stdout ()
  $log.debug 'beginning capture_stdout'
  read_end, write_end = IO.pipe
  $stdout = write_end
  
  yield
  
  $stdout = STDOUT
  write_end.close
  lines = read_end.readlines
  read_end.close

  $log.debug 'capture_stdout lines => ' + lines.inspect
  lines
end


def get_elements(form)
  $log.debug 'beginning get_elements(' + form.inspect + ')'
  
  elements = Array.new
  form.elements.each {|element|
    $log.debug 'element = ' + element.inspect
    elements << element
  }
  
  $log.debug "elements.length = #{elements.length}"
  elements
end


def get_elements_named_values(form)
  $log.debug 'beginning get_elements_named_values(' + form.inspect + ')'
  
  named_values = Hash.new
  
  elements = get_elements(form)
  elements.each {|element|
    $log.debug "element.name: '#{element.name}', .value: '#{element.value}'"
    named_values[element.name] = element.value
  }
  
  $log.debug "named_values.length: #{named_values.length}"
  named_values
end


def rand_string(root = 'randstr00')
  if defined?(@str) then @str = @str.succ
  else @str = root
  end
end


def login_with_new_user( user )
  #Based on Bret's start_with_new_user() in timeclock-assist.rb
  $log.debug "login_with_new_user('#{user}')"
  
  ensure_no_user_data( user )
  start_ie( 'http://localhost:8080' )

  forms[0].name = user
  forms[0].submit
  $iec.wait
end

def create_first_job(job)
  $log.debug "create_first_job(#{job})"
  
  forms[0].name = job
  forms[0].submit
  $iec.wait
end

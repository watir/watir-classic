require 'rbconfig'
require 'ruby-trace/all'

module Timeclock

  class ConfigurationProblem < StandardError
  end
  
  class Configuration
    
    def self.data_dir
      dir = ENV['VW_TIMECLOCK_DATA_DIR']
      return dir if dir

      if Config::CONFIG['target_vendor'] == 'apple'
        unless ENV['HOME']
          raise ConfigurationProblem, no_home
        end
        return "#{ENV['HOME']}/Library/Timeclock"
      end
        
      raise ConfigurationProblem, no_data_dir
    end

    def self.no_data_dir
      '.Timeclock does not know where to store its data.
       .You must set environment variable VW_TIMECLOCK_DATA_DIR.
       .Its value should be the name of a directory (or folder).'.after_dots
    end

    def self.no_home
      '.Timeclock normally stores its data under your home directory.
       .But the HOME environment variable is not set.'.after_dots
    end

    def self.ensure_data_dir
      unless File.exists?(data_dir)
        File.makedirs(data_dir)
      end
      unless File.exists?(logdir)
        File.makedirs(logdir)
      end
      unless File.exists?(userdir)
        File.makedirs(userdir)
      end
    end

    def self.logdir
      data_dir+'/logs'
    end

    def self.userdir
      data_dir+'/user-data'
    end

    def self.user_file(username)
      userdir + "/" + username
    end
      
    def self.log_file(logname)
      logdir + "/" + logname
    end

    # These do not have unit tests, but they're tested through use.

    def self.start_log(logname, file_threshold='event')
      logfile = log_file(logname)
      $trace = Trace::Connector.debugging_buffer_and_file(logfile, "a", 100000)
      $trace.set_threshold('file', file_threshold)
      $trace.announce("=================NEW INVOCATION=======================")
    end

  end
end

# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'
require 'observer'

module Trace

  # All Trace exceptions are supposed to be subclasses of
  # Trace::Exception.
  class Exception < ::Exception
  end

  module Util
    # I'm a little uneasy about using "/n" in strings on Windows,
    # although it seems to work correctly. So I go to some effort
    # to use $/ everywhere.
    def lines(*args)
      args.join($/)
    end

    # An easy way to construct a standard error message.
    def try_one(prefix, list)
      lines(prefix,
            "   Try one of these:",
            "   #{list.join(', ')}")
    end
  end

  class Theme
    attr_accessor :name, :level_names
    
    def initialize(name, level_names)
      @name = name
      @level_names = level_names
      #Insert "none" as highest level so that set_threshold("none") 
      #turns off all the normally visible levels
      level_names[0,0]="none"
    end
  end

  class Environment
    include TraceErrors

    def initialize
      @env = []
    end

    # Receives the result of looking up a name like TRACEENV in the
    # environment.
    def set(env_value)
      @env = (env_value || "").split(/ |;|:/)
      Internal.trace.announce "Obeying this trace environment: #{@env.inspect}"
    end

    def topic_default(topic, buffer)
      find_topic_item(topic, buffer, 'default')
    end

    def topic_threshold(topic, buffer)
      find_topic_item(topic, buffer, 'threshold')
    end

    def global_default(theme, destination)
      sought = Regexp.new("^global-#{theme}-#{destination}-default=(.*)$")
      return $1 if @env.find { | elt | sought =~ elt }
      nil
    end

    def find_topic_item(topic, buffer, item)
      sought = Regexp.new("^#{topic}-#{buffer}-#{item}=(.*)$")
      return $1 if @env.find { | elt | sought  =~ elt }
      sought = Regexp.new("^#{topic}--#{item}=(.*)$")
      return $1 if @env.find { | elt | sought =~ elt }
      nil
    end

    def to_s
      "ENV: #{@env.inspect}"
    end
  end

end

# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'
require 'ruby-trace/valueholder'
require 'observer'
require 'monitor'

module Trace
  class Connector < Topic
    include TraceErrors
    include Util

    # Topic privatizes :new because Topics are singletons. Connectors
    # aren't singletons, so make it public again.
    public_class_method :new

    # These should only be used by Topic, which is pretty tightly
    # coupled to Connector. 
    attr_reader :theme_map, :default_destinations, :default_theme,           
                :default_thresholds, :environment              

                 ### CREATION AND INITIALIZATION ###

    # new takes a block argument. The methods normally called in the
    # block argument follow 'initialize'. Those methods are in the
    # context of self.

    def initialize (&proc)
      @topic_map = {}           # A hash with string names as keys
                                # and topics as values.
                                
      @theme_map = {}           # A hash with string names as keys
                                # and Themes as values.

      @destination_map={}       # The different possible destinations for trace
                                # messages. A hash with string names as keys
                                # and Destinations as values.

      @default_destinations=[]  # The destinations selected by default.
                                # An array of strings.

      @default_theme=nil        # String name of the default theme.

      @default_thresholds={}    # Interface is a 2D hash of
                                # [Theme_name][Destination_name] that
                                # yields the String name of the default
                                # threshold for messages of that theme
                                # going to that destination.

      @topics_with_methods = [] # Topics that have had add_method_for_topic
                                # called for them. Needed so that topic
                                # methods can be added twice while still
                                # preventing predefined methods from being
                                # overridden.

      @environment=Environment.new  # The Environment applicable to this.

      @monitor = Monitor.new    # Thread safety

      instance_eval(&proc) if proc

      @theme_map.each_key { | theme_name |
        @destination_map.each_key { | dest_name |
          default = @environment.global_default(theme_name, dest_name)
          if default
            theme_and_destination_use_default(theme_name, dest_name, default)
          end
        }
      }

      # If there is a default theme, this Connection is itself a topic
      # with that theme. If there isn't one, it makes no sense for the
      # Connection to be a topic. A topic about what?
      if @default_theme
        super("", self, {})
        Internal.trace.announce "Created connection (theme #{@default_theme})."
      else
        Internal.trace.announce "Created connection (but it's not a topic)."
      end
    end

    def use_environment_variable(var)
      @monitor.synchronize {
        Internal.trace.announce "Using environment variable #{var}."
        @environment.set(ENV[var])
      }
    end

    def add_theme(name, levels, default=false)
      @monitor.synchronize {
        assert(@theme_map[name] == nil) { "Theme '#{name}' already exists." }
        assert(levels.class==Array) {
          "'levels' argument should be an Array. '#{levels}' is not."
        }
        levels.each { | l |
          assert(/^[a-z]\w*$/===l) {
            "Level names must match /[a-z][a-zA-Z0-9_]*/"
          }
          assert(! Topic.method_defined?(l)) {
            "'#{l}' cannot be a level - it's already a method of class Topic."
          }
        }
        t = Theme.new(name, levels)
        @theme_map[name] = t
        @default_thresholds[name] = {}
        @default_theme=name if default
        t
      }
    end

    def add_destination(destination, default=false)
      @monitor.synchronize {
        assert(@destination_map[destination.name] == nil) {
          "Destination '#{destination.name}' already exists."
        }
        @destination_map[destination.name]=destination
        
        @default_destinations.push(destination.name) if default
        destination
      }
    end

    def theme_and_destination_use_default(theme_name, dest_name, default_threshold)
      @monitor.synchronize {
        Internal.trace.announce "Setting default threshold of theme '#{theme_name}' and destination '#{dest_name}' to #{default_threshold}."
        assert_known_destination(dest_name)
        assert(@theme_map[theme_name]) {
          try_one("Theme '#{theme_name}' is unknown.",
                        @theme_map.keys.sort)
        }
        assert(@theme_map[theme_name].level_names.include?(default_threshold)) {
          try_one("'#{default_threshold}' is not a level for theme '#{theme_name}'.",
                        @theme_map[theme_name].level_names)
        }
        
        value_holder =
          (@default_thresholds[theme_name][dest_name] ||= ValueHolder.new)
        value_holder.value = default_threshold
      }
    end


    ### Common combinations of the above calls.
    
    def debugging_theme
      add_theme('debugging',
                %w{error warning announce event debug verbose},
                :default)
    end

    def debugging_theme_and_buffer
      # Note that this does NOT automatically obey TRACEENV.
      add_destination(BufferDestination.new('buffer'), :default)
      debugging_theme
      theme_and_destination_use_default('debugging', 'buffer', 'event')
    end


    ### Constructors for standard connectors. 
    ### Note that each should evaluate any proc given in the context
    ### of self. 

    def Connector.debugging_buffer (&proc)
      Connector.new  {
        use_environment_variable("TRACEENV")
        debugging_theme_and_buffer
        instance_eval(&proc) if proc
      }
    end

    def Connector.debugging_buffer_and_file(*file_args, &proc)
      Connector.new  {
        use_environment_variable("TRACEENV")
        debugging_theme_and_buffer
        add_destination(LogfileDestination.new('file', *file_args), :default)
        theme_and_destination_use_default('debugging', 'file', "announce")

        instance_eval(&proc) if proc
      }
    end

    def Connector.debugging_printer(&proc)
      Connector.new {
        use_environment_variable 'TRACEENV'
        debugging_theme
        add_destination(PrintingDestination.new('printer'), :default)
        theme_and_destination_use_default('debugging', 'printer', 'none')

        instance_eval(&proc) if proc
      }
    end



                ### Miscellaneous public methods. ###

    def replace_destination(destination)
      @monitor.synchronize {
        assert(@destination_map[destination.name]) { 
          "You can't replace '#{destination.name}'. It was never created."
        }
        @destination_map[destination.name]=destination
      }
    end

    # This is only quasi-public: should only be called by class Topic.
    def remember_topic(topic)
      @monitor.synchronize {
        @topic_map[topic.name] = topic
      }
    end

    # Create a topic managed by this Connector.
    def topic(name, keyword_args={})
      Topic.instance(name, self, keyword_args)
    end

    # Add a singleton method whose name is the topic's and whose
    # action is to return the topic.
    def add_method_for_topic(topic_name)
      assert(topic_name.kind_of?(String)) {
        "add_method_for_topic takes a topic name, not a topic object."
      }

      assert(@topic_map.has_key?(topic_name)) {
        "'#{topic_name}' does not name a topic. Use Connector.topic first."
      }
      
      unless (@topics_with_methods.include?(topic_name)) # already present.
        method_name_regexp = /^[a-z_]\w*$/
        assert(method_name_regexp =~ topic_name) {
          lines("'#{topic_name}' is not a valid method name.",
                "To be added, topic names must match #{method_name_regexp.inspect}.")
        }
        assert(!respond_to?(topic_name, :include_private)) {
          "'#{topic_name}' clashes with an existing method."
        }

        instance_eval("def self.#{topic_name}() @topic_map['#{topic_name}']; end")
        @topics_with_methods.push(topic_name)
      end
      self.send(topic_name) # Return the topic corresponding to the name
    end

    def drain(from_name, to_name)
      assert_known_destination(from_name)
      assert_known_destination(to_name)
      
      from = destination_named(from_name)
      to = destination_named(to_name)
      
      assert(from.respond_to?(:to_destination)) {
        lines("Destination '#{from_name}' does not know how to drain.",
              "It should be a BufferDestination or something similar.")
      }

      from.to_destination(to)
    end

    def topic_named(name)
      @topic_map[name]
    end

    def destination_named(name)
      @destination_map[name]
    end

    def inspect
      @monitor.synchronize {
        description = [
          "Connection with topics: #{@topic_map.keys.inspect}",
          "  themes: #{@theme_map.keys.inspect}",
          "  destinations: #{@destination_map.keys.inspect}",
          "  default_destinations: #{@default_destinations.inspect}",
          "  default_theme: #{@default_theme.inspect}"
          ]
        @default_thresholds.collect { | theme_name, hash |
          hash.collect { | destination_name, threshold |
            description.push "  default_thresholds[#{theme_name}][#{destination_name}] = #{threshold.value}"
          }
        }
        lines(description)
      }
    end


    private

    def assert_known_destination(dest_name)
      assert(@destination_map[dest_name]) {
        try_one("Destination '#{dest_name}' is unknown.",
                      @destination_map.keys.sort)
      }
    end

  end

  # Since there are two common spellings of this word, support them both.
  Connecter=Connector
end

# Ruby-Trace 
# Brian Marick, marick@visibleworkings.com, www.visibleworkings.com
# $Revision$ ($Name$) of $Date$
# Copyright (C) 2001 by Brian Marick. See LICENSE.txt in the root directory.

require 'ruby-trace/errors'
require 'ruby-trace/misc'
require 'ruby-trace/valueholder'
require 'observer'
require 'monitor'

module Trace

  class Topic
    include TraceErrors
    include Util
    # This class also uses internal classes ThresholdManager and
    # MethodInstaller, which are defined at the end of the file.

    attr_accessor :name,        # A string.

      :theme,                   # A Theme object, not a theme name.
                                
      :destination_names,       # An array of destination names

      :threshold_managers,      # A hash with a ThresholdManager 
                                # for each destination name

      :owner                    # The Connector object that owns self


                 ### CREATION AND INITIALIZATION ###

    # Topics are singletons, created thusly:

    def Topic.instance(name, owner, keyword_args={})
      Topic.check_for_extra_keywords(keyword_args)

      topic = owner.topic_named(name)
      if topic
	topic.assert_consistent_initialization_keywords(keyword_args)
        Internal.trace.event("Topic '#{name}' already exists.")
      else
        msg = "Creating topic '#{name}' with #{keyword_args.inspect}"
        Internal.trace.announce(msg)
        topic = new(name, owner, keyword_args)
      end
      topic
    end

    private_class_method  :new

    def initialize(name, owner, keyword_args)
      @name = name
      @owner = owner
      @monitor = Monitor.new

      @destination_names = destination_names_or_error(keyword_args)
      theme_name = theme_name_or_error(keyword_args)
      @destination_names.each { |dest_name|
        assert_has_threshold(theme_name, dest_name)
      }

      @theme = @owner.theme_map[theme_name]
      Internal.trace.announce("Creating topic '#{name}' with theme '#{theme.name}' and destinations #{destination_names.inspect}")

      make_threshold_managers
      environment_may_override_default_thresholds
      install_level_methods
      observe_threshold_changes

      # This seems like it should be in Connector#topic. However, there's
      # one topic - the connector itself - that is not created via that
      # method. So this is the only place that makes sure adding happens
      # for all topics.
      @owner.remember_topic(self)
    end

    ### Creation utilities

    def Topic.check_for_extra_keywords(keyword_args)
      extras = keyword_args.keys - %w{theme destinations destination}
      TraceErrors.assert(extras.length == 0) {
        # Only bother with the first bad one.
        "trace topic creation: '#{extras[0]}' is an unknown keyword."
      }
    end

    # When a singleton trace object is fetched, any keyword
    # args given must be consistent with those originally used.
    def assert_consistent_initialization_keywords(keyword_args)
      new_theme_name = keyword_args.fetch('theme', @theme.name)
      assert(new_theme_name == @theme.name) {
        "Topic '#{@name}' already has a different theme: '#{@theme.name}'."
      }

      new_destination_names =
        destination_names_or_default(keyword_args, @destination_names)
      assert(new_destination_names.sort == @destination_names.sort) {
        "Topic '#{@name}' already routed to #{@destination_names.inspect}."
      }
    end

    # Destination names are given in keywords or gotten from owner.
    def destination_names_or_error(keyword_args)
      destination_names =
        destination_names_or_default(keyword_args, @owner.default_destinations)
      assert(destination_names.length>0) {
        "Because there is no default destination, you must declare it explicitly for '#{name}'."
      }
      destination_names
    end

    def destination_names_or_default(keyword_args, default)
      # Assume they'll give either 'destinations' or 'destination', not both.
      destination_names =
        keyword_args.fetch('destinations', keyword_args['destination'])
      destination_names ||= default

      # If a singleton string, wrap with array. Aren't we friendly? 
      unless destination_names.class == Array
        destination_names = [destination_names]
      end

      destination_names
    end

    # The theme name is given in keywords or gotten from owner.
    def theme_name_or_error(keyword_args)
      theme_name=keyword_args.fetch('theme', @owner.default_theme)
      assert(theme_name) {
        "Because there is no default theme, you must declare it explicitly for '#{name}'."
      }
      theme_name
    end

    def assert_has_threshold(theme_name, dest_name)
      assert(@owner.default_thresholds[theme_name] &&
             @owner.default_thresholds[theme_name][dest_name]) {
        "Theme '#{theme_name}' does not have a default threshold for destination '#{dest_name}'."
      }
    end

    def make_threshold_managers
      @threshold_managers = {}
      @destination_names.each do |dest_name |
        @threshold_managers[dest_name] = 
          ThresholdManager.new(@owner.default_thresholds[@theme.name][dest_name])
      end
    end

    def environment_may_override_default_thresholds
      @destination_names.each do | dest_name |
        
        level = @owner.environment.topic_threshold(@name, dest_name)
        set_threshold(dest_name, level) if level

        level = @owner.environment.topic_default(@name, dest_name)
        set_default_threshold(dest_name, level) if level
      end
    end

    def observe_threshold_changes
      @threshold_managers.each_value do | manager | 
        manager.add_observer(self)
      end
    end


                        ### PUBLIC METHODS ###

    # Set the specific threshold. Overrides everything else. 
    def set_threshold(dest_name, level_name)
      @monitor.synchronize {
        msg = "'#{@name}'.set_threshold(#{dest_name}, #{level_name})"
        Internal.trace.event msg

        set_one_threshold(dest_name, level_name, :explicit)
        self
      }
    end

    # The default threshold overrides the owner, but not an explicit
    # threshold set with set_threshold.
    def set_default_threshold(dest_name, level_name)
      @monitor.synchronize {
        msg = "'#{@name}'.set_default_threshold(#{dest_name},#{level_name})"
        Internal.trace.event msg

        set_one_threshold(dest_name, level_name, :default)
        self
      }
    end


    # Helper methods for the public methods.

    # This code kind of smells - I don't like the 'which_kind' -
    # but I don't see a better way. 
    def set_one_threshold(dest_name, level_name, which_kind)
      manager = @threshold_managers[dest_name]
      assert(manager) {
        try_one("'#{dest_name}' is not a destination for topic '#{@name}'.",
                @destination_names)
      }

      value_holder = manager.send(which_kind)

      if level_name == "default"
        value_holder.forget_value!
      elsif @theme.level_names.include?(level_name)
        value_holder.value = level_name
      else
	fail(try_one("'#{level_name}' is not a level for topic '#{@name}'.",
                     ['default']+@theme.level_names))
      end
      # Since self is an observer of the threshold, updates will happen.
    end


             ### CREATING AND CHANGING LEVEL METHODS ###

    # We observe each destination's threshold, which can be changed either
    # directly (via topic.set_threshold or topic.set_default_threshold) or
    # indirectly (via the owner changing its defaults).

    def update
      install_level_methods
    end

    def install_level_methods
      @theme.level_names.each do |l|
        mc = MethodInstaller.new(self, l)

        # Install topic.error, topic.warning, etc.
        mc.install_one_method(l,
          "def self.#{l}(message='Reached here.', additional_frames=0) ",
          "message=yield if block_given?; ",
          "Message.new(message, '#{@name}', '#{l}', additional_frames)")

        # Install topic.error_value, topic.warning_value, etc.
        # This clever hack for printing a string's value due to Dave Thomas.
        mc.install_one_method("#{l}_value",
          "def self.#{l}_value(&proc) ",
          'string=yield; message="#{string} -> #{eval(string,proc).inspect}";',
          "Message.new(message, '#{@name}', '#{l}')")
      end
    end


                        ### HELPER CLASSES ###

    # A MethodInstaller creates a method and installs it on an object
    # as a singleton method.

    class MethodInstaller
      def initialize(topic, level_name)
        @topic = topic
        @level_name = level_name
      end

      # The NAME is the name of the method to install.
      # The HEAD is everything up through the argument list.
      # The BLOCK_HANDLER is code that does something if a block is given
      # to the installed method.
      # The MESSAGE_CALLER is code that creates a Message.
      # What this does is construct code that invokes the MESSAGE_CALLER
      # for each destination that should receive messages at
      # this message installer's level. If there are no such destinations,
      # the method body is empty.
      #
      # Yeah, all this reflective hackery is strictly unnecessary, but
      # gosh it was fun.

      def install_one_method(name, head, block_handler, message_caller)
        body = body_of_constructed_method(message_caller)
        body = block_handler  + body unless body == ""
        defn = head + body + "end"
        Internal.trace.verbose(defn)

        # Removing methods prevents warnings with ruby -w.
        if @topic.singleton_methods.include?(name)
          destroyer = "class << self; remove_method(#{name.intern.inspect}); end"
          @topic.instance_eval(destroyer)
        end
        @topic.instance_eval(defn)
      end

      def body_of_constructed_method(message_creation_string)
        body=""
        @topic.destination_names.each { | dest | 
          threshold = @topic.threshold_managers[dest].threshold
          level_names = @topic.theme.level_names
          if level_names.index(@level_name) <= level_names.index(threshold)
            body += "@owner.destination_named('#{dest}').accept(#{message_creation_string}); "
          end
        }
        body
      end

      # A teensy note about efficiency. "@owner.destination_named('buffer')" is
      # about 50% slower than constructing an instance variable to cache
      # the value. Even though I want people to think of this code as
      # maximally efficient, caching doesn't seem worthwhile. I did once
      # cache, just because I wanted to play with instance_eval. If you
      # do cache, note the following:
      # - destination names have to be transmogrified because they
      #   may contain all kinds of weird characters. (There are tests
      #   for this.) A singleton transmogrifier would look like this:
      #   
      #
      #        class DestInstanceVars
      #          def initialize(destinations)
      #            @destinations = destinations
      #            @mapping = {}
      #          end
      #
      #          def [](dest_name)
      #            val = @mapping[dest_name]
      #            return val if val
      #
      #            safe_var_name=dest_name.tr("^a-zA-Z0-9_", "").downcase
      #            instance_name = "@#{safe_var_name}_destination"
      #            set_accessor_string =
      #              "#{instance_name}=@owner.destinations['#{dest_name}']"
      #            Internal.trace.verbose(set_accessor_string)
      #            instance_eval(set_accessor_string)
      #            self[dest_name]
      #          end
      #        end
      #
      # - The topic must be an observer on Connector's @destinations
      #   instance variable (@owner.destinations.add_observer(self)),
      #   and replace_destinations must notify_observers. (Note that
      #   you must also make Hash observable.)
      #   There are also tests that replacing destinations works correctly.
      #   See revision 1.7 of connections.rb (since deleted, but still in
      #   the repository).
    end


    # At any given moment, a ThresholdManager object merges the owner default
    # threshold, the topic default threshold, and the topic explicit
    # threshold into a single threshold. It observes all those values
    # and updates itself when they change.

    class ThresholdManager
      include Observable
      attr_reader :threshold, :default, :explicit

      def initialize(owner_default)
        @owner_default = owner_default
        @default = ValueHolder.new
        @explicit = ValueHolder.new

        @owner_default.add_observer(self)
        @default.add_observer(self)
        @explicit.add_observer(self)
        
        calculate_threshold
      end

      def update
        calculate_threshold
      end

      def calculate_threshold
        @threshold = 
          if @explicit.value?
            @explicit.value
          elsif @default.value?
            @default.value
          else
            @owner_default.value
          end
        Internal.trace.debug("Threshold updated to #{@threshold}.")
        changed; notify_observers
      end

      def inspect
        "ThresholdManager with owner_default = #{@owner_default.inspect}, " +
          "default = #{@default.inspect}, " +
          "explicit = #{@explicit.inspect} => #{@threshold}."
      end

    end
  end
end

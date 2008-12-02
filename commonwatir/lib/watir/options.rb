# watir/options
require 'rubygems'

require 'user-choices'

module Watir
  @@options_file = nil
  @@options = nil
  class << self
    # Specify the location of a yaml file containing Watir options. Must be
    # specified before the options are parsed.
    def options_file= file
      @@options_file = file
    end
    def options_file
      @@options_file
    end
    def options= x
      @@options = x
    end
    # Return the Watir options, as a hash. If they haven't been parsed yet,
    # they will be now.
    def options
      @@options ||= Watir::Options.new.execute
    end
  end

  class Options < UserChoices::Command
    include UserChoices
    def add_sources builder
      builder.add_source EnvironmentSource, :with_prefix, 'watir_'
      if Watir.options_file
        builder.add_source YamlConfigFileSource, :from_complete_path, 
          Watir.options_file
      end
    end
    def add_choices builder
      builder.add_choice :browser, 
      :type => Watir::Browser.options, 
      :default => Watir::Browser.default
      builder.add_choice :speed, 
      :type => ['slow', 'fast', 'zippy'], 
      :default => 'fast'
      builder.add_choice :visible,
      :type => :boolean
    end
    def execute 
      @user_choices[:speed] = @user_choices[:speed].to_sym
      @user_choices
    end 
  end
end

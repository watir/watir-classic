#--
# watir/options
require 'rubygems'

require 'user-choices'

module Watir
  class << self
    # Specify the location of a yaml file containing Watir options. Must be
    # specified before the options are parsed.
    attr_accessor :options_file

    attr_writer :options

    # Return the Watir options, as a hash. If they haven't been parsed yet,
    # they will be now.
    def options
      @options ||= Watir::WatirOptions.new.execute
    end
  end

  # @private
  class WatirOptions < UserChoices::Command
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
      :type => Watir::Browser.browser_names, 
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

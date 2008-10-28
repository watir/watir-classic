# watir/options

require 'user-choices'

module Watir
  @@options_file = nil
  @@options = nil
  @@default_browser = 'ie'
  class << self
    def options_file= file
      @@options_file = file
    end
    def options_file
      @@options_file
    end
    def options= x
      @@options = x
    end
    def options
      @@options ||= Watir::Options.new.execute
    end
    def default_browser= browser_option
      @@default_browser = browser_option
    end
    def default_browser
      @@default_browser
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
      :type => ['firefox', 'ie', 'Firefox', 'IE'], 
      :default => Watir.default_browser
      builder.add_choice :speed, 
      :type => ['slow', 'fast', 'zippy'], 
      :default => 'fast'
    end
    def execute 
      @user_choices[:browser].downcase!
      @user_choices
    end 
  end
end
require 'user-choices'

module Watir
  module UnitTest
    class Options < UserChoices::Command
      include UserChoices
      def add_sources builder
        builder.add_source EnvironmentSource, :with_prefix, 'watir_'
        builder.add_source YamlConfigFileSource, :from_complete_path, 
          $myDir + '/options.yml' 
      end
      def add_choices builder
        builder.add_choice :browser, :type => ['firefox', 'ie', 'Firefox', 'IE'], 
        :default => 'ie'
        builder.add_choice :speed, :type => ['slow', 'fast', 'zippy'], :default => 'fast'
      end
      def execute 
        @user_choices[:browser].downcase!
        @user_choices
      end 
    end
    def self.options= x
      @@options = x
    end
    def self.options
      @@options
    end
  end
end

# setup/options
require 'user-choices'

module Watir
  module UnitTest
    class Options < UserChoices::Command
      include UserChoices
      def add_sources builder
        builder.add_source EnvironmentSource, :with_prefix, 'watir_'
        builder.add_source YamlConfigFileSource, :from_complete_path, 
          $suite_options_file
      end
      def add_choices builder
        builder.add_choice :coverage,
        :type => ['regression', 'all', 'known failures'],
        :default => 'regression'
      end
      def execute 
        Watir::UnitTest.options = @user_choices
      end 
    end
    def self.options
      @@options
    end
    def self.options= x
      @@options = x
    end
  end
end

# ActionOrchestrator is (mostly) tested indirectly through the
# command-line and HTML actions (especially the command-line).

require 'timeclock/marshalled/include-all'
require 'timeclock/client/ActionOrchestrator'
require 'timeclock/util/RichlyCallingWrapper'
require 'timeclock/util/RichlyCalledWrapper'
require 'timeclock/util/test-util'

module Timeclock
  module Client

    class ActionOrchestratorTests < Test::Unit::TestCase

      def setup
        @session = RichlyCallingWrapper.new(RichlyCalledWrapper.new(Server::Session.new("action orchestrator tests")))
        @orchestrator = ActionOrchestrator.test_instance(@session)
      end

      def teardown
        @session.forget_everything

      end
      
      def test_action_symbol_to_class
        assert_equal(AtAction, @orchestrator.action_symbol_to_action_class(:at))
        assert_equal(AddRecordAction, 
                     @orchestrator.action_symbol_to_action_class(:add_record))
      end

      def test_result_descriptions_are_fetched
        @orchestrator.attempt(:job, 'hello')
        assert_equal("Job 'hello' created.",
                     @orchestrator.describe_result_for_command_line)

        # As you'd expect, you can fetch the result twice.
        assert_equal("Job 'hello' created.",
                     @orchestrator.describe_result_for_command_line)
      end

    end
  end
end

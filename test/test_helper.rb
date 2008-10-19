require 'test/unit'
require 'test/unit/ui/console/testrunner'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'growling_test'
require 'dtr'
require 'dtr/test_unit'
DTR.configuration.master_heartbeat_interval = 2
DTR.configuration.follower_listen_heartbeat_timeout = 3

require File.dirname(__FILE__) + '/agent_helper'
require File.dirname(__FILE__) + '/logger_stub'

ENV['DTR_ENV'] = 'test'

module Test
  module Unit
    class TestCase
      def assert_false(o)
        assert !o
      end
      def assert_fork_process_exits_ok(&block)
        pid = Process.fork do
          Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../testdata/")) do
            setup_test_env
            with_agent_helper_group(&block)
          end
          exit 0
        end
        Process.waitpid pid
        assert_equal 0, $?.exitstatus
      ensure
        DTR.kill_process pid
      end

      def with_agent_helper_group(&block)
        DTR.configuration.group = DTR::AgentHelper::GROUP
        begin
          block.call
        ensure
          DTR.configuration.group = nil
        end
      end

      def setup_test_env
        require 'a_test_case'
        require 'a_test_case2'
        require 'a_failed_test_case'
        require 'an_error_test_case'
        require 'a_file_system_test_case'
        require 'scenario_test_case'
        require 'setup_agent_env_test_case'
        DTR.inject
      end

      def runit(suite)
        Test::Unit::UI::Console::TestRunner.run(suite, Test::Unit::UI::SILENT)
      end
      def clear_configuration
        DTR::EnvStore.destroy
        DTR.configuration.load
      end
    end
  end
end

class Test::Unit::TestResult
  attr_reader :failures, :errors
end

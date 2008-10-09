require 'test/unit'
require 'test/unit/ui/console/testrunner'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
# require 'growling_test'
require 'dtr'
require 'dtr/test_unit'
DTR.configuration.master_yell_interval = 2
DTR.configuration.follower_listen_sleep_timeout = 3

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
          block.call
          exit 0
        end
        Process.waitpid pid
        assert_equal 0, $?.exitstatus
      ensure
        Process.kill 'TERM', pid rescue nil
      end
      def runit(suite)
        Test::Unit::UI::Console::TestRunner.run(suite, Test::Unit::UI::SILENT)
      end
    end
  end
end

class Test::Unit::TestResult
  attr_reader :failures, :errors
end

require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class SyncLoggerTest < Test::Unit::TestCase
  
  def setup
    start_agents(:size => 1)
  end

  def teardown
    stop_agents
  end

  def test_master_process_should_get_log_of_agents
    @logger = LoggerStub.new
    assert_fork_process_exits_ok do
      DTR.logger = @logger

      $argv_dup = ['a_test_case.rb']
      suite = Test::Unit::TestSuite.new('master_process_should_get_log_of_agents')
      suite << ATestCase.suite
      runit(suite)

      logs = @logger.logs.flatten.join("\n")
      # puts logs
      assert(/From #{Socket.gethostname}: => Herald starts off/ =~ logs)
      assert(/From #{Socket.gethostname}: runner0: test files loaded/ =~ logs)
      #when use Delegator to implement UndumpedLogger, there are lots of 'nil' in the log
      assert(/nil/ !~ logs)
    end
  ensure
    @logger.clear
  end
end
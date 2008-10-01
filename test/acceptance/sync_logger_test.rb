require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class SyncLoggerTest < Test::Unit::TestCase
  
  def setup
    @logger = LoggerStub.new
    DTR.logger = @logger
    start_agents
    unless defined?(ATestCase)
      require 'a_test_case'
    end
    DTR.inject
  end

  def teardown
    DTR.reject
    stop_agents
    $argv_dup = nil
    Process.waitall
    DTR.logger = nil
    @logger.clear
  end

  def test_master_process_should_get_log_of_agents
    $argv_dup = ['a_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_master_process_should_get_log_of_agents')
    suite << ATestCase.suite
    assert_fork_process_exits_ok do
      runit(suite)
    end
    logs = @logger.logs.flatten.join("\n")
    assert(/From #{Socket.gethostname}: => Herald starts off\.\.\./ =~ logs)
    assert(/From #{Socket.gethostname}: runner0: test files loaded/ =~ logs)
    #when use Delegator to implement UndumpedLogger, there are lots of 'nil' in the log
    assert(/nil/ !~ logs)
  end
end
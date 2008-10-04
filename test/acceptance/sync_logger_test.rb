require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/test_unit'

include DTR::AgentHelper

class SyncLoggerTest < Test::Unit::TestCase
  
  def setup
    start_agents
    # put these here for we don't want run them in current process
    @pwd = Dir.pwd
    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/"))
    require 'a_test_case'
    @logger = LoggerStub.new
    DTR.logger = @logger
    DTR.inject
  end

  def teardown
    DTR.reject
    Dir.chdir(@pwd)
    stop_agents
    $argv_dup = nil
    DTR.logger = nil
    @logger.clear
  end

  #todo fix random failure
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
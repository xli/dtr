require File.dirname(__FILE__) + '/test_helper'
require 'dtr/base.rb'

class BaseTest < Test::Unit::TestCase
  def setup
    @env_store = DTR::EnvStore.new
    @env_store[DTR::MESSAGE_KEY] = nil
    @logger_level = DTR.logger.level
  end
  
  def teardown
    DTR.logger.level = @logger_level
    @env_store[DTR::MESSAGE_KEY] = nil if @env_store[DTR::MESSAGE_KEY]
    DTROPTIONS[:run_with_monitor] = nil
  end
  
  def test_should_include_error_log_when_interrupt_by_command
    DTR.logger.level = Logger::ERROR
    DTROPTIONS[:run_with_monitor] = true
    assert DTR::Cmd.execute("echo 'message'")
    assert_nil @env_store[DTR::MESSAGE_KEY]
    
    assert !DTR::Cmd.execute("not_a_cmd args")
    assert @env_store[DTR::MESSAGE_KEY].last.include?("not_a_cmd")

    assert !DTR::Cmd.execute("rake --rakefile #{File.dirname(__FILE__)}/../testdata/Rakefile not_exist_task")
    assert @env_store[DTR::MESSAGE_KEY].last.include?("rake aborted!")
  end
  
  def test_identifier_of_working_env
    assert_not_equal DTR::WorkingEnv.refresh[:identifier], DTR::WorkingEnv.refresh[:identifier]
  end
  
  def test_working_env_equal
    env1 = DTR::WorkingEnv.refresh
    env2 = DTR::WorkingEnv.refresh
    assert_not_equal env1, env2
    env2[:identifier] = env1[:identifier]
    assert env1 == env2
    assert env2 != nil
    assert nil != env2
  end
  
end
require File.dirname(__FILE__) + '/unit_test_helper'
require 'dtr/utils.rb'

class UtilsTest < Test::Unit::TestCase
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

end

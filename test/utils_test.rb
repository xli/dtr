require File.dirname(__FILE__) + '/unit_test_helper'

class UtilsTest < Test::Unit::TestCase
  def setup
    @logger_level = DTR.logger.level
  end
  
  def teardown
    DTR.logger.level = @logger_level
  end
  
  def test_empty
    
  end
  
  #todo don't know how to do this yet
  def xtest_should_include_error_log_when_interrupt_by_command
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
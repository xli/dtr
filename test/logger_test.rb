require File.dirname(__FILE__) + '/unit_test_helper'

class LoggerTest < Test::Unit::TestCase
  def setup
    @logger_level = DTR.logger.level
  end
  
  def teardown
    DTR.logger.level = @logger_level
  end
  
  def test_should_be_silent_when_logger_level_is_error
    DTR.logger.level = Logger::INFO
    assert !DTR.silent?
    DTR.logger.level = Logger::DEBUG
    assert !DTR.silent?
    DTR.logger.level = Logger::ERROR
    assert DTR.silent?
  end
  
end

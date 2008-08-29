require File.dirname(__FILE__) + '/test_helper'
require 'dtr/base.rb'

class LoggerTest < Test::Unit::TestCase
  def setup
    @env_store = DTR::EnvStore.new
    @env_store[DTR::MESSAGE_KEY] = nil
    @logger_level = DTR.logger.level
  end
  
  def teardown
    DTROPTIONS[:run_with_monitor] = nil
    DTR.logger.level = @logger_level
    @env_store[DTR::MESSAGE_KEY] = nil if @env_store[DTR::MESSAGE_KEY]
  end
  
  def test_should_be_silent_when_logger_level_is_error
    DTR.logger.level = Logger::INFO
    assert !DTR.silent?
    DTR.logger.level = Logger::DEBUG
    assert !DTR.silent?
    DTR.logger.level = Logger::ERROR
    assert DTR.silent?
  end
  
  def test_should_put_message_into_queue_when_run_with_monitor
    DTROPTIONS[:run_with_monitor] = true
    DTR.logger.level = Logger::DEBUG
    DTR.error('error')
    assert_equal 1, @env_store[DTR::MESSAGE_KEY].size
    DTR.error{'error'}
    assert_equal 2, @env_store[DTR::MESSAGE_KEY].size

    DTR.info('info')
    assert_equal 3, @env_store[DTR::MESSAGE_KEY].size
    DTR.info{'info'}
    assert_equal 4, @env_store[DTR::MESSAGE_KEY].size

    DTR.debug('debug')
    assert_equal 5, @env_store[DTR::MESSAGE_KEY].size
    DTR.debug{'debug'}
    assert_equal 6, @env_store[DTR::MESSAGE_KEY].size
  end
  
  def test_shift_message
    assert_nil @env_store[DTR::MESSAGE_KEY]
    @env_store.shift(DTR::MESSAGE_KEY)
    assert_nil @env_store[DTR::MESSAGE_KEY]
    @env_store[DTR::MESSAGE_KEY] = ['message']
    @env_store.shift(DTR::MESSAGE_KEY)
    assert @env_store[DTR::MESSAGE_KEY].empty?
  end
  
end
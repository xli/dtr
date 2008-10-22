require File.dirname(__FILE__) + '/../test_helper'

require 'dtr/agent/sync_logger'
require 'stringio'
#logger related unit test, including sync_logger
class LoggerTest < Test::Unit::TestCase
  def setup
    @msg = nil
  end

  def teardown
    DTR.logger = DTR.create_default_logger(nil)
  end

  def test_should_not_send_message_when_message_logger_level_is_not_enough
    DTR.logger = DTR::SyncLogger::MessageDecoratedLogger.new(self)
    @msg = nil
    DTR.debug('debug msg')
    assert_nil @msg
  end

  def test_send_message
    DTR.logger = DTR::SyncLogger::MessageDecoratedLogger.new(self)
    DTR.info('info msg')
    assert_equal "From #{Socket.gethostname}: info msg", @msg
    DTR.info('error msg')
    assert_equal "From #{Socket.gethostname}: error msg", @msg
  end

  def test_send_message_by_block_should_be_sent_as_string_msg
    DTR.logger = DTR::SyncLogger::MessageDecoratedLogger.new(self)
    DTR.info { 'info msg' }
    assert_equal "From #{Socket.gethostname}: info msg", @msg
  end

  def test_should_output_error_into_stderr
    logs = catch_stderr_output do
      DTR.debug {'debug info'}
      DTR.info {'info info'}
      DTR.error {'error info'}
    end
    assert(/error info/ =~ logs)
    assert(/info info/ !~ logs)
    assert(/debug info/ !~ logs)
  end

  def catch_stderr_output
    stderr = $stderr
    $stderr = StringIO.new
    yield
    $stderr.rewind
    $stderr.read
  ensure
    $stderr = stderr
  end

  def level
    Logger::INFO
  end

  def debug(msg)
    @msg = msg
  end

  def error(msg)
    @msg = msg
  end

  def info(msg)
    @msg = msg
  end
end
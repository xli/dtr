require File.dirname(__FILE__) + '/../test_helper'

class FileServiceTest < Test::Unit::TestCase
  include DTR::FileService
  TEST_PORT = 8888
  def test_copy_file
    File.open(DTR::FileService::CODEBASE_FILENAME, 'w') do |f|
      f.syswrite("codebase\n")
    end
    
    start_server(TEST_PORT)
    request_file('localhost', TEST_PORT)
    
    assert File.exists?("copy_#{DTR::FileService::CODEBASE_FILENAME}")
    assert_equal "codebase\n", File.open("copy_#{DTR::FileService::CODEBASE_FILENAME}", 'r'){|f|f.read}
  ensure
    @server.shutdown rescue nil
    Thread.kill @acceptor rescue nil
    File.delete(DTR::FileService::CODEBASE_FILENAME) rescue nil
    File.delete('copy_' + DTR::FileService::CODEBASE_FILENAME) rescue nil
  end
end
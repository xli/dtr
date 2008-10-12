require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/facade'

class FacadeTest < Test::Unit::TestCase
  include DTR::Facade
  def test_lib_path
    expected = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    assert_equal expected, lib_path
  end

  def test_save_broadcast_list
    DTR::EnvStore.destroy
    self.broadcast_list = ['10.18.255.255']
    assert_equal ['10.18.255.255'], DTR::EnvStore.new[:broadcast_list]
  ensure
    DTR::EnvStore.destroy
  end

  def test_save_port
    DTR::EnvStore.destroy
    self.port = '3456'
    assert_equal '3456', DTR::EnvStore.new[:port]
  ensure
    DTR::EnvStore.destroy
  end

  def fork_and_kill_process
    pid = fork_process do
      loop do
      end
    end
    kill_process pid
    Timeout.timeout(1) do
      Process.waitall
    end
  end
end
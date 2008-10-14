require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/facade'

class FacadeTest < Test::Unit::TestCase
  include DTR::Facade

  def teardown
    clear_configuration
  end

  def test_lib_path
    expected = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    assert_equal expected, lib_path
  end

  def test_save_broadcast_list
    self.broadcast_list = ['10.18.255.255']
    assert_equal ['10.18.255.255'], DTR::EnvStore.new[:broadcast_list]
  end

  def test_save_group
    self.group = 'mingle'
    assert_equal 'mingle', DTR::EnvStore.new[:group]
  end

  def test_save_agent_listen_port
    self.agent_listen_port = '7890'
    assert_equal '7890', DTR::EnvStore.new[:agent_listen_port]
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
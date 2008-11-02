require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class AdapterTest < Test::Unit::TestCase
  include DTR::Adapter::Master
  include DTR::Adapter::Follower

  def setup
    @host_ip = nil
    @timeout = false
    @messages = []
    DTR.root = Dir.pwd
    DTR.logger('test.log')
    DTR.configuration.follower_listen_heartbeat_timeout = 1
  end

  def teardown
    DTR.configuration.refresh
    DTR.root = nil
  end

  def test_should_be_sleep_if_never_wakeup
    assert sleep?
    assert !wakeup?
    assert sleep?
    do_wakeup_agents
    assert wakeup?
    do_wakeup_agents
    assert !sleep?
  end

  def test_wakeup_by_broadcast_message
    assert !wakeup?
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 4567")
    assert wakeup?
  end

  def test_should_be_sleep_after_hypnotized_waked_up_agents
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 4567")
    assert wakeup?
    hypnotize_agents
    assert sleep?
  end

  def test_do_wakeup_agents
    assert !wakeup?
    do_wakeup_agents
    assert wakeup?

    do_wakeup_agents
    assert !sleep?
  end

  def test_hypnotize_agents_after_did_waked_up_agents
    do_wakeup_agents
    assert wakeup?
    hypnotize_agents
    assert sleep?
  end

  def test_should_not_be_sleep_when_sleep_message_is_sent_from_different_port_with_wakeup_message
    @host_ip = '10.18.1.1'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert wakeup?
    #sleep message should be ignored
    broadcast('address', "#{DTR::Adapter::SLEEP_MESSAGE} 4567")
    #wakup message for keep it wakeup
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert !sleep?
  end

  def test_should_not_be_sleep_when_sleep_message_is_sent_from_different_hostname_with_wakeup_message
    @host_ip = '10.18.1.1'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert wakeup?
    #sleep message should be ignored
    @host_ip = '192.168.1.1'
    broadcast('address', "#{DTR::Adapter::SLEEP_MESSAGE} 1234")
    #wakup message for keep it wakeup
    @host_ip = '10.18.1.1'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert !sleep?
  end

  def test_should_update_rinda_server_port_parsed_from_wakeup_message
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 4567")
    assert wakeup?
    assert_equal 4567, DTR.configuration.rinda_server_port
  end

  def test_should_be_sleep_when_timeout_on_listen
    do_wakeup_agents
    assert wakeup?
    @timeout = true
    assert sleep?
  end

  def test_should_be_sleep_when_timeout_on_listen_to_host_sending_wakeup_message
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert wakeup?
    @host_ip = 'dtr.remote'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    sleep(2)
    assert sleep?
  end

  def test_should_match_group_configured_when_receive_wakeup_cmd
    DTR.configuration.group = 'mingle'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert !wakeup?
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234 mingle")
    assert wakeup?
  end

  def test_should_not_need_match_group_configured_when_receive_sleep_cmd
    DTR.configuration.group = 'mingle'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234 mingle")
    assert wakeup?
    broadcast('address', "#{DTR::Adapter::SLEEP_MESSAGE} 1234")
    assert sleep?
  end

  def test_do_wakeup_agents_should_include_group_configured
    DTR.configuration.group = 'mingle'
    do_wakeup_agents
    assert wakeup?
  end

  def test_should_reset_broadcast_configuration_as_master_process_ip
    @host_ip = '10.18.1.1'
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} 1234")
    assert wakeup?
    assert_equal ['10.18.1.1'], DTR.configuration.broadcast_list
  end

  def listen
    raise Timeout::Error.new('timeout') if @timeout
    cmd, port, group, host_ip = @messages.shift.to_s.split
    if host_ip.nil?
      host_ip = group
      group = nil
    end
    [cmd, "#{host_ip}:#{port}", group]
  end

  def broadcast(it, msg)
    host_ip = @host_ip || Socket.gethostname
    @messages << "#{msg} #{host_ip}"
  end
end
require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class AdapterTests < Test::Unit::TestCase
  include DTR::Adapter::Master
  include DTR::Adapter::Follower

  def setup
    @messages = []
  end

  def test_should_be_sleep_if_never_wakeup
    assert sleep?
    assert !wakeup?
    assert sleep?
    do_wakeup_agents
    assert wakeup?
    assert !sleep?
  end

  def test_wakeup_by_broadcast_message
    assert !wakeup?
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} #{Socket.gethostname}:4567")
    assert wakeup?
  end

  def test_should_be_sleep_after_hypnotized_waked_up_agents
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} #{Socket.gethostname}:4567")
    assert wakeup?
    hypnotize_agents
    assert sleep?
  end

  def test_do_wakeup_agents
    assert !wakeup?
    do_wakeup_agents
    assert wakeup?
    assert !sleep?
  end

  def test_hypnotize_agents_after_did_waked_up_agents
    do_wakeup_agents
    assert wakeup?
    hypnotize_agents
    assert sleep?
  end

  def test_should_not_be_sleep_when_sleep_message_is_sent_from_different_port_with_wakeup_message
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} hostname:1234")
    assert wakeup?
    broadcast('address', "#{DTR::Adapter::SLEEP_MESSAGE} hostname:4567")
    assert !sleep?
  end

  def test_should_not_be_sleep_when_sleep_message_is_sent_from_different_hostname_with_wakeup_message
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} xli.local:1234")
    assert wakeup?
    broadcast('address', "#{DTR::Adapter::SLEEP_MESSAGE} dtr.remote:1234")
    assert !sleep?
  end

  def test_should_update_rinda_server_port_parsed_from_wakeup_message
    broadcast('address', "#{DTR::Adapter::WAKEUP_MESSAGE} hostname:4567")
    assert wakeup?
    assert_equal 4567, DTR.configuration.rinda_server_port
  end

  def listen
    @messages.shift.to_s.split
  end

  def broadcast(it, msg)
    @messages << msg
  end
end
require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationTest < Test::Unit::TestCase
  def teardown
    clear_configuration
  end

  def test_should_not_save_rinda_server_port
    DTR.configuration.rinda_server_port = '3456'
    assert_equal '3456', DTR.configuration.rinda_server_port
    assert_nil DTR::EnvStore.new[:rinda_server_port]
  end

  def test_group_defualt_is_dangerous_group
    assert_nil DTR.configuration.group
  end

  def test_group
    DTR.configuration.group = 'mingle'
    assert_equal 'mingle', DTR.configuration.group
    DTR.configuration.save
    assert_equal 'mingle', DTR::EnvStore.new[:group]
  end

  def test_should_save_as_nil_when_group_is_blank
    DTR.configuration.group = ''
    assert_nil DTR.configuration.group
    DTR.configuration.save
    assert_nil DTR::EnvStore.new[:group]
  end

  def test_shoul_convert_space_in_group_name_to_underscore
    DTR.configuration.group = 'mingle group'
    assert_equal 'mingle_group', DTR.configuration.group
    DTR.configuration.save
    assert_equal 'mingle_group', DTR::EnvStore.new[:group]
  end

  def test_load
    DTR::EnvStore.new[:group] = 'new group'
    DTR.configuration.load
    assert_equal 'new group', DTR.configuration.group
  end

  def test_agent_env_setup_cmd
    DTR.configuration.agent_env_setup_cmd = 'rake db:test:prepare'
    assert_equal 'rake db:test:prepare', DTR.configuration.agent_env_setup_cmd
    DTR.configuration.save
    assert_equal 'rake db:test:prepare', DTR::EnvStore.new[:agent_env_setup_cmd]
  end

  def test_agent_runners
    DTR.configuration.agent_runners = ['r1', 'r2']
    assert_equal ['r1', 'r2'], DTR.configuration.agent_runners
    DTR.configuration.save
    assert_equal ['r1', 'r2'], DTR::EnvStore.new[:agent_runners]
  end

  def test_working_env_should_be_saved_directly
    env = DTR::WorkingEnv.new
    DTR.configuration.working_env = env
    assert_equal env, DTR.configuration.working_env
    assert_equal env, DTR::EnvStore.new[:working_env]
  end

  def test_working_env_should_always_load_from_pstore
    env = DTR::WorkingEnv.new
    DTR::EnvStore.new[:working_env] = env
    assert_equal env, DTR.configuration.working_env
  end
end

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
end
require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/agent/working_env_ext'
DTR::WorkingEnv.send(:include, DTR::Agent::WorkingEnvExt)

class WorkingEnvTest < Test::Unit::TestCase
  def test_identifier_of_working_env
    assert_not_equal DTR::WorkingEnv.new[:identifier], DTR::WorkingEnv.new[:identifier]
  end
  
  def test_working_env_equal
    env1 = DTR::WorkingEnv.new
    env2 = DTR::WorkingEnv.new
    assert_not_equal env1, env2
    env2[:identifier] = env1[:identifier]
    assert env1 == env2
    assert env2 != nil
    assert nil != env2
  end

  def test_env_base_dir_should_be_based_on_host_and_pwd
    env = DTR::WorkingEnv.new
    env[:pwd] = 'pwd'
    env[:host] = 'hostname'
    base_dir = env.base_dir
    assert_equal File.expand_path('hostname/pwd'), base_dir
  ensure
    FileUtils.rm_rf File.expand_path('hostname')
  end

  def test_should_truncate_pwd_if_it_is_too_long_for_base_dir
    env = DTR::WorkingEnv.new
    env[:pwd] = 'pwd_pwd_pwd_pwd_pwd_pwd_pwd_pwd_pwd_pwd' #40
    env[:host] = 'hostname'
    base_dir = env.base_dir
    assert_equal File.expand_path('hostname/_pwd_pwd_pwd_pwd_pwd'), base_dir
  ensure
    FileUtils.rm_rf File.expand_path('hostname')
  end

  def test_should_convert_non_word_and_number_in_dir_string_to_underscore
    env = DTR::WorkingEnv.new
    env[:pwd] = 'pwd pwd' #40
    env[:host] = 'xli.local:1234'
    base_dir = env.base_dir
    assert_equal File.expand_path('xli_local_1234/pwd_pwd'), base_dir
  ensure
    FileUtils.rm_rf File.expand_path('xli_local_1234')
  end

  def test_base_dir_should_be_created_if_it_does_not_exist
    env = DTR::WorkingEnv.new
    env[:pwd] = 'pwd'
    env[:host] = 'hostname'

    assert !File.exists?(File.expand_path('hostname'))
    base_dir = env.base_dir
    assert File.exists?(base_dir)
  ensure
    FileUtils.rm_rf File.expand_path('hostname')
  end
end

require File.dirname(__FILE__) + '/unit_test_helper'
require 'dtr/working_env.rb'

class WorkingEnvTest < Test::Unit::TestCase
  def test_identifier_of_working_env
    assert_not_equal DTR::WorkingEnv.refresh[:identifier], DTR::WorkingEnv.refresh[:identifier]
  end
  
  def test_working_env_equal
    env1 = DTR::WorkingEnv.refresh
    env2 = DTR::WorkingEnv.refresh
    assert_not_equal env1, env2
    env2[:identifier] = env1[:identifier]
    assert env1 == env2
    assert env2 != nil
    assert nil != env2
  end
end

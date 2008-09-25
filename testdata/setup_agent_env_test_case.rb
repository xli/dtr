require 'test/unit'
class SetupAgentEnvTestCase < Test::Unit::TestCase

  def test_setup_agent_env_test_case
    assert File.exists?('/tmp/test_setup_agent_env_from_master_process')
  end

end


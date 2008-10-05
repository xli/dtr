require 'test/unit'

class VerifyDirPwdTestCase < Test::Unit::TestCase

  def test_should_not_sync_codebase_and_setup_working_dir_when_agent_is_in_same_dir_with_master_process
    assert_equal 'should_not_sync_codebase_and_setup_working_dir_when_agent_is_in_same_dir_with_master_process', Dir.pwd.split('/').last
  end

end


require 'test/unit'
class ScenarioTestCase < Test::Unit::TestCase
  
  def test_run_test_failed
    assert_equal '1', '2'
  end
  
  def test_run_test_passed
    assert_eqaul '1', '1'
  end
  
  def test_run_test_error
    assert false
  end

  def test_runner_should_setup_env
    'should'.raise.error
  end

  def test_runner_should_not_setup_env_twice
  end
  
  def test_runner_should_update_code
    assert_equal ['1'], '1' + nil
  end
  
  def test_execution
    assert nil.empty?
  end
  
  def test_runner_should_rollback_popped_test
    assert_equal ['1'], '1'
  end
end
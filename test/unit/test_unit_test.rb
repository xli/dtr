require File.dirname(__FILE__) + '/../test_helper'

class TestUnitTest < Test::Unit::TestCase
  
  def teardown
    DTR.reject
  end

  # inject testcase as late as possible, for in ruby world there is lots hacks added to TestCase#run method,
  # DTR should be the last one to add dtr injection chain into run method
  def test_should_only_inject_test_runner_mediator_for_lauching_dtr
    DTR.inject
    assert Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)
    assert Test::Unit::UI::TestRunnerMediator.method_defined?(:run_suite_without_dtr_injection)
    assert Test::Unit::UI::TestRunnerMediator.private_method_defined?(:create_result_without_thread_safe)
  end

  def test_reject
    DTR.inject
    DTR.reject
    assert !Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)
    assert !Test::Unit::UI::TestRunnerMediator.method_defined?(:run_suite_without_dtr_injection)
    assert !Test::Unit::UI::TestRunnerMediator.private_method_defined?(:create_result_without_thread_safe)
  end
  
end

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
    assert !Test::Unit::TestCase.respond_to?(:reject_dtr)
    assert !Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
  end

  def test_inject_testcase
    Test::Unit::TestCase.send(:include, DTR::TestUnit::TestCaseInjection)
    begin
      assert Test::Unit::TestCase.respond_to?(:reject_dtr)
      assert Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
    ensure
      Test::Unit::TestCase.reject_dtr
    end
    assert !Test::Unit::TestCase.respond_to?(:reject_dtr)
    assert !Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
  end

  def test_reject
    DTR.inject
    DTR.reject
    test_case = Test::Unit::TestCase.new('name')
    assert_false test_case.respond_to?(:run_without_dtr_injection)
    assert test_case.respond_to?(:run)

    assert !Test::Unit::TestCase.respond_to?(:reject_dtr)
    assert !Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)

    assert !Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
    assert !Test::Unit::UI::TestRunnerMediator.method_defined?(:run_suite_without_dtr_injection)
    assert !Test::Unit::UI::TestRunnerMediator.private_method_defined?(:create_result_without_thread_safe)
  end
  
end

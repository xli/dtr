require File.dirname(__FILE__) + '/../test_helper'

class TestUnitTest < Test::Unit::TestCase
  
  def teardown
    DTR.reject
  end
  
  def test_inject
    DTR.inject
    assert Test::Unit::TestCase.respond_to?(:reject_dtr)
    assert Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)

    assert Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
    assert Test::Unit::UI::TestRunnerMediator.method_defined?(:run_suite_without_dtr_injection)
    assert Test::Unit::UI::TestRunnerMediator.private_method_defined?(:create_result_without_thread_safe)
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

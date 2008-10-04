require File.dirname(__FILE__) + '/../test_helper'

class TestUnitTest < Test::Unit::TestCase
  
  def teardown
    DTR.reject
  end
  
  def test_inject
    DTR.inject
    assert Test::Unit::TestCase.method_defined?(:run_without_dtr_injection)
    assert Test::Unit::TestSuite.method_defined?(:run_without_dtr_injection)
    assert Test::Unit::TestSuite.method_defined?(:dtr_injected?)
  end
  
  def test_reject
    DTR.inject
    DTR.reject
    test_case = Test::Unit::TestCase.new('name')
    assert_false test_case.respond_to?(:run_without_dtr_injection)
    assert test_case.respond_to?(:run)
  end
  
end

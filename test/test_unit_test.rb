require File.dirname(__FILE__) + '/unit_test_helper'
require 'dtr/test_unit.rb'

class InjectTest < Test::Unit::TestCase
  
  def teardown
    DTR.reject
  end
  
  def test_inject
    DTR.inject
    assert Test::Unit::TestCase.method_defined?(:__run__)
    assert Test::Unit::TestSuite.method_defined?(:__run__)
    assert Test::Unit::TestSuite.method_defined?(:dtr_injected?)
  end
  
  def test_reject
    DTR.inject
    DTR.reject
    test_case = Test::Unit::TestCase.new('name')
    assert_false test_case.respond_to?(:__run__)
    assert test_case.respond_to?(:run)
  end
  
end

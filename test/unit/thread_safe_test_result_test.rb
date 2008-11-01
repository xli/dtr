require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/test_unit/thread_safe_test_result'

class ThreadSafeTestResultTest < Test::Unit::TestCase
  class DRbObjectStub
    def initialize(uri)
      @uri = uri
    end
  end
  def test_should_sort_runner_test_results
    results = DTR::TestUnit::ThreadSafeTestResult::RunnerTestResults.new
    runner1 = DRbObjectStub.new('runner1')
    runner2 = DRbObjectStub.new('runner2')
    runner3 = DRbObjectStub.new('runner3')
    r1 = results.fetch(runner1)
    r1.add_run

    r2 = results.fetch(runner2)
    r2.add_run
    r2.add_run
    r2.add_run

    r3 = results.fetch(runner3)
    r3.add_run
    r3.add_run

    assert_equal %{runner2 => 3 tests, 0 assertions, 0 failures, 0 errors
runner3 => 2 tests, 0 assertions, 0 failures, 0 errors
runner1 => 1 tests, 0 assertions, 0 failures, 0 errors}, results.to_s
  end

  def test_pair_should_multicast_messages
    r1 = Test::Unit::TestResult.new
    r2 = Test::Unit::TestResult.new
    pair = DTR::TestUnit::ThreadSafeTestResult::Pair.new(r1, r2)
    pair.add_run

    assert_equal 1, r1.run_count
    assert_equal 1, r2.run_count
  end
end

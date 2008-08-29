require File.dirname(__FILE__) + '/test_helper'
require 'test/unit/ui/console/testrunner'
require 'dtr/service_provider'
require 'dtr/test_unit'
require 'dtr'
require 'socket'
# DTROPTIONS[:log_level] = Logger::DEBUG

class Test::Unit::TestResult
  attr_reader :failures, :errors
end

class ScenarioTests < Test::Unit::TestCase

  def setup
    unless defined?(ATestCase)
      require 'a_test_case'
      require 'a_test_case2'
      require 'a_failed_test_case'
      require 'an_error_test_case'
      require 'a_file_system_test_case'
      require 'scenario_test_case'
    end
    DTR.inject
  end
  
  def teardown
    DTR.reject
    $argv_dup = nil
  end
  
  def test_run_test_passed
    $argv_dup = ['a_test_case.rb', 'a_test_case2.rb', 'a_file_system_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_passed')
    suite << ATestCase.suite
    suite << ATestCase2.suite
    suite << AFileSystemTestCase.suite

    @result = runit(suite)
    
    assert @result.passed?
    assert_equal 3, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 0, @result.error_count
  end
  
  def test_run_test_failed
    $argv_dup = ['a_test_case.rb', 'a_failed_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_failed')
    suite << ATestCase.suite
    suite << AFailedTestCase.suite
    
    @result = runit(suite)

    assert !@result.passed?
    assert_equal 2, @result.run_count
    assert_equal 1, @result.failure_count
    assert_equal 0, @result.error_count
  end
   
  def test_run_test_error
    $argv_dup = ['a_test_case.rb', 'an_error_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_error')
    suite << ATestCase.suite
    suite << AnErrorTestCase.suite
    
    DTR.debug { "dtr_injected: #{Test::Unit::TestSuite.method_defined?(:dtr_injected?)}" }
    @result = runit(suite)
    
    assert_false @result.passed?
    assert_equal 2, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 1, @result.error_count
  end
  
  def test_run_suite_should_be_independence
    $argv_dup = ['an_error_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 1')
    suite << AnErrorTestCase.suite
    
    @result = runit(suite)
    
    assert_false @result.passed?
    assert_equal 1, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 1, @result.error_count

    $argv_dup = ['a_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 2')
    suite << ATestCase.suite

    @result = runit(suite)

    assert @result.passed?
    assert_equal 1, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 0, @result.error_count
  end
  
  def test_should_ignore_environment_file_not_exists
    $argv_dup = ['a_test_case.rb', 'test_file_not_exists.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_file_not_exist')
    suite << ATestCase.suite

    @result = runit(suite)

    assert @result.passed?
    assert_equal 1, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 0, @result.error_count
  end
  
  def test_run_empty_test_suite_and_no_test_files_in_environment
    $argv_dup = []
    suite = Test::Unit::TestSuite.new('test_run_without_test_files')

    @result = runit(suite)

    assert @result.passed?
    assert_equal 0, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 0, @result.error_count
  end
  
  def test_run_test_specified_by_load_path
    lib_path = File.expand_path(File.dirname(__FILE__) + '/../testdata/lib')
    $LOAD_PATH.unshift lib_path
    require 'lib_test_case'
    $argv_dup = ['lib_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_specified_by_load_path')
    suite << LibTestCase.suite

    @result = runit(suite)
    
    assert @result.passed?
    assert_equal 1, @result.run_count
    assert_equal 0, @result.failure_count
    assert_equal 0, @result.error_count
  ensure
    $LOAD_PATH.delete lib_path
  end
  
  def test_message_of_errors_and_failures_should_include_runner_host_name
    $argv_dup = ['scenario_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_should_wrapper_errors_by_dtr_remote_exception')
    suite << ScenarioTestCase.suite

    @result = runit(suite)
    
    assert !@result.passed?
    assert_equal 8, @result.run_count
    assert_equal 3, @result.failure_count
    assert_equal 4, @result.error_count
    
    @result.errors.each do |e|
      assert e.message.include?("from #{Socket.gethostname}")
    end
    @result.failures.each do |e|
      assert e.message.include?("from #{Socket.gethostname}")
    end
  end

  def runit(suite)
    Test::Unit::UI::Console::TestRunner.run(suite, Test::Unit::UI::SILENT)
  end
end

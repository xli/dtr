require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class AgentWorkingEnvTest < Test::Unit::TestCase
  include DTR::Service::WorkingEnv
  def setup
    #start_agents first for test files loaded would be copied into sub processes
    start_agents
    DTR.inject
  end

  def teardown
    DTR.reject
    stop_agents
    $argv_dup = nil
  end

  def test_run_2_project_should_be_independence
    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/")) do
      $argv_dup = ['an_error_test_case.rb']
      require 'an_error_test_case'

      suite = Test::Unit::TestSuite.new('test_run_2_project_should_be_independence 1')
      suite << AnErrorTestCase.suite

      assert_fork_process_exits_ok do
        @result = runit(suite)

        assert_false @result.passed?
        assert_equal 1, @result.run_count
        assert_equal 0, @result.failure_count
        assert_equal 1, @result.error_count
      end
    end

    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/another_project")) do
      $argv_dup = ['passed_test_case.rb']
      require 'passed_test_case'
      suite = Test::Unit::TestSuite.new('test_run_2_project_should_be_independence 2')
      suite << PassedTestCase.suite

      assert_fork_process_exits_ok do
        @result = runit(suite)

        assert @result.passed?
        assert_equal 1, @result.run_count
        assert_equal 0, @result.failure_count
        assert_equal 0, @result.error_count
      end
    end
  end

  def test_run_same_project_twice_should_be_independence
    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/another_project")) do
      $argv_dup = ['passed_test_case.rb']
      require 'passed_test_case'
      suite = Test::Unit::TestSuite.new('test_run_same_project_twice_should_be_independence 1')
      suite << PassedTestCase.suite

      assert_fork_process_exits_ok do
        @result = runit(suite)

        assert @result.passed?
        assert_equal 1, @result.run_count
        assert_equal 0, @result.failure_count
        assert_equal 0, @result.error_count
      end
    end

    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/another_project")) do
      FileUtils.cp("./../an_error_test_case.rb", '.')
      begin
        $argv_dup = ['an_error_test_case.rb']
        require 'an_error_test_case'
        suite = Test::Unit::TestSuite.new('test_run_same_project_twice_should_be_independence 2')
        suite << AnErrorTestCase.suite

        assert_fork_process_exits_ok do
          @result = runit(suite)

          assert_false @result.passed?
          assert_equal 1, @result.run_count
          assert_equal 0, @result.failure_count
          assert_equal 1, @result.error_count
        end
      ensure
        FileUtils.rm_f('an_error_test_case.rb')
      end
    end
  end
end

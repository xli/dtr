require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class GeneralTest < Test::Unit::TestCase
  
  def setup
    start_agents
  end

  def teardown
    stop_agents
  end

  def test_run_test_passed
    assert_fork_process_exits_ok do
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
  end

  def test_run_test_failed
    assert_fork_process_exits_ok do
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
  end

  def test_run_test_error
    assert_fork_process_exits_ok do
      $argv_dup = ['a_test_case.rb', 'an_error_test_case.rb']
      suite = Test::Unit::TestSuite.new('test_run_test_error')
      suite << ATestCase.suite
      suite << AnErrorTestCase.suite

      @result = runit(suite)

      assert_false @result.passed?
      assert_equal 2, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
    end
  end

  def test_run_suite_should_be_independence
    assert_fork_process_exits_ok do
      $argv_dup = ['an_error_test_case.rb']
      suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 1')
      suite << AnErrorTestCase.suite

      @result = runit(suite)

      assert_false @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
    end

    assert_fork_process_exits_ok do
      $argv_dup = ['a_test_case.rb']
      suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 2')
      suite << ATestCase.suite

      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_should_ignore_environment_file_not_exists
    assert_fork_process_exits_ok do
      $argv_dup = ['a_test_case.rb', 'test_file_not_exists.rb']
      suite = Test::Unit::TestSuite.new('test_run_test_file_not_exist')
      suite << ATestCase.suite

      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_and_no_test_files_in_environment
    assert_fork_process_exits_ok do
      $argv_dup = []
      suite = Test::Unit::TestSuite.new('test_run_without_test_files')

      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_should_not_crash_agent
    assert_fork_process_exits_ok do
      $argv_dup = []
      suite = Test::Unit::TestSuite.new('test_run_empty_test_suite_should_not_crash_agent')

      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end

    assert_fork_process_exits_ok do
      $argv_dup = ['a_test_case.rb']
      suite = Test::Unit::TestSuite.new('test_run_empty_test_suite_should_not_crash_agent')
      suite << ATestCase.suite

      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_and_test_files_not_exist_in_environment
    assert_fork_process_exits_ok do
      $argv_dup = ['test_file_not_exists.rb']
      suite = Test::Unit::TestSuite.new('test_run_empty_test_suite_and_test_files_not_exist_in_environment')

      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_test_specified_by_load_path
    lib_path = File.expand_path(File.dirname(__FILE__) + '/../../testdata/lib')
    assert_fork_process_exits_ok do
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
    end
  end

  def test_message_of_errors_and_failures_should_include_runner_host_name
    assert_fork_process_exits_ok do
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
  end

  def test_setup_agent_env_from_master_process
    assert_fork_process_exits_ok do
      $argv_dup = ['setup_agent_env_test_case.rb']
      suite = Test::Unit::TestSuite.new('setup_agent_env_from_master_process')
      suite << SetupAgentEnvTestCase.suite
      ENV['DTR_AGENT_ENV_SETUP_CMD'] = 'touch /tmp/test_setup_agent_env_from_master_process'

      @result = runit(suite)
      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  ensure
    File.delete('/tmp/test_setup_agent_env_from_master_process') rescue nil
  end

  def test_multi_dtr_tasks_should_be_queued_and_processed_one_by_one
    testdata_dir = File.expand_path(File.dirname(__FILE__) + "/../../testdata/")
    process_assertion = Proc.new do |master_dir|
      FileUtils.cp_r testdata_dir, master_dir
      begin
        Dir.chdir(master_dir) do
          $argv_dup = ['a_test_case.rb', 'a_test_case2.rb', 'a_file_system_test_case.rb']
          setup_test_env
          suite = Test::Unit::TestSuite.new('run_test_passed')
          suite << ATestCase.suite
          suite << ATestCase2.suite
          suite << AFileSystemTestCase.suite
          with_agent_helper_group do
            result = runit(suite)
            assert result.passed?
            assert_equal 3, result.run_count
          end
        end
      ensure
        FileUtils.rm_rf master_dir
      end
    end

    @test_processes = []
    4.times do |index|
      @test_processes << Process.fork do
        process_assertion.call("#{testdata_dir}_copy#{index}")
      end
    end

    Process.waitpid @test_processes[0]
    assert_equal 0, $?.exitstatus
    Process.waitpid @test_processes[1]
    assert_equal 0, $?.exitstatus
    Process.waitpid @test_processes[2]
    assert_equal 0, $?.exitstatus
    Process.waitpid @test_processes[3]
    assert_equal 0, $?.exitstatus
  ensure
    @test_processes.each do |pid|
      DTR.kill_process pid
    end
  end

  def test_run_test_case_hacked_run_method
    assert_fork_process_exits_ok do
      require 'hacked_run_method_test_case'

      $argv_dup = ['hacked_run_method_test_case.rb']
      suite = Test::Unit::TestSuite.new('run_test_case_hacked_run_method')
      suite << HackedRunMethodTestCase.suite

      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_should_not_break_heartbeat_of_master_process_when_run_with_a_test_case_sleep_long_time
    assert_fork_process_exits_ok do
      DTR.configuration.master_heartbeat_interval = 1
      DTR.configuration.follower_listen_heartbeat_timeout = 2

      require 'sleep_3_secs_test_case'

      $argv_dup = ['sleep_3_secs_test_case.rb']
      suite = Test::Unit::TestSuite.new('run_test_case_sleep_3_secs')
      suite << Sleep3SecsTestCase.suite

      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_should_add_meaningful_error_when_runner_get_a_unknown_test
    assert_fork_process_exits_ok do
      $argv_dup = ['a_failed_test_case.rb']
      suite = Test::Unit::TestSuite.new('should_add_meaningful_error_when_runner_get_a_unknown_test')
      suite << ATestCase.suite

      @result = runit(suite)

      assert !@result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
      assert_equal "DTR::RemoteError: DTR::Agent::UnknownTestError from #{Socket.gethostname}: No such test loaded: ATestCase", @result.errors.first.message
    end
  end

  def test_run_test_timeout
    assert_fork_process_exits_ok do
      require 'sleep_3_secs_test_case'
      $argv_dup = ['sleep_3_secs_test_case.rb']
      suite = Test::Unit::TestSuite.new('run_test_case_sleep_3_secs')
      suite << Sleep3SecsTestCase.suite

      ENV['RUN_TEST_TIMEOUT'] = '1'
      @result = runit(suite)

      assert !@result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
      assert @result.errors.first.message.include?('Timeout')
    end
  end
end

require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class GeneralTest < Test::Unit::TestCase
  
  def setup
    #start_agents first for test files loaded would be copied into sub processes
    start_agents
    # put these here for we don't want run them in current process
    @pwd = Dir.pwd
    Dir.chdir(File.expand_path(File.dirname(__FILE__) + "/../../testdata/"))
    require 'a_test_case'
    require 'a_test_case2'
    require 'a_failed_test_case'
    require 'an_error_test_case'
    require 'a_file_system_test_case'
    require 'scenario_test_case'
    require 'setup_agent_env_test_case'

    DTR.inject
  end

  def teardown
    DTR.reject
    Dir.chdir(@pwd)
    stop_agents
    $argv_dup = nil
  end

  def test_run_test_passed
    $argv_dup = ['a_test_case.rb', 'a_test_case2.rb', 'a_file_system_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_passed')
    suite << ATestCase.suite
    suite << ATestCase2.suite
    suite << AFileSystemTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 3, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_test_failed
    $argv_dup = ['a_test_case.rb', 'a_failed_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_failed')
    suite << ATestCase.suite
    suite << AFailedTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert !@result.passed?
      assert_equal 2, @result.run_count
      assert_equal 1, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_test_error
    $argv_dup = ['a_test_case.rb', 'an_error_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_error')
    suite << ATestCase.suite
    suite << AnErrorTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert_false @result.passed?
      assert_equal 2, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
    end
  end

  def test_run_suite_should_be_independence
    $argv_dup = ['an_error_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 1')
    suite << AnErrorTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert_false @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 1, @result.error_count
    end

    $argv_dup = ['a_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_suite_should_be_independence 2')
    suite << ATestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_should_ignore_environment_file_not_exists
    $argv_dup = ['a_test_case.rb', 'test_file_not_exists.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_file_not_exist')
    suite << ATestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_and_no_test_files_in_environment
    $argv_dup = []
    suite = Test::Unit::TestSuite.new('test_run_without_test_files')

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_should_not_crash_agent
    $argv_dup = []
    suite = Test::Unit::TestSuite.new('test_run_empty_test_suite_should_not_crash_agent')

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end

    $argv_dup = ['a_test_case.rb']
    suite << ATestCase.suite
    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_empty_test_suite_and_test_files_not_exist_in_environment
    $argv_dup = ['test_file_not_exists.rb']
    suite = Test::Unit::TestSuite.new('test_run_empty_test_suite_and_test_files_not_exist_in_environment')

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 0, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_run_test_specified_by_load_path
    lib_path = File.expand_path(File.dirname(__FILE__) + '/../../testdata/lib')
    $LOAD_PATH.unshift lib_path
    require 'lib_test_case'
    $argv_dup = ['lib_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_run_test_specified_by_load_path')
    suite << LibTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  ensure
    $LOAD_PATH.delete lib_path
  end

  def test_message_of_errors_and_failures_should_include_runner_host_name
    $argv_dup = ['scenario_test_case.rb']
    suite = Test::Unit::TestSuite.new('test_should_wrapper_errors_by_dtr_remote_exception')
    suite << ScenarioTestCase.suite

    assert_fork_process_exits_ok do
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
    $argv_dup = ['setup_agent_env_test_case.rb']
    suite = Test::Unit::TestSuite.new('setup_agent_env_from_master_process')
    suite << SetupAgentEnvTestCase.suite
    ENV['DTR_AGENT_ENV_SETUP_CMD'] = 'touch /tmp/test_setup_agent_env_from_master_process'
    assert_fork_process_exits_ok do
      @result = runit(suite)
      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  ensure
    File.delete('/tmp/test_setup_agent_env_from_master_process') rescue nil
    ENV['DTR_AGENT_ENV_SETUP_CMD'] = nil
  end

  def test_multi_dtr_tasks_should_be_queued_and_processed_one_by_one
    testdata_dir = File.expand_path('./../testdata')
    $argv_dup = ['a_test_case.rb', 'a_test_case2.rb', 'a_file_system_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_passed')
    suite << ATestCase.suite
    suite << ATestCase2.suite
    suite << AFileSystemTestCase.suite
    process_assertion = Proc.new do |master_dir|
      FileUtils.cp_r testdata_dir, master_dir
      begin
        Dir.chdir(master_dir) do
          result = runit(suite)
          assert result.passed?
          assert_equal 3, result.run_count
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
    require 'hacked_run_method_test_case'

    $argv_dup = ['hacked_run_method_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_case_hacked_run_method')
    suite << HackedRunMethodTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  end

  def test_should_not_break_heartbeat_of_master_process_when_run_with_a_test_case_sleep_long_time
    master_heartbeat_interval = DTR.configuration.master_heartbeat_interval
    follower_listen_heartbeat_timeout = DTR.configuration.follower_listen_heartbeat_timeout
    DTR.configuration.master_heartbeat_interval = 1
    DTR.configuration.follower_listen_heartbeat_timeout = 2

    require 'sleep_3_secs_test_case'

    $argv_dup = ['sleep_3_secs_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_case_sleep_3_secs')
    suite << Sleep3SecsTestCase.suite

    assert_fork_process_exits_ok do
      @result = runit(suite)

      assert @result.passed?
      assert_equal 1, @result.run_count
      assert_equal 0, @result.failure_count
      assert_equal 0, @result.error_count
    end
  ensure
    DTR.configuration.master_heartbeat_interval = master_heartbeat_interval
    DTR.configuration.follower_listen_heartbeat_timeout = follower_listen_heartbeat_timeout
  end
end
